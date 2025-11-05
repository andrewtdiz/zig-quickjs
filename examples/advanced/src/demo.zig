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
        std.debug.print("JS exception (already reported)\n", .{});
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

    const greet_symbol: [:0]const u8 = "greetFromJs";
    const name_arg: [:0]const u8 = "Zig Runner";
    var args = [_][*c]const u8{@ptrCast(name_arg.ptr)};
    var greet_out: [256]u8 = undefined;
    const greet_status = quickjs.js_app_call_global(
        app,
        @ptrCast(greet_symbol.ptr),
        @ptrCast(&args),
        @intCast(args.len),
        @ptrCast(greet_out[0..].ptr),
        greet_out.len,
    );
    if (greet_status == 0) {
        const greet_slice = greet_out[0..];
        const greet_end = std.mem.indexOfScalar(u8, greet_slice, 0) orelse greet_slice.len;
        std.debug.print("greetFromJs returned: {s}\n", .{greet_slice[0..greet_end]});
    } else {
        std.debug.print("greetFromJs call failed\n", .{});
        printJsException(app);
    }

    const faulty_symbol: [:0]const u8 = "faultyAccessor";
    var unused: [1]u8 = .{0};
    const faulty_status = quickjs.js_app_call_global(
        app,
        @ptrCast(faulty_symbol.ptr),
        @ptrFromInt(0),
        0,
        @ptrCast(unused[0..].ptr),
        unused.len,
    );
    if (faulty_status != 0) {
        std.debug.print("faultyAccessor threw as expected\n", .{});
        printJsException(app);
    } else {
        std.debug.print("faultyAccessor unexpectedly succeeded\n", .{});
    }

    std.debug.print("Pumping pending jobs...\n", .{});
    const executed = quickjs.js_app_execute_jobs(app, 8);
    if (executed >= 0) {
        std.debug.print("Executed {d} pending jobs\n", .{executed});
    } else {
        std.debug.print("Encountered error while executing jobs\n", .{});
        printJsException(app);
    }
}
