pub const js_app = opaque {};
pub const JSRuntime = opaque {};
pub const JSContext = opaque {};

pub const JSValueUnion = extern union {
    int32: i32,
    float64: f64,
    ptr: ?*anyopaque,
    short_big_int: i32,
};

pub const JSValue = extern struct {
    u: JSValueUnion,
    tag: i64,
};

pub const JSValueConst = JSValue;
pub const JSCFunction = fn (*JSContext, JSValueConst, c_int, [*c]JSValueConst) callconv(.c) JSValue;

pub extern "c" fn js_app_new(width: c_int, height: c_int) ?*js_app;
pub extern "c" fn js_app_free(app: ?*js_app) void;
pub extern "c" fn js_app_eval_file(app: ?*js_app, path: [*c]const u8) c_int;
pub extern "c" fn js_app_eval_module_file(app: ?*js_app, path: [*c]const u8) c_int;
pub extern "c" fn js_app_eval_code(app: ?*js_app, code: [*c]const u8, filename: [*c]const u8, is_module: c_int) c_int;
pub extern "c" fn js_app_eval_prelude(app: ?*js_app, code: [*c]const u8, filename: [*c]const u8, is_module: c_int) c_int;
pub extern "c" fn js_app_eval_prelude_file(app: ?*js_app, path: [*c]const u8, is_module: c_int) c_int;
pub extern "c" fn js_app_run_loop(app: ?*js_app) void;
pub extern "c" fn js_app_execute_jobs(app: ?*js_app, max_jobs: c_int) c_int;
pub extern "c" fn js_app_last_exception(app: ?*js_app, out_buf: [*c]u8, out_buf_len: usize) c_int;
pub extern "c" fn js_app_call_global(app: ?*js_app, func_name: [*c]const u8, argv: [*c]const [*c]const u8, argc: c_int, out_buf: [*c]u8, out_buf_len: usize) c_int;
pub extern "c" fn js_app_get_context(app: ?*js_app) ?*anyopaque;

pub extern "c" fn zjs_get_global_object(ctx: *JSContext) JSValue;
pub extern "c" fn zjs_get_property_str(ctx: *JSContext, obj: JSValueConst, prop: [*c]const u8) JSValue;
pub extern "c" fn zjs_is_exception(value: JSValueConst) bool;
pub extern "c" fn zjs_is_function(ctx: *JSContext, value: JSValueConst) bool;
pub extern "c" fn zjs_is_object(value: JSValueConst) bool;
pub extern "c" fn zjs_is_undefined(value: JSValueConst) bool;
pub extern "c" fn zjs_is_null(value: JSValueConst) bool;
pub extern "c" fn zjs_is_number(value: JSValueConst) bool;
pub extern "c" fn zjs_is_string(value: JSValueConst) bool;
pub extern "c" fn zjs_is_bool(value: JSValueConst) bool;
pub extern "c" fn zjs_is_array(value: JSValueConst) bool;
pub extern "c" fn zjs_new_object(ctx: *JSContext) JSValue;
pub extern "c" fn zjs_new_float64(ctx: *JSContext, value: f64) JSValue;
pub extern "c" fn zjs_new_int32(ctx: *JSContext, value: i32) JSValue;
pub extern "c" fn zjs_new_bool(ctx: *JSContext, value: bool) JSValue;
pub extern "c" fn zjs_new_string_len(ctx: *JSContext, data: [*c]const u8, len: usize) JSValue;
pub extern "c" fn zjs_set_property_str(ctx: *JSContext, obj: JSValueConst, prop: [*c]const u8, value: JSValue) c_int;
pub extern "c" fn zjs_call(ctx: *JSContext, func: JSValueConst, this_obj: JSValueConst, argc: c_int, argv: [*c]JSValueConst) JSValue;
pub extern "c" fn zjs_to_float64(ctx: *JSContext, out_value: *f64, value: JSValueConst) c_int;
pub extern "c" fn zjs_free_value(ctx: *JSContext, value: JSValue) void;
pub extern "c" fn zjs_new_c_function(ctx: *JSContext, func: *const JSCFunction, name: [*c]const u8, length: c_int) JSValue;
pub extern "c" fn zjs_make_undefined() JSValue;
pub extern "c" fn zjs_eval(ctx: *JSContext, code: [*c]const u8, len: usize, filename: [*c]const u8, flags: c_int) JSValue;
pub extern "c" fn zjs_to_cstring_len(ctx: *JSContext, out_len: *usize, value: JSValueConst) [*c]const u8;
pub extern "c" fn zjs_free_cstring(ctx: *JSContext, ptr: [*c]const u8) void;
