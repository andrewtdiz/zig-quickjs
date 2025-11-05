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
JSValue zjs_new_object(JSContext *ctx);
JSValue zjs_new_float64(JSContext *ctx, double value);
int zjs_set_property_str(JSContext *ctx, JSValueConst obj, const char *prop, JSValue value);
JSValue zjs_call(JSContext *ctx, JSValueConst func, JSValueConst this_obj, int argc, JSValueConst *argv);
int zjs_to_float64(JSContext *ctx, double *out_value, JSValueConst value);
void zjs_free_value(JSContext *ctx, JSValue value);

#ifdef __cplusplus
}
#endif

#endif
