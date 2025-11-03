const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep = b.dependency("quickjs", .{});
    const root_mod = b.createModule(.{
        .root_source_file = b.path("demo.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "quickjs", .module = dep.module("quickjs") },
        },
    });

    const exe = b.addExecutable(.{
        .name = "example-simple",
        .root_module = root_mod,
    });

    exe.linkLibrary(dep.artifact("zig-quickjs"));
    exe.linkLibC();
    b.installArtifact(exe);

    const run_step = b.step("run", "Run simple example (pass script path after --)");
    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    run_step.dependOn(&run_cmd.step);
}
