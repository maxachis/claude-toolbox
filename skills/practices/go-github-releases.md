# Go: GitHub Releases Workflow

Tag-triggered release pipeline for Go apps. Push `vX.Y.Z`, get a GitHub Release with cross-compiled binaries and checksums.

## When to use

- Single-binary Go apps (CLIs, desktop apps, small services)
- You want users to download from `github.com/<owner>/<repo>/releases`
- No need for package managers (those layer on top — see `go-update-check.md` and `desktop-distribution.md`)

## Pipeline shape

`.github/workflows/release.yml`:

```yaml
name: release
on:
  push:
    tags: ["v*"]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: "1.26"

      - run: go mod tidy

      - name: Build
        run: |
          mkdir -p dist
          CGO_ENABLED=0 GOOS=windows GOARCH=amd64 \
            go build -trimpath \
              -ldflags "-s -w -X main.version=${GITHUB_REF_NAME}" \
              -o dist/myapp-windows-amd64.exe .
          # Repeat per target: linux/amd64, darwin/amd64, darwin/arm64…

      - name: Checksums
        run: (cd dist && sha256sum * > SHA256SUMS.txt)

      - uses: softprops/action-gh-release@v2
        if: startsWith(github.ref, 'refs/tags/')
        with:
          files: |
            dist/*
          generate_release_notes: true
```

## Key conventions

- **Version injection**: `var version = "dev"` in `main.go`, overridden via `-X main.version=$TAG`. The `dev` default lets local builds identify themselves and lets update-checkers skip.
- **`-trimpath`**: strips local filesystem paths from the binary — reproducible-ish builds.
- **`-s -w`**: strip debug/symbol tables, ~25% smaller binary.
- **`CGO_ENABLED=0`**: pure-Go cross-compilation, no toolchain per target. If you need CGo (e.g. `mattn/go-sqlite3`), use `modernc.org/sqlite` instead, or add a matrix with per-OS runners.
- **Asset naming**: `<app>-<goos>-<goarch><ext>` — predictable URLs make installers and update-checkers easy.
- **SHA256SUMS.txt**: one file, one line per artifact. Both humans and self-updaters can verify.
- **`generate_release_notes: true`**: auto-populates from PR titles since last tag. Good default; override with `body:` if you want hand-written notes.

## Parallel local script

Mirror the CI build in `scripts/build-<target>.sh` so you can cut a local test binary without pushing a tag. Set `VERSION="${VERSION:-$(git describe --tags --always --dirty)}"` so local builds carry a meaningful version string.

## Cutting a release

See `/release-tag` command. Short version: `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`.

## Common gotchas

- **Tag didn't trigger workflow**: `git push` alone doesn't push tags. Use `git push origin vX.Y.Z` or `git push --follow-tags`.
- **Action can't write releases**: ensure `permissions: contents: write` at the workflow or job level.
- **Wrong version baked in**: `GITHUB_REF_NAME` is only set for tag pushes — for `workflow_dispatch`, fall back to a manual input or `git describe`.
- **No tests run**: this workflow only builds. Keep a separate `ci.yml` on PR/push for tests — a broken tag shouldn't be the first time you find out.
