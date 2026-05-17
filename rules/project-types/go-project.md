# Project Rules

## Overview

This is a Go project. Follow these conventions when making changes.

## Code Style

- Format with `gofmt` / `goimports` — never hand-format
- Use `golangci-lint` for linting; address warnings rather than silencing
- Package names: short, lowercase, no underscores (`conversion`, not `conversion_service`)
- Exported identifiers: `CamelCase`; unexported: `camelCase`
- Keep functions focused; prefer many small packages over one large `util`
- Wrap errors with context: `fmt.Errorf("load config: %w", err)`

## Project Structure

```
cmd/
├── <appname>/        # main package(s), one per binary
internal/             # private packages, not importable externally
├── service/          # business logic
├── store/            # database / persistence
└── httpapi/          # HTTP handlers
pkg/                  # (optional) libraries intended for external import
go.mod
go.sum
```

For small projects (single binary, <2000 LOC), a flat layout with `main.go` + topic-named files (`db.go`, `handlers.go`, `service.go`) is preferable to forced `cmd/`/`internal/` nesting.

## Testing

- Tests live beside source in `*_test.go` files
- Use table-driven tests with `t.Run` subtests for clarity
- Test files in `package foo` (white-box) unless you specifically need `package foo_test` (black-box)
- Use `t.TempDir()` for filesystem fixtures — never hardcode `/tmp` paths
- Prefer real dependencies over mocks when cheap (e.g. in-memory SQLite over a mocked DB interface)
- Run with `go test ./...` from project root

## Dependencies

- Manage via `go.mod`; run `go mod tidy` before committing
- Pin to specific versions; avoid `latest` in imports
- Prefer standard library first, then well-maintained third-party
- For SQLite, prefer `modernc.org/sqlite` (pure Go, no CGo) unless you specifically need the C driver

## Error Handling

- Return errors, don't panic (except at startup for unrecoverable config)
- Wrap with `%w` so callers can `errors.Is` / `errors.As`
- Never ignore errors silently — if truly safe, comment *why*: `_ = f.Close() // best-effort cleanup`
- Don't log and return the same error; pick one layer to handle it

## Cross-Platform Paths

- **Never hardcode relative paths for user data.** Use `os.UserConfigDir()` for config, `os.UserCacheDir()` for caches, `os.TempDir()` for scratch.
- Use `filepath.Join` rather than string concatenation with `/`
- Gate OS-specific logic on `runtime.GOOS` in dedicated `_linux.go` / `_windows.go` files when it grows beyond a few branches

## Build

- `go build ./...` to verify all packages compile
- `go vet ./...` catches common bugs the compiler misses
- Cross-compile via `GOOS` / `GOARCH` env vars — no toolchain reinstall needed
- Avoid CGo unless unavoidable; it complicates cross-compilation and static linking

## Git

- Use conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`
- Keep commits focused; one logical change per commit
- Don't commit `go.sum` conflicts unresolved — run `go mod tidy`
