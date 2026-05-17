# Go: Check-on-Launch Update Banner

Pattern for Go apps distributed via GitHub Releases: on startup, check the Releases API, compare against the baked-in version, and surface a banner when a newer version is available.

## When to use

- Go app shipped as a binary via GitHub Releases (see `go-github-releases.md`)
- Users install once and run repeatedly (desktop apps, long-running CLIs, tray apps)
- You don't want to implement self-update — just nudge users to reinstall

## Why not auto-apply

- Self-replacing a running exe is platform-specific (Windows needs rename-in-place; Unix is simpler but still touchy).
- Surfacing a banner is ~100 lines and has zero blast radius. Auto-apply has real failure modes.
- Users on package managers (winget, brew, scoop) get updates through those channels — don't duplicate.

## Design

- **Version baked in at build time**: `var version = "dev"` in `main.go`, overridden with `-X main.version=$TAG`. The `"dev"` sentinel short-circuits the checker for local builds.
- **Synchronous initial fetch, bounded by short timeout** (~3s): populates the banner before the first page renders. If GitHub is slow, the goroutine picks it up.
- **Background ticker** (~6h): catches releases published mid-session without hammering the API (GitHub unauthenticated limit is 60 req/hr/IP).
- **RWMutex-protected cached result**: readers (template renders) never block on the network.
- **Strict semver-lite comparison**: strip `v`, split on `.`, compare `[3]int`. Pre-release tags (`v1.2.3-rc1`) will fail to parse and be treated as "no update" — fine for a nudge banner.

## Skeleton

```go
// internal/update/update.go
package update

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"
)

type Checker struct {
	current, repo string
	client        *http.Client
	mu            sync.RWMutex
	latest, url   string
}

func New(current, repo string) *Checker {
	return &Checker{current: current, repo: repo,
		client: &http.Client{Timeout: 10 * time.Second}}
}

func (c *Checker) Start(ctx context.Context) {
	if !versionLooksReal(c.current) || c.repo == "" { return }
	initCtx, cancel := context.WithTimeout(ctx, 3*time.Second)
	c.refresh(initCtx); cancel()
	go func() {
		t := time.NewTicker(6 * time.Hour); defer t.Stop()
		for { select {
			case <-ctx.Done(): return
			case <-t.C: c.refresh(ctx)
		} }
	}()
}

func (c *Checker) Status() (has bool, latest, url string) {
	c.mu.RLock(); defer c.mu.RUnlock()
	if !isNewer(c.current, c.latest) { return false, "", "" }
	return true, c.latest, c.url
}

// refresh hits https://api.github.com/repos/<repo>/releases/latest,
// decodes { tag_name, html_url }, stores under c.mu.Lock().
```

Version comparison (TDD-worthy — covered cases: v-prefix, missing patch, equal versions, dev/empty, non-numeric):

```go
func isNewer(current, latest string) bool {
	c, ok1 := parseVersion(current); l, ok2 := parseVersion(latest)
	if !ok1 || !ok2 { return false }
	for i := 0; i < 3; i++ {
		if l[i] != c[i] { return l[i] > c[i] }
	}
	return false
}
```

## Wiring into a web UI

Put a nullable `Update *UpdateInfo` field on the page struct, populate it from `Checker.Status()` inside the central `render()` helper, and render a banner in the layout template. Keep the banner unintrusive — a dismissible `<div>` with a "Download" link to the release URL.

## Wiring into a CLI

Print a one-line notice on startup (stderr so it doesn't pollute piped stdout):

```go
if has, v, url := checker.Status(); has {
    fmt.Fprintf(os.Stderr, "→ myapp %s available: %s\n", v, url)
}
```

## Important subtleties

- **Cold start cost**: users on the *first* version that contains the checker won't see the banner for that upgrade. They see it on the *next* release. This is inherent — document it or accelerate with a winget/brew manifest.
- **API rate limits**: 60 req/hr/IP unauthenticated. A 6h interval gives plenty of headroom for a single user; a shared office IP with many users might bump into it — fine for a nudge that can fail silently.
- **Private repos**: the `/releases/latest` endpoint needs auth. For a client-side binary you almost certainly don't want to ship a PAT — if the repo is private, use a different distribution channel.
- **Pre-release tags**: `/releases/latest` skips drafts and pre-releases automatically. If you tag `v1.2.3-rc1`, users won't see it.

## Tests worth writing

Just the version comparator. The HTTP layer is thin and integration-testing it against the real API is flaky. Table-driven tests for `isNewer` cover: equal, patch bump, minor bump, major bump, downgrade, `v` prefix vs. bare, 2-segment vs. 3-segment, `dev`, empty, garbage input.
