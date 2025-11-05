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

JSValue zjs_new_object(JSContext *ctx) {
    return JS_NewObject(ctx);
}

JSValue zjs_new_float64(JSContext *ctx, double value) {
    return JS_NewFloat64(ctx, value);
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

void zjs_free_value(JSContext *ctx, JSValue value) {
    JS_FreeValue(ctx, value);
}
