# QuickJS Zig Binding Review

## Findings
- **High** – `JS_ExecutePendingJob` exceptions are dropped: the loop exits on `ret < 0` and returns the positive job count, so callers never learn that a job threw and the pending exception remains (`src/wrapper.c:154`). Capture the negative return, fetch/dump the exception, and propagate an error code (and/or surface it through `js_app_last_exception`).
- **High** – Several helper calls ignore the `JS_EXCEPTION` sentinel: `JS_GetPropertyStr` may trigger a throwing getter yet the result is treated as normal, and `JS_NewString` failures feed directly into `JS_Call` (`src/wrapper.c:183`, `src/wrapper.c:201`). Both need `JS_IsException` checks with cleanup.
- **High** – The translated binding in `src/quickjs.zig` is currently uncompilable because numerous top-level constants evaluate to `@compileError(...)` (for example `__seg_gs`, `__UINT32_C_SUFFIX__`). Simply importing the module fails; the auto-generated header needs pruning or hand-written replacements.
- **Medium** – `format_exception` assumes `.stack` retrieval succeeds; if `JS_GetPropertyStr` throws, `JS_ToCStringLen` observes `JS_EXCEPTION` (`src/wrapper.c:73`). Guard with `JS_IsException(msg)` and fall back to duplicating the original exception value.
- **Medium** – Module evaluation never calls `js_module_set_import_meta`, so `import.meta` behaves incorrectly compared to the QuickJS CLI (`src/wrapper.c:115`, `src/wrapper.c:128`). Adding the helper keeps parity.
- **Low** – `js_app_run_loop` fetches an exception that `js_std_dump_error` already consumed and discards the returned value (`src/wrapper.c:145`). Either drop the extra `JS_GetException` or free the value to avoid confusion.

## Questions / Assumptions
- Should the wrapper remain the only surface area, or should Zig users be able to reach the full QuickJS API? As written, `quickjs.zig` exposes only the small wrapper API and still references the raw C headers elsewhere in the repo.

## Context
The C wrapper’s structure is generally sound—runtime and context lifetimes pair up, helpers are initialised once, allocations are freed on failure—but the missing exception guards and job-loop handling will bite as soon as user code throws inside getters, argument coercion fails, or a promise rejects. Module evaluation also needs the usual QuickJS boilerplate to feel complete. On the Zig side the auto-generated file needs cleanup before it can compile, and it currently doesn’t map through the broader QuickJS surface (no host function registration, value manipulation, memory limits, etc.), so “full QuickJS support” isn’t there yet.

## Recommendations for Engine Embedding
1. Fix the exception-handling issues above, then wrap `js_app_execute_jobs` / `js_app_run_loop` with engine-friendly scheduling so you can pump the JS job queue once per frame instead of blocking inside `js_std_loop`.
2. Expose a safe API for registering native callbacks or events; without it there’s no way to drive gameplay objects from JS.
3. Consider a thin Zig layer around `JSValue` (via `@cImport` or curated bindings) for performance-sensitive code, and decide upfront how contexts will behave across threads.
4. Guard memory usage (`JS_SetMemoryLimit`, `JS_SetMaxStackSize`) to keep scripts from exhausting the engine, and route promise rejections to the engine’s logging/error system.

Once the binding compiles cleanly and surfaces these lifecycle hooks, it will provide a solid foundation; until then expect surprises when user scripts exercise the missing cases.
