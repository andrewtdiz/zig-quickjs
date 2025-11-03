const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Import the Zig module from the parent package so @import("quickjs") resolves
    const dep = b.dependency("zig_quickjs", .{});
    const root_mod = b.createModule(.{
        .root_source_file = b.path("demo.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "quickjs", .module = dep.module("quickjs") },
        },
    });

    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = root_mod,
    });

    // Compile and link the C wrapper alongside the QuickJS static lib
    var c_flags: std.ArrayList([]const u8) = .empty;
    defer c_flags.deinit(b.allocator);
    const is_msvc = target.result.abi == .msvc;
    if (is_msvc) {
        c_flags.appendSlice(b.allocator, &.{ "/std:c11", "/D_GNU_SOURCE" }) catch unreachable;
    } else {
        c_flags.appendSlice(b.allocator, &.{ "-std=c11", "-D_GNU_SOURCE" }) catch unreachable;
    }
    exe.addIncludePath(b.path("../../src"));
    exe.addIncludePath(b.path("../../quickjs"));
    exe.addCSourceFiles(.{ .files = &.{ "../../src/wrapper.c" }, .flags = c_flags.items });

    exe.linkLibrary(dep.artifact("quickjs"));
    exe.linkLibC();
    b.installArtifact(exe);

    // Optional: convenience run step 
    const run_step = b.step("run", "Run example with demo.js");
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.addArg(b.path("demo.js").getPath(b));
    run_step.dependOn(&run_cmd.step);
}
