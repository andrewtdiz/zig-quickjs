#include "wrapper.h"
#include "quickjs.h"
#include "quickjs-libc.h"
#include <stdlib.h>
#include <string.h>

struct js_app {
    JSRuntime *rt;
    JSContext *ctx;
};

static void js_setup_globals(JSContext *ctx) {
    js_init_module_bjson(ctx, "qjs:bjson");
    js_init_module_std(ctx, "qjs:std");
    js_init_module_os(ctx, "qjs:os");

    const char *prelude =
        "import * as bjson from 'qjs:bjson';\n"
        "import * as std from 'qjs:std';\n"
        "import * as os from 'qjs:os';\n"
        "globalThis.bjson = bjson;\n"
        "globalThis.std = std;\n"
        "globalThis.os = os;\n";
    JSValue v = JS_Eval(ctx, prelude, strlen(prelude), "<prelude>", JS_EVAL_TYPE_MODULE);
    if (JS_IsException(v)) {
        js_std_dump_error(ctx);
    }
    JS_FreeValue(ctx, v);
}

js_app* js_app_new(int width, int height) {
    (void)width;
    (void)height;

    JSRuntime *rt = JS_NewRuntime();
    if (!rt) return NULL;
    js_std_init_handlers(rt);

    JSContext *ctx = JS_NewContext(rt);
    if (!ctx) {
        js_std_free_handlers(rt);
        JS_FreeRuntime(rt);
        return NULL;
    }

    JS_SetModuleLoaderFunc(rt, NULL, js_module_loader, NULL);
    JS_SetHostPromiseRejectionTracker(rt, js_std_promise_rejection_tracker, NULL);

    js_std_add_helpers(ctx, -1, NULL);
    js_setup_globals(ctx);

    struct js_app *app = (struct js_app*)malloc(sizeof(struct js_app));
    if (!app) {
        JS_FreeContext(ctx);
        js_std_free_handlers(rt);
        JS_FreeRuntime(rt);
        return NULL;
    }
    app->rt = rt;
    app->ctx = ctx;
    return app;
}

// Internal: stringify exception into buffer; returns 0 on success, -1 otherwise.
static int format_exception(JSContext* ctx, JSValueConst exc, char* out_buf, size_t out_len) {
    if (!out_buf || out_len == 0) return -1;
    out_buf[0] = '\0';
    if (JS_IsNull(exc) || JS_IsUndefined(exc)) return -1;

    JSValue msg = JS_UNDEFINED;
    // Prefer stack for Error objects
    if (JS_IsError(exc)) {
        msg = JS_GetPropertyStr(ctx, exc, "stack");
    }
    if (JS_IsUndefined(msg)) {
        msg = JS_DupValue(ctx, (JSValue)exc);
    }
    size_t len = 0;
    const char* cstr = JS_ToCStringLen(ctx, &len, msg);
    if (!cstr) {
        JS_FreeValue(ctx, msg);
        return -1;
    }
    size_t copy_len = len < (out_len - 1) ? len : (out_len - 1);
    memcpy(out_buf, cstr, copy_len);
    out_buf[copy_len] = '\0';
    JS_FreeCString(ctx, cstr);
    JS_FreeValue(ctx, msg);
    return 0;
}

int js_app_eval_file(js_app* app, const char* path) {
    if (!app || !path) return -1;
    size_t len = 0;
    uint8_t *buf = js_load_file(app->ctx, &len, path);
    if (!buf) return -1;

    const int flags = 0; // classic script
    JSValue v = JS_Eval(app->ctx, (const char *)buf, len, path, flags);
    js_free(app->ctx, buf);
    if (JS_IsException(v)) {
        JS_FreeValue(app->ctx, v);
        return -1;
    }
    JS_FreeValue(app->ctx, v);
    return 0;
}

int js_app_eval_module_file(js_app* app, const char* path) {
    if (!app || !path) return -1;
    size_t len = 0;
    uint8_t *buf = js_load_file(app->ctx, &len, path);
    if (!buf) return -1;
    const int flags = JS_EVAL_TYPE_MODULE;
    JSValue v = JS_Eval(app->ctx, (const char *)buf, len, path, flags);
    js_free(app->ctx, buf);
    if (JS_IsException(v)) {
        JS_FreeValue(app->ctx, v);
        return -1;
    }
    JS_FreeValue(app->ctx, v);
    return 0;
}

int js_app_eval_code(js_app* app, const char* code, const char* filename, int is_module) {
    if (!app || !code) return -1;
    const char* fname = filename ? filename : "<input>";
    const int flags = is_module ? JS_EVAL_TYPE_MODULE : 0;
    JSValue v = JS_Eval(app->ctx, code, strlen(code), fname, flags);
    if (JS_IsException(v)) {
        JS_FreeValue(app->ctx, v);
        return -1;
    }
    JS_FreeValue(app->ctx, v);
    return 0;
}

int js_app_eval_prelude(js_app* app, const char* code, const char* filename, int is_module) {
    return js_app_eval_code(app, code, filename, is_module);
}

int js_app_eval_prelude_file(js_app* app, const char* path, int is_module) {
    if (is_module) {
        return js_app_eval_module_file(app, path);
    }
    return js_app_eval_file(app, path);
}

void js_app_run_loop(js_app* app) {
    if (!app) return;
    int has_exc = js_std_loop(app->ctx);
    if (has_exc) {
        // Dump any exception that caused the loop to exit (e.g., timer callback errors)
        js_std_dump_error(app->ctx);
        // Clear the exception so the context remains usable
        (void)JS_GetException(app->ctx); // fetched and freed by js_std_dump_error already
    }
}

int js_app_execute_jobs(js_app* app, int max_jobs) {
    if (!app) return -1;
    JSContext* ctx = NULL;
    int executed = 0;
    for (;;) {
        int ret = JS_ExecutePendingJob(JS_GetRuntime(app->ctx), &ctx);
        if (ret <= 0) break; // 0 = queue empty, <0 = error
        executed += ret;
        if (max_jobs > 0 && executed >= max_jobs) break;
    }
    return executed;
}

int js_app_last_exception(js_app* app, char* out_buf, size_t out_buf_len) {
    if (!app) return -1;
    JSValue exc = JS_GetException(app->ctx);
    if (JS_IsNull(exc) || JS_IsUndefined(exc)) {
        JS_FreeValue(app->ctx, exc);
        return -1;
    }
    int ok = format_exception(app->ctx, exc, out_buf, out_buf_len);
    JS_FreeValue(app->ctx, exc);
    return ok;
}

int js_app_call_global(js_app* app,
                       const char* func_name,
                       const char* const* argv,
                       int argc,
                       char* out_buf,
                       size_t out_buf_len) {
    if (!app || !func_name) return -1;
    JSContext* ctx = app->ctx;
    JSValue global = JS_GetGlobalObject(ctx);
    JSValue fn = JS_GetPropertyStr(ctx, global, func_name);
    if (!JS_IsFunction(ctx, fn)) {
        JS_FreeValue(ctx, fn);
        JS_FreeValue(ctx, global);
        return -1;
    }
    // Prepare arguments as JS strings
    JSValue args_storage[16];
    JSValue* args = args_storage;
    if (argc > (int)(sizeof(args_storage)/sizeof(args_storage[0]))) {
        args = (JSValue*)js_malloc(ctx, sizeof(JSValue) * (size_t)argc);
        if (!args) {
            JS_FreeValue(ctx, fn);
            JS_FreeValue(ctx, global);
            return -1;
        }
    }
    for (int i = 0; i < argc; ++i) {
        const char* s = argv ? argv[i] : NULL;
        args[i] = s ? JS_NewString(ctx, s) : JS_UNDEFINED;
    }
    JSValue ret = JS_Call(ctx, fn, global, argc, args);
    for (int i = 0; i < argc; ++i) {
        if (!JS_IsUndefined(args[i])) JS_FreeValue(ctx, args[i]);
    }
    if (args != args_storage) js_free(ctx, args);
    JS_FreeValue(ctx, fn);
    JS_FreeValue(ctx, global);

    if (JS_IsException(ret)) {
        JS_FreeValue(ctx, ret);
        return -1;
    }
    // Convert result to string
    size_t len = 0;
    const char* cstr = JS_ToCStringLen(ctx, &len, ret);
    if (!cstr) {
        JS_FreeValue(ctx, ret);
        return -1;
    }
    if (out_buf && out_buf_len > 0) {
        size_t copy_len = len < (out_buf_len - 1) ? len : (out_buf_len - 1);
        memcpy(out_buf, cstr, copy_len);
        out_buf[copy_len] = '\0';
    }
    JS_FreeCString(ctx, cstr);
    JS_FreeValue(ctx, ret);
    return 0;
}

void* js_app_get_context(js_app* app) {
    if (!app) return NULL;
    return app->ctx;
}

void js_app_free(js_app* app) {
    if (!app) return;
    JSRuntime *rt = app->rt;
    JSContext *ctx = app->ctx;
    js_std_free_handlers(rt);
    JS_FreeContext(ctx);
    JS_FreeRuntime(rt);
    free(app);
}
