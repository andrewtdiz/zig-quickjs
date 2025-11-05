const std = @import("std");
const quickjs = @import("quickjs");

const types = @import("types.zig");

pub const FrameData = types.FrameData;
pub const FrameResult = types.FrameResult;
pub const MouseSnapshot = types.MouseSnapshot;

/// JSRuntime owns the QuickJS embedding for per-frame request/response calls.
pub const JSRuntime = struct {
    allocator: std.mem.Allocator,
    handle: *quickjs.js_app,

    pub const Error = error{
        RuntimeInitFailed,
        ScriptLoadFailed,
        CallFailed,
        InvalidResponse,
    };

    pub fn init(allocator: std.mem.Allocator, script_path: []const u8) Error!JSRuntime {
        const runtime = quickjs.js_app_new(-1, -1) orelse return error.RuntimeInitFailed;
        errdefer quickjs.js_app_free(runtime);

        const script_c = allocator.allocSentinel(u8, script_path.len, 0) catch return error.ScriptLoadFailed;
        defer allocator.free(script_c);
        @memcpy(script_c[0..script_path.len], script_path);

        if (quickjs.js_app_eval_file(runtime, script_c.ptr) != 0) {
            warnLastException(runtime, "eval_file");
            return error.ScriptLoadFailed;
        }

        return .{
            .allocator = allocator,
            .handle = runtime,
        };
    }

    pub fn deinit(self: *JSRuntime) void {
        quickjs.js_app_free(self.handle);
    }

    pub fn runFrame(self: *JSRuntime, frame_data: FrameData) Error!FrameResult {
        const ctx = try self.acquireContext();

        const global = quickjs.JS_GetGlobalObject(ctx);
        defer quickjs.JS_FreeValue(ctx, global);
        const global_const = quickjs.asValueConst(global);

        const run_frame_name = "runFrame\x00";
        const run_frame_ptr: [*c]const u8 = @ptrCast(run_frame_name.ptr);
        const func = quickjs.JS_GetPropertyStr(ctx, global_const, run_frame_ptr);
        const func_const: quickjs.JSValueConst = quickjs.asValueConst(func);
        if (quickjs.JS_IsException(func_const)) {
            warnLastException(self.handle, "runFrame.lookup");
            return error.CallFailed;
        }
        defer quickjs.JS_FreeValue(ctx, func);

        if (!quickjs.JS_IsFunction(ctx, func_const)) {
            std.log.err("QuickJS runFrame missing or not callable", .{});
            return error.InvalidResponse;
        }

        const frame_obj = quickjs.JS_NewObject(ctx);
        const frame_obj_const = quickjs.asValueConst(frame_obj);
        if (quickjs.JS_IsException(frame_obj_const)) {
            warnLastException(self.handle, "runFrame.allocFrame");
            return error.CallFailed;
        }
        defer quickjs.JS_FreeValue(ctx, frame_obj);

        const position_f64: f64 = @floatCast(frame_data.position);
        try self.setFloatProperty(ctx, frame_obj_const, "position", position_f64);

        const dt_f64: f64 = @floatCast(frame_data.dt);
        try self.setFloatProperty(ctx, frame_obj_const, "dt", dt_f64);

        var argv = [_]quickjs.JSValueConst{ frame_obj_const };
        const argc = @as(c_int, @intCast(argv.len));
        const argv_ptr: [*c]quickjs.JSValueConst = @ptrCast(&argv[0]);
        const result_value = quickjs.JS_Call(
            ctx,
            func_const,
            global_const,
            argc,
            argv_ptr,
        );
        const result_const: quickjs.JSValueConst = quickjs.asValueConst(result_value);
        if (quickjs.JS_IsException(result_const)) {
            warnLastException(self.handle, "runFrame.call");
            return error.CallFailed;
        }
        defer quickjs.JS_FreeValue(ctx, result_value);

        const pending_jobs = quickjs.js_app_execute_jobs(self.handle, 0);
        if (pending_jobs < 0) {
            warnLastException(self.handle, "runFrame.jobs");
            return error.CallFailed;
        }

        var new_position_f64: f64 = 0;
        if (quickjs.JS_ToFloat64(ctx, &new_position_f64, result_const) < 0) {
            warnLastException(self.handle, "runFrame.toFloat");
            return error.InvalidResponse;
        }
        if (!std.math.isFinite(new_position_f64)) return error.InvalidResponse;

        const new_position: f32 = @floatCast(new_position_f64);
        if (!std.math.isFinite(new_position)) return error.InvalidResponse;

        return .{ .new_position = new_position };
    }

    pub fn updateMouse(self: *JSRuntime, mouse: MouseSnapshot) Error!void {
        const ctx = try self.acquireContext();

        const global = quickjs.JS_GetGlobalObject(ctx);
        defer quickjs.JS_FreeValue(ctx, global);
        const global_const = quickjs.asValueConst(global);

        const mouse_prop = "mouse\x00";
        const mouse_prop_ptr: [*c]const u8 = @ptrCast(mouse_prop.ptr);

        const mouse_obj = quickjs.JS_NewObject(ctx);
        const mouse_obj_const = quickjs.asValueConst(mouse_obj);
        if (quickjs.JS_IsException(mouse_obj_const)) {
            warnLastException(self.handle, "mouse.alloc");
            return error.CallFailed;
        }

        const x_value: f64 = @floatFromInt(mouse.x);
        self.setFloatProperty(ctx, mouse_obj_const, "x", x_value) catch |err| {
            quickjs.JS_FreeValue(ctx, mouse_obj);
            return err;
        };

        const y_value: f64 = @floatFromInt(mouse.y);
        self.setFloatProperty(ctx, mouse_obj_const, "y", y_value) catch |err| {
            quickjs.JS_FreeValue(ctx, mouse_obj);
            return err;
        };

        if (quickjs.JS_SetPropertyStr(ctx, global_const, mouse_prop_ptr, mouse_obj) < 0) {
            quickjs.JS_FreeValue(ctx, mouse_obj);
            warnLastException(self.handle, "mouse.set");
            return error.CallFailed;
        }
    }

    fn setFloatProperty(
        self: *JSRuntime,
        ctx: *quickjs.JSContext,
        target: quickjs.JSValueConst,
        comptime name: []const u8,
        value: f64,
    ) Error!void {
        const property_value = quickjs.JS_NewFloat64(ctx, value);
        const prop_name = name ++ "\x00";
        const prop_ptr: [*c]const u8 = @ptrCast(prop_name.ptr);
        if (quickjs.JS_SetPropertyStr(ctx, target, prop_ptr, property_value) < 0) {
            quickjs.JS_FreeValue(ctx, property_value);
            warnLastException(self.handle, name);
            return error.CallFailed;
        }
    }

    fn acquireContext(self: *JSRuntime) Error!*quickjs.JSContext {
        const ctx_ptr = quickjs.js_app_get_context(self.handle) orelse {
            warnLastException(self.handle, "context");
            return error.CallFailed;
        };
        return @ptrCast(ctx_ptr);
    }
};

/// Global pointer for accessing the runtime from decoupled modules.
/// App.init installs the pointer and must clear it during shutdown.
pub var g_runtime: ?*JSRuntime = null;

pub fn setGlobalRuntime(runtime: *JSRuntime) void {
    g_runtime = runtime;
}

pub fn clearGlobalRuntime() void {
    g_runtime = null;
}

fn warnLastException(runtime: *quickjs.js_app, context: []const u8) void {
    var buffer: [512]u8 = undefined;
    @memset(buffer[0..], 0);
    const rc = quickjs.js_app_last_exception(runtime, &buffer, buffer.len);
    if (rc == 0) {
        const message = std.mem.sliceTo(buffer[0..], 0);
        std.log.err("QuickJS {s}: {s}", .{ context, message });
    } else {
        std.log.debug("QuickJS {s}: <exception already reported>", .{context});
    }
}
