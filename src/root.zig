const quickjs_raw = @import("quickjs_raw.zig");

pub const js_app = quickjs_raw.js_app;
pub const JSRuntime = quickjs_raw.JSRuntime;
pub const JSContext = quickjs_raw.JSContext;
pub const JSValue = quickjs_raw.JSValue;
pub const JSValueConst = quickjs_raw.JSValueConst;
pub const JSCFunction = quickjs_raw.JSCFunction;

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

pub inline fn JS_IsObject(value: JSValueConst) bool {
    return quickjs_raw.zjs_is_object(value);
}

pub inline fn JS_IsUndefined(value: JSValueConst) bool {
    return quickjs_raw.zjs_is_undefined(value);
}

pub inline fn JS_IsNull(value: JSValueConst) bool {
    return quickjs_raw.zjs_is_null(value);
}

pub inline fn JS_IsNumber(value: JSValueConst) bool {
    return quickjs_raw.zjs_is_number(value);
}

pub inline fn JS_IsString(value: JSValueConst) bool {
    return quickjs_raw.zjs_is_string(value);
}

pub inline fn JS_IsBool(value: JSValueConst) bool {
    return quickjs_raw.zjs_is_bool(value);
}

pub inline fn JS_IsArray(value: JSValueConst) bool {
    return quickjs_raw.zjs_is_array(value);
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

pub inline fn JS_NewInt32(ctx: *JSContext, value: i32) JSValue {
    return quickjs_raw.zjs_new_int32(ctx, value);
}

pub inline fn JS_NewBool(ctx: *JSContext, value: bool) JSValue {
    return quickjs_raw.zjs_new_bool(ctx, value);
}

pub inline fn JS_NewStringLen(ctx: *JSContext, data: [*c]const u8, len: usize) JSValue {
    return quickjs_raw.zjs_new_string_len(ctx, data, len);
}

pub inline fn JS_FreeValue(ctx: *JSContext, value: JSValue) void {
    quickjs_raw.zjs_free_value(ctx, value);
}

pub inline fn JS_NewCFunction(ctx: *JSContext, func: *const JSCFunction, name: [*c]const u8, length: c_int) JSValue {
    return quickjs_raw.zjs_new_c_function(ctx, func, name, length);
}

pub inline fn JS_GetUndefined() JSValue {
    return quickjs_raw.zjs_make_undefined();
}

pub inline fn asValueConst(value: JSValue) JSValueConst {
    return value;
}
