# Wails Best Practices

Wails builds cross-platform desktop apps with a Go backend and a web frontend (any framework or vanilla JS), communicating over an IPC bridge into a native webview.

## Version Awareness

- **v2** is stable and production-ready
- **v3 is alpha** (`v3.0.0-alpha.*`) — APIs, IPC globals, and generated bindings change between alpha releases. Treat every upgrade as potentially breaking.
- Always check which major version the project uses before writing code against Wails APIs — they differ significantly.

## IPC Detection (v3 alpha gotcha)

In Wails v3 alpha, `window.wails` and `window.__wails_invoke__` are **not** set. Code that detects "am I running in Wails?" by checking these globals will always get `false` and silently fall through to any HTTP fallback you wrote.

Detect the native webview bridge directly instead:

```js
const isWails =
  !!window.chrome?.webview?.postMessage ||        // Windows (Edge WebView2)
  !!window.webkit?.messageHandlers?.external?.postMessage || // macOS/Linux (WKWebView / webkit2gtk)
  !!window.wails?.invoke;                          // v2 fallback
```

If your frontend has both an IPC path and an HTTP-fetch path, verify which branch is actually executing — asset-server logs showing `/api/*` requests mean you fell into HTTP mode when you shouldn't have.

## Dual-Mode Apps (IPC + HTTP Fallback)

A common pattern: run as a desktop app normally, but also support `--browser` mode that serves the same frontend over HTTP. This is useful for debugging and for environments where native webviews are broken.

- Expose a unified `API` object on the frontend that wraps either IPC calls or `fetch`
- Make detection the *only* place mode matters; everything downstream uses `API.method()`
- Don't forget to register HTTP handlers *only* in browser mode — calling them from desktop mode means detection broke

## Linux: webkit2gtk Gotchas

webkit2gtk (the Linux backend) has two issues that cause silent launch failures:

### 1. Snap environment variable leakage

If the binary is launched from a snap-wrapped shell (VSCode's integrated terminal is the common culprit), the environment leaks `GIO_MODULE_DIR`, `GTK_PATH`, `GTK_IM_MODULE_FILE`, `GTK_MODULES`, `GSETTINGS_SCHEMA_DIR`, `LOCPATH`, `XDG_DATA_HOME`, `XDG_DATA_DIRS` pointing into `/snap/code/...`. webkit2gtk `dlopen`s modules from those paths, which were built against an older glibc, and you get:

```
symbol lookup error: /snap/core20/.../libpthread.so.0: undefined symbol: __libc_pthread_init, version GLIBC_PRIVATE
```

**This is not a build problem.** `ldd` and `readelf` will show clean linkage — the failure is at runtime dlopen. Fix by unsetting these variables in `main.go` before `application.New`:

```go
if runtime.GOOS == "linux" {
    for _, v := range []string{
        "GIO_MODULE_DIR", "GTK_PATH", "GTK_IM_MODULE_FILE", "GTK_MODULES",
        "GSETTINGS_SCHEMA_DIR", "LOCPATH", "XDG_DATA_HOME", "XDG_DATA_DIRS",
    } {
        os.Unsetenv(v)
    }
}
```

### 2. DMA-BUF renderer blank window

Even with clean env vars, some webkit2gtk builds render a pure-white window. Assets load (you'll see them in the asset server log) but layout never runs. Workaround:

```go
os.Setenv("WEBKIT_DISABLE_DMABUF_RENDERER", "1")
```

If that doesn't fix it, try `WEBKIT_DISABLE_COMPOSITING_MODE=1`. Do not waste time chasing JSC/SIGUSR1 log noise — `NeedDebuggerBreak` and "Overriding existing handler for signal 10" are benign.

## Database Location

Never use a relative path for the app database. Wails apps can be launched from unpredictable working directories (Program Files, app bundles, system-started launchers). Use `os.UserConfigDir()`:

```go
configDir, _ := os.UserConfigDir()
dbPath := filepath.Join(configDir, "myapp", "app.db")
os.MkdirAll(filepath.Dir(dbPath), 0755)
```

## Silent Frontend Errors

IPC errors are easy to swallow. A `try/catch` with only `console.error` means users see nothing when things fail — modals stay open, buttons do nothing, and debugging requires opening devtools. Always surface errors to the UI, even if it's just a toast or an alert.

## Generated Bindings

Wails auto-generates TypeScript/JS bindings for your Go methods into `frontend/bindings/`. **Never edit these by hand** — they're regenerated on every build. If you need to adapt the shape, wrap them in your own layer.

## Dev Loop

- `wails dev` (v2) / `wails3 dev` (v3) — hot reload for both Go and frontend
- Frontend changes hot-reload instantly; Go changes require a rebuild (automatic in dev mode)
- If hot reload silently stops working, kill and restart — it's an alpha quirk
