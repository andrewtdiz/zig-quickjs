zig-quickjs

Overview
- Minimal Zig build that compiles the QuickJS C sources as a static library.
- Small C wrapper (`src/wrapper.h` / `src/wrapper.c`) exposing a simple runtime API, with a generated Zig binding (`src/quickjs.zig`).

Prerequisites
- Zig 0.16.0 (or compatible dev build noted in `build.zig.zon`).
- Git submodules checked out (the `quickjs/` directory).

Getting Started
- Fetch submodule: `git submodule update --init --recursive`
- Build library: `zig build`
- Output: `zig-out/lib/libquickjs.a`

Headers and Includes
- QuickJS headers live under `quickjs/` (e.g., `quickjs/quickjs.h`).
- When consuming the static lib from C/C++, add include path `-I quickjs` and link `zig-out/lib/libquickjs.a`.

Wrapper API
- Public header: `src/wrapper.h`
- Implementation: `src/wrapper.c`
- Provides:
  - `js_app_new`, `js_app_free`
  - `js_app_eval_file`, `js_app_eval_module_file`, `js_app_eval_code`
  - `js_app_eval_prelude`, `js_app_eval_prelude_file`
  - `js_app_run_loop`, `js_app_execute_jobs`
  - `js_app_last_exception`
  - `js_app_call_global`

Examples
- `example/simple`: minimal command-line host that executes a script file and processes the QuickJS event loop.
- `example/advanced`: richer demo showing prelude injection, timer aliases, and detailed exception handling.

Regenerating the Zig Binding
- The Zig binding (`src/quickjs.zig`) is generated from the C wrapper header via translate-c.
- Update it after changing `src/wrapper.h`:

  zig translate-c ./src/wrapper.h > ./src/quickjs.zig

Notes
- The current `build.zig` installs only the QuickJS static library. If you want the wrapper compiled and installed as a separate static lib, we can extend the build to produce and install `libzjs.a` and copy `src/wrapper.h` into `zig-out/include`.
- The wrapper uses `quickjs-libc` helpers for convenience (module loader, std/OS modules). If you need a custom host environment without these helpers, the wrapper can be adapted accordingly.
- Consumers can inject additional globals before running user scripts by calling `js_app_eval_prelude`/`js_app_eval_prelude_file` (see `example/demo.zig` for a quick alias of `setTimeout`/`setInterval`).
