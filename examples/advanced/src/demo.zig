const std = @import("std");
const quickjs = @import("quickjs");

const AppError = error{
    CreateFailed,
    PreludeFailed,
    ScriptFailed,
    OutOfMemory,
};

fn printJsException(app: *quickjs.js_app) void {
    var buf: [4096]u8 = undefined;
    if (quickjs.js_app_last_exception(app, &buf, buf.len) == 0) {
        const slice = buf[0..];
        const end = std.mem.indexOfScalar(u8, slice, 0) orelse slice.len;
        std.debug.print("JS exception: {s}\n", .{slice[0..end]});
    } else {
        std.debug.print("JS exception (unavailable)\n", .{});
    }
}

fn applyPrelude(app: *quickjs.js_app) AppError!void {
    const allocator = std.heap.c_allocator;
    const prelude_src =
        "globalThis.setTimeout = os.setTimeout;\n" ++
        "globalThis.setInterval = os.setInterval;\n" ++
        "globalThis.clearTimeout = os.clearTimeout;\n" ++
        "globalThis.clearInterval = os.clearInterval;\n";

    var buffer = allocator.alloc(u8, prelude_src.len + 1) catch return AppError.OutOfMemory;
    defer allocator.free(buffer);
    std.mem.copyForwards(u8, buffer[0..prelude_src.len], prelude_src);
    buffer[prelude_src.len] = 0;

    const label = "<prelude>\x00";
    const code_ptr: [*c]const u8 = @ptrCast(buffer.ptr);
    const label_ptr: [*c]const u8 = @ptrCast(label.ptr);
    if (quickjs.js_app_eval_prelude(app, code_ptr, label_ptr, 0) != 0) {
        return AppError.PreludeFailed;
    }
}

pub fn main() AppError!void {
    if (std.os.argv.len < 2) {
        std.debug.print("usage: demo js_path\n", .{});
        return;
    }

    const script_path = std.os.argv[1];
    const app = quickjs.js_app_new(-1, -1) orelse return AppError.CreateFailed;
    defer quickjs.js_app_free(app);

    if (applyPrelude(app)) |_| {} else |err| {
        printJsException(app);
        return err;
    }

    if (quickjs.js_app_eval_file(app, script_path) != 0) {
        printJsException(app);
        return AppError.ScriptFailed;
    }

    quickjs.js_app_run_loop(app);
}
