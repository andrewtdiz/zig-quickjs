# zig-quickjs

A minimal Zig libary for adding QuickJS as a static library. Supports Windows and Linux.

## Quick Start

### Prerequisites

- Zig 0.16.0 (or compatible version in `build.zig.zon`)
- Git (for submodule management)

### Setup and Build

```bash
git clone --recurse-submodules https://github.com/andrewtdiz/zig-quickjs
cd zig-quickjs
zig build
```

Add as a dependency to `build.zig.zon`

```zig
.dependencies = .{
    .quickjs = .{
        .path = "./zig-quickjs", // Path to zig-quickjs
    },
},
```

In your `build.zig`, add the following:

```diff
+ const dep = b.dependency("quickjs", .{});
+
const root_mod = b.createModule(.{
     .root_source_file = b.path("main.zig"),
     .target = target,
     .optimize = optimize,
+    .imports = &.{
+         .{ .name = "quickjs", .module = dep.module("quickjs") },
+     },
});
+
+ exe.linkLibrary(dep.artifact("zig-quickjs"));
+ exe.linkLibC();
```

## Project Structure

### Core Files

- **`src/wrapper.h`** / **`src/wrapper.c`** - Simple C API wrapper
- **`src/root.zig`** - Main Zig module
- **`quickjs/`** - QuickJS source (Git submodule)
- **`zig-out/lib/libquickjs.a`** - Vanilla QuickJS static library
- **`zig-out/lib/libzjs.a`** - Wrapper static library (links `libquickjs`)
- **`zig-out/include/wrapper.h`** - Installed wrapper header

### Examples

- **`example/simple/`** - Basic command-line host
- **`example/advanced/`** - Demo with timers and prelude injection

## Wrapper API

The C wrapper provides these functions:

- `js_app_new()`, `js_app_free()` - Create/destroy runtime
- `js_app_eval_code()` - Execute JavaScript code
- `js_app_eval_file()` - Execute JavaScript file
- `js_app_eval_module_file()` - Execute as ES module
- `js_app_eval_prelude()`, `js_app_eval_prelude_file()` - Inject setup code
- `js_app_run_loop()` - Process event loop
- `js_app_execute_jobs()` - Run pending jobs
- `js_app_last_exception()` - Get error details
- `js_app_call_global()` - Call global functions

## Contributing

### From C/C++

1. Include the installed header: `#include "wrapper.h"`
2. Add include paths: `-I zig-out/include` (and `-I quickjs` if you need the raw QuickJS headers)
3. Link: `zig-out/lib/libzjs.a` (automatically pulls in `libquickjs.a`)

### Regenerating Zig Bindings

After modifying `src/wrapper.h`, regenerate:

```bash
zig translate-c ./src/wrapper.h > ./src/quickjs.zig
```

## Notes

- The wrapper uses `quickjs-libc` for built-in modules (std, OS)
- Inject custom globals via `js_app_eval_prelude()` before running scripts
- For custom environments, the wrapper can be adapted
