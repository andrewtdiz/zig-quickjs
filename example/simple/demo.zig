const std = @import("std");
const quickjs = @import("quickjs");

pub fn main() !void {
    if (std.os.argv.len < 2) {
        std.debug.print("usage: demo js_path\n", .{});
        return;
    }

    const script_path = std.os.argv[1];
    const app = quickjs.js_app_new(-1, -1) orelse {
        std.debug.print("failed to create quickjs runtime\n", .{});
        return;
    };
    defer quickjs.js_app_free(app);

    if (quickjs.js_app_eval_file(app, script_path) != 0) {
        var buf: [512]u8 = undefined;
        if (quickjs.js_app_last_exception(app, &buf, buf.len) == 0) {
            const slice = buf[0..];
            const end = std.mem.indexOfScalar(u8, slice, 0) orelse slice.len;
            std.debug.print("JS exception: {s}\n", .{slice[0..end]});
        } else {
            std.debug.print("JS exception (unavailable)\n", .{});
        }
        return;
    }

    quickjs.js_app_run_loop(app);
}
