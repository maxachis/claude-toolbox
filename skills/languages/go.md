# Go Best Practices

## Code Style

- `gofmt` / `goimports` is non-negotiable — all code must be formatted
- Package names: short, lowercase, singular (`user`, not `users` or `user_pkg`)
- Exported names start uppercase; unexported lowercase. Visibility is package-scoped
- Prefer explicit over clever — Go rewards boring code
- Keep interfaces small; define them where they're *used*, not where they're implemented

## Error Handling

- Return `error` as the last value; check immediately at the call site
- Wrap with context using `%w`: `fmt.Errorf("open config %q: %w", path, err)`
- Use `errors.Is` for sentinel errors, `errors.As` for typed errors
- Only panic for genuinely unrecoverable state (e.g. broken invariants at startup)
- `defer` cleanup (close, unlock) right after acquiring the resource

## Concurrency

- Goroutines are cheap but not free — always have a plan for how they exit
- Prefer channels for coordination, mutexes for protecting state
- Use `context.Context` for cancellation and deadlines; pass as first arg
- Never store a `context.Context` in a struct; pass it through calls

## Standard Library First

Go's stdlib is unusually complete. Before reaching for a dependency, check:
- `net/http` — production-capable HTTP server and client
- `encoding/json` — JSON; `json.Decoder` for streams
- `database/sql` — generic DB interface
- `log/slog` — structured logging (Go 1.21+)
- `testing` — test framework; no external runner needed

## SQLite Without CGo

`modernc.org/sqlite` is a pure-Go SQLite port. Use it when:
- You want CGo-free builds (simpler cross-compilation, static binaries)
- You don't need the absolute fastest SQLite performance
- You want `go build` to "just work" on every platform

Import as `_ "modernc.org/sqlite"` and open with `sql.Open("sqlite", path)`. Performance is ~2-3x slower than `mattn/go-sqlite3` (CGo) but acceptable for most desktop / CLI apps.

## Cross-Platform Writable Paths

Never hardcode paths for user data:

```go
configDir, err := os.UserConfigDir()   // e.g. ~/.config on Linux, %AppData% on Windows
cacheDir, err := os.UserCacheDir()     // e.g. ~/.cache on Linux, %LocalAppData%/Cache on Windows
dataDir := filepath.Join(configDir, "myapp")
os.MkdirAll(dataDir, 0755)
```

Relative paths (`./app.db`) break the moment the binary is launched from a different working directory — especially on Windows, where Program Files is write-protected.

## Testing

- Tests live in `*_test.go` beside source; same package for white-box
- Table-driven tests:
  ```go
  for _, tc := range []struct{ name, in, want string }{ ... } {
      t.Run(tc.name, func(t *testing.T) { ... })
  }
  ```
- `t.TempDir()` gives you an auto-cleaned temp directory — use it for DB files, config, etc.
- `t.Helper()` in helper functions so failures report the correct line
- Race detector: `go test -race ./...`

## Build & Tooling

- `go build ./...` — compile everything
- `go vet ./...` — find suspicious constructs
- `go test ./...` — run all tests
- `go mod tidy` — clean up dependencies
- `golangci-lint run` — aggregated linters (recommended)
- Cross-compile: `GOOS=windows GOARCH=amd64 go build` — no toolchain switch needed

## Avoid CGo When Possible

CGo (`import "C"`) gives up Go's biggest wins: fast builds, trivial cross-compilation, static binaries. Only use it when:
- The C library has no pure-Go replacement
- The performance difference is measurably critical

For SQLite, graphics, crypto — pure-Go alternatives exist and are usually good enough.
