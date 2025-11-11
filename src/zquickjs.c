#include "zquickjs.h"

#include <stdbool.h>

JSValue zjs_get_global_object(JSContext *ctx) {
    return JS_GetGlobalObject(ctx);
}

JSValue zjs_get_property_str(JSContext *ctx, JSValueConst obj, const char *prop) {
    return JS_GetPropertyStr(ctx, obj, prop);
}

bool zjs_is_exception(JSValueConst value) {
    return JS_IsException(value);
}

bool zjs_is_function(JSContext *ctx, JSValueConst value) {
    return JS_IsFunction(ctx, value);
}

bool zjs_is_object(JSValueConst value) {
    return JS_IsObject(value);
}

bool zjs_is_undefined(JSValueConst value) {
    return JS_IsUndefined(value);
}

bool zjs_is_null(JSValueConst value) {
    return JS_IsNull(value);
}

bool zjs_is_number(JSValueConst value) {
    return JS_IsNumber(value);
}

bool zjs_is_string(JSValueConst value) {
    return JS_IsString(value);
}

bool zjs_is_bool(JSValueConst value) {
    return JS_IsBool(value);
}

bool zjs_is_array(JSValueConst value) {
    return JS_IsArray(value);
}

JSValue zjs_new_object(JSContext *ctx) {
    return JS_NewObject(ctx);
}

JSValue zjs_new_float64(JSContext *ctx, double value) {
    return JS_NewFloat64(ctx, value);
}

JSValue zjs_new_int32(JSContext *ctx, int32_t value) {
    return JS_NewInt32(ctx, value);
}

JSValue zjs_new_int64(JSContext *ctx, int64_t value) {
    return JS_NewInt64(ctx, value);
}

JSValue zjs_new_bool(JSContext *ctx, bool value) {
    return JS_NewBool(ctx, value);
}

JSValue zjs_new_string_len(JSContext *ctx, const char *data, size_t len) {
    return JS_NewStringLen(ctx, data, len);
}

int zjs_set_property_str(JSContext *ctx, JSValueConst obj, const char *prop, JSValue value) {
    return JS_SetPropertyStr(ctx, obj, prop, value);
}

JSValue zjs_call(JSContext *ctx, JSValueConst func, JSValueConst this_obj, int argc, JSValueConst *argv) {
    return JS_Call(ctx, func, this_obj, argc, argv);
}

int zjs_to_float64(JSContext *ctx, double *out_value, JSValueConst value) {
    return JS_ToFloat64(ctx, out_value, value);
}

int zjs_to_uint32(JSContext *ctx, uint32_t *out_value, JSValueConst value) {
    return JS_ToUint32(ctx, out_value, value);
}

int zjs_to_int32(JSContext *ctx, int32_t *out_value, JSValueConst value) {
    return JS_ToInt32(ctx, out_value, value);
}

void zjs_free_value(JSContext *ctx, JSValue value) {
    JS_FreeValue(ctx, value);
}

JSValue zjs_new_c_function(JSContext *ctx, JSCFunction *func, const char *name, int length) {
    return JS_NewCFunction(ctx, func, name, length);
}

JSValue zjs_make_undefined(void) {
    return JS_UNDEFINED;
}

JSValue zjs_eval(JSContext *ctx, const char *code, size_t len, const char *filename, int flags) {
    return JS_Eval(ctx, code, len, filename, flags);
}

const char *zjs_to_cstring_len(JSContext *ctx, size_t *len, JSValueConst value) {
    return JS_ToCStringLen(ctx, len, value);
}

void zjs_free_cstring(JSContext *ctx, const char *ptr) {
    JS_FreeCString(ctx, ptr);
}

void zjs_update_stack_top(JSRuntime *rt) {
    JS_UpdateStackTop(rt);
}
