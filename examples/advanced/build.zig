const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Import the Zig module from the parent package so @import("quickjs") resolves
    const dep = b.dependency("quickjs", .{});
    const root_mod = b.createModule(.{
        .root_source_file = b.path("./src/demo.zig"),
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

    // Link against the prebuilt wrapper library from the parent package
    exe.linkLibrary(dep.artifact("zig-quickjs"));
    exe.linkLibC();
    b.installArtifact(exe);

    // Optional: convenience run step 
    const run_step = b.step("run", "Run advanced example (pass script path after --)");
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.addArg(b.path("demo.js").getPath(b));
    run_step.dependOn(&run_cmd.step);
}
