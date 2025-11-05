const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Expose the translated Zig wrapper as a module named "quickjs"
    _ = b.addModule("quickjs", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Build and export the QuickJS C library from ./quickjs
    const is_msvc = target.result.abi == .msvc;
    var c_flags: std.ArrayList([]const u8) = .empty;
    defer c_flags.deinit(b.allocator);
    if (is_msvc) {
        c_flags.appendSlice(b.allocator, &.{
            "/std:c11",
            "/D_GNU_SOURCE",
            "/DWIN32_LEAN_AND_MEAN",
            "/D_WIN32_WINNT=0x0602",
            "/D_CRT_SECURE_NO_WARNINGS",
        }) catch unreachable;
    } else {
        c_flags.appendSlice(b.allocator, &.{
            "-std=c11",
            "-D_GNU_SOURCE",
        }) catch unreachable;
    }

    const qjs_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    qjs_mod.addIncludePath(b.path("quickjs"));
    qjs_mod.addCSourceFiles(.{
        .files = &.{
            "quickjs/cutils.c",
            "quickjs/libregexp.c",
            "quickjs/libunicode.c",
            "quickjs/dtoa.c",
            "quickjs/quickjs.c",
            "quickjs/quickjs-libc.c",
        },
        .flags = c_flags.items,
    });
    const qjs_lib = b.addLibrary(.{
        .name = "quickjs",
        .root_module = qjs_mod,
        .linkage = .static,
    });
    qjs_lib.linkLibC();

    // Install the static library to zig-out/lib
    b.installArtifact(qjs_lib);

    // Build a wrapper static library (libzjs.a) exposing js_app_* helpers
    const wrapper_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    wrapper_mod.addIncludePath(b.path("quickjs"));
    wrapper_mod.addIncludePath(b.path("src"));
    wrapper_mod.addCSourceFiles(.{
        .files = &.{
            "src/wrapper.c",
            "src/zquickjs.c",
        },
        .flags = c_flags.items,
    });
    const wrapper_lib = b.addLibrary(.{
        .name = "zig-quickjs",
        .root_module = wrapper_mod,
        .linkage = .static,
    });
    wrapper_lib.linkLibC();
    wrapper_lib.linkLibrary(qjs_lib);
    b.installArtifact(wrapper_lib);

    // Make the C header available to dependents
    b.installFile("src/wrapper.h", "include/wrapper.h");
}
