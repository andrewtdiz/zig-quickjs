#ifndef JS_WRAPPER_H
#define JS_WRAPPER_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct js_app js_app;

// Lifecycle
js_app* js_app_new(int width, int height);
void js_app_free(js_app* app);

// Evaluation helpers
// Evaluate a file as a classic script (same as old js_app_eval_file)
int js_app_eval_file(js_app* app, const char* path);
// Evaluate a file explicitly as an ES module
int js_app_eval_module_file(js_app* app, const char* path);
// Evaluate an in-memory string, choose module mode with is_module != 0
int js_app_eval_code(js_app* app, const char* code, const char* filename, int is_module);
// Evaluate code intended as a preload/prelude step before running user scripts.
// Behaves the same as js_app_eval_code but gives consumers a named API for clarity.
int js_app_eval_prelude(js_app* app, const char* code, const char* filename, int is_module);
// Evaluate a file as a preload; if is_module != 0 the file is parsed as an ES module.
int js_app_eval_prelude_file(js_app* app, const char* path, int is_module);

// Event loop helpers
// Run libqjs std event loop (blocking)
void js_app_run_loop(js_app* app);
// Execute pending jobs; if max_jobs <= 0, run until queue empty.
// Returns number of executed jobs, or -1 on error.
int js_app_execute_jobs(js_app* app, int max_jobs);

// Exceptions
// If the last operation threw, formats the exception to a string.
// Returns 0 on success and writes a NUL-terminated string to out_buf.
// Returns -1 if no exception is present.
int js_app_last_exception(js_app* app, char* out_buf, size_t out_buf_len);
void* js_app_get_context(js_app* app);

// Call into JS
// Call a global function by name with string arguments. The result is
// converted to string and written into out_buf (NUL-terminated).
// Returns 0 on success, -1 on error (check js_app_last_exception).
int js_app_call_global(js_app* app,
                       const char* func_name,
                       const char* const* argv,
                       int argc,
                       char* out_buf,
                       size_t out_buf_len);

#ifdef __cplusplus
}
#endif

#endif // JS_WRAPPER_H
