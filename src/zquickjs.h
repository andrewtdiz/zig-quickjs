#ifndef ZIG_QUICKJS_API_H
#define ZIG_QUICKJS_API_H

#include <stdbool.h>

#include "quickjs.h"

#ifdef __cplusplus
extern "C" {
#endif

JSValue zjs_get_global_object(JSContext *ctx);
JSValue zjs_get_property_str(JSContext *ctx, JSValueConst obj, const char *prop);
bool zjs_is_exception(JSValueConst value);
bool zjs_is_function(JSContext *ctx, JSValueConst value);
bool zjs_is_object(JSValueConst value);
bool zjs_is_undefined(JSValueConst value);
bool zjs_is_null(JSValueConst value);
bool zjs_is_number(JSValueConst value);
bool zjs_is_string(JSValueConst value);
bool zjs_is_bool(JSValueConst value);
bool zjs_is_array(JSValueConst value);
JSValue zjs_new_object(JSContext *ctx);
JSValue zjs_new_float64(JSContext *ctx, double value);
int zjs_set_property_str(JSContext *ctx, JSValueConst obj, const char *prop, JSValue value);
JSValue zjs_call(JSContext *ctx, JSValueConst func, JSValueConst this_obj, int argc, JSValueConst *argv);
JSValue zjs_new_int32(JSContext *ctx, int32_t value);
JSValue zjs_new_bool(JSContext *ctx, bool value);
JSValue zjs_new_string_len(JSContext *ctx, const char *data, size_t len);
int zjs_to_float64(JSContext *ctx, double *out_value, JSValueConst value);
void zjs_free_value(JSContext *ctx, JSValue value);
JSValue zjs_new_c_function(JSContext *ctx, JSCFunction *func, const char *name, int length);
JSValue zjs_make_undefined(void);

#ifdef __cplusplus
}
#endif

#endif
