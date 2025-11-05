const quickjs_raw = @import("quickjs_raw.zig");

pub const js_app = quickjs_raw.js_app;
pub const JSRuntime = quickjs_raw.JSRuntime;
pub const JSContext = quickjs_raw.JSContext;
pub const JSValue = quickjs_raw.JSValue;
pub const JSValueConst = quickjs_raw.JSValueConst;

pub inline fn js_app_new(width: c_int, height: c_int) ?*js_app {
    return quickjs_raw.js_app_new(width, height);
}

pub inline fn js_app_free(app: ?*js_app) void {
    quickjs_raw.js_app_free(app);
}

pub inline fn js_app_eval_file(app: ?*js_app, path: [*c]const u8) c_int {
    return quickjs_raw.js_app_eval_file(app, path);
}

pub inline fn js_app_eval_module_file(app: ?*js_app, path: [*c]const u8) c_int {
    return quickjs_raw.js_app_eval_module_file(app, path);
}

pub inline fn js_app_eval_code(app: ?*js_app, code: [*c]const u8, filename: [*c]const u8, is_module: c_int) c_int {
    return quickjs_raw.js_app_eval_code(app, code, filename, is_module);
}

pub inline fn js_app_eval_prelude(app: ?*js_app, code: [*c]const u8, filename: [*c]const u8, is_module: c_int) c_int {
    return quickjs_raw.js_app_eval_prelude(app, code, filename, is_module);
}

pub inline fn js_app_eval_prelude_file(app: ?*js_app, path: [*c]const u8, is_module: c_int) c_int {
    return quickjs_raw.js_app_eval_prelude_file(app, path, is_module);
}

pub inline fn js_app_run_loop(app: ?*js_app) void {
    quickjs_raw.js_app_run_loop(app);
}

pub inline fn js_app_execute_jobs(app: ?*js_app, max_jobs: c_int) c_int {
    return quickjs_raw.js_app_execute_jobs(app, max_jobs);
}

pub inline fn js_app_last_exception(app: ?*js_app, out_buf: [*c]u8, out_buf_len: usize) c_int {
    return quickjs_raw.js_app_last_exception(app, out_buf, out_buf_len);
}

pub inline fn js_app_call_global(app: ?*js_app, func_name: [*c]const u8, argv: [*c]const [*c]const u8, argc: c_int, out_buf: [*c]u8, out_buf_len: usize) c_int {
    return quickjs_raw.js_app_call_global(app, func_name, argv, argc, out_buf, out_buf_len);
}

pub inline fn js_app_get_context(app: ?*js_app) ?*anyopaque {
    return quickjs_raw.js_app_get_context(app);
}

pub inline fn JS_GetGlobalObject(ctx: *JSContext) JSValue {
    return quickjs_raw.zjs_get_global_object(ctx);
}

pub inline fn JS_GetPropertyStr(ctx: *JSContext, obj: JSValueConst, prop: [*c]const u8) JSValue {
    return quickjs_raw.zjs_get_property_str(ctx, obj, prop);
}

pub inline fn JS_IsException(value: JSValueConst) bool {
    return quickjs_raw.zjs_is_exception(value);
}

pub inline fn JS_IsFunction(ctx: *JSContext, value: JSValueConst) bool {
    return quickjs_raw.zjs_is_function(ctx, value);
}

pub inline fn JS_NewObject(ctx: *JSContext) JSValue {
    return quickjs_raw.zjs_new_object(ctx);
}

pub inline fn JS_NewFloat64(ctx: *JSContext, value: f64) JSValue {
    return quickjs_raw.zjs_new_float64(ctx, value);
}

pub inline fn JS_SetPropertyStr(ctx: *JSContext, obj: JSValueConst, prop: [*c]const u8, value: JSValue) c_int {
    return quickjs_raw.zjs_set_property_str(ctx, obj, prop, value);
}

pub inline fn JS_Call(ctx: *JSContext, func: JSValueConst, this_obj: JSValueConst, argc: c_int, argv: [*c]JSValueConst) JSValue {
    return quickjs_raw.zjs_call(ctx, func, this_obj, argc, argv);
}

pub inline fn JS_ToFloat64(ctx: *JSContext, out_value: *f64, value: JSValueConst) c_int {
    return quickjs_raw.zjs_to_float64(ctx, out_value, value);
}

pub inline fn JS_FreeValue(ctx: *JSContext, value: JSValue) void {
    quickjs_raw.zjs_free_value(ctx, value);
}

pub inline fn asValueConst(value: JSValue) JSValueConst {
    return value;
}
