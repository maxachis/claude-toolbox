# Go: Windows Desktop Packaging

Shipping a Go app as a real Windows desktop experience — embedded icon, version metadata, windowed (not console) launch, optional WebView2 wrapper, PowerShell installer.

## When to use

- Go app aimed at non-technical Windows users
- Single `.exe`, no MSI/NSIS wrapper wanted
- Backend is a local HTTP server + browser or WebView2 front end

## The five pieces

### 1. Icon: SVG → multi-size ICO

Keep one `assets/icon.svg`, render it to an ICO at build time:

```bash
for size in 16 24 32 48 64 128 256; do
  rsvg-convert -w $size -h $size assets/icon.svg -o build/png/icon-$size.png
done
convert build/png/icon-{16,24,32,48,64,128,256}.png assets/icon.ico
```

Requires `librsvg2-bin` and `imagemagick` (install via `apt` in CI or locally).

### 2. Embedded version info

`versioninfo.json` drives what Windows Explorer shows in the "Details" tab:

```json
{
  "FixedFileInfo": { "FileVersion": { "Major": 0, "Minor": 1, "Patch": 0, "Build": 0 } },
  "StringFileInfo": {
    "CompanyName": "Your Name",
    "ProductName": "MyApp",
    "FileDescription": "MyApp — short tagline",
    "LegalCopyright": "© 2026 Your Name"
  },
  "IconPath": "assets/icon.ico"
}
```

Generate the `.syso` resource file Go will link:

```bash
go install github.com/josephspurrier/goversioninfo/cmd/goversioninfo@latest
"$(go env GOPATH)/bin/goversioninfo" -platform-specific versioninfo.json
```

This writes `resource_windows_amd64.syso` (and other arches) into the module root. Commit them or regenerate every build — regenerating is cleaner.

### 3. Windowed build flags

```bash
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 \
  go build -trimpath \
    -ldflags "-s -w -H=windowsgui -X main.version=$VERSION" \
    -o dist/myapp-windows-amd64.exe .
```

- `-H=windowsgui`: **critical** — without this, every launch spawns a console window behind the app. With it, the exe is a GUI subsystem binary and runs silently.
- `CGO_ENABLED=0`: lets you cross-compile from Linux/macOS.

### 4. WebView2 shell (optional)

Use `github.com/jchv/go-webview2` to wrap the local HTTP server in a native Chromium window instead of opening the system browser. Build-tag it so non-Windows builds still compile:

```go
// ui_windows.go
//go:build windows
package main
import "github.com/jchv/go-webview2"
func runUI(url string) {
    w := webview2.NewWithOptions(webview2.WebViewOptions{ /* ... */ })
    defer w.Destroy()
    w.Navigate(url); w.Run()
}

// ui_other.go
//go:build !windows
package main
import "github.com/pkg/browser"
func runUI(url string) { browser.OpenURL(url); select {} }
```

WebView2 runtime ships with Windows 11 and is auto-installed on 10. No extra dependency for end users.

### 5. PowerShell installer

`scripts/install-windows.ps1` — one-liner install via `iwr | iex`:

```powershell
param(
  [string]$Repo       = "owner/app",
  [string]$Version    = "latest",
  [string]$Asset      = "myapp-windows-amd64.exe",
  [string]$InstallDir = "$env:LOCALAPPDATA\Programs\MyApp",
  [switch]$Uninstall
)
# Resolve URL: releases/latest/download/$Asset or releases/download/$Version/$Asset
# Stop running process, download via curl.exe (fallback to HttpClient),
# create Start Menu + Desktop shortcuts via WScript.Shell COM.
```

Key details:

- **Install to `%LOCALAPPDATA%\Programs\`**, not `Program Files` — avoids UAC elevation, matches VS Code / GitHub Desktop convention.
- **Force TLS 1.2** for old PowerShell hosts: `[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12`.
- **Prefer `curl.exe`** over `Invoke-WebRequest` — faster and dodges `iwr`'s progress-bar bug with large files.
- **Shortcut icons**: `$sc.IconLocation = $ExePath` pulls from the embedded ICO resource.
- **Leave user data alone on uninstall**: remove `$InstallDir` but not `$env:USERPROFILE\.myapp`.
- **Stop running process first**: `Get-Process -Name myapp | Stop-Process -Force` before overwriting the exe, otherwise the copy fails.

## SmartScreen reality check

Unsigned binaries will trigger "Windows protected your PC" on first launch. Options:

- **Do nothing + document**: users click "More info → Run anyway". Acceptable for personal projects.
- **Azure Trusted Signing** (~$10/mo): real cert, SmartScreen reputation builds over weeks.
- **EV code-signing cert** (~$300–600/yr): instant SmartScreen trust.
- **Ship via winget**: sidesteps SmartScreen entirely — see `desktop-distribution.md`.

## CI hookup

In the GitHub Actions release workflow, install the icon tooling and run `goversioninfo` before `go build`:

```yaml
- run: |
    sudo apt-get install -y librsvg2-bin imagemagick
    # render ICO (see §1)
    go install github.com/josephspurrier/goversioninfo/cmd/goversioninfo@latest
    "$(go env GOPATH)/bin/goversioninfo" -platform-specific versioninfo.json
- run: |
    CGO_ENABLED=0 GOOS=windows GOARCH=amd64 \
      go build -trimpath -ldflags "-s -w -H=windowsgui -X main.version=${GITHUB_REF_NAME}" \
      -o dist/myapp-windows-amd64.exe .
```

## Common gotchas

- **Console window flashes on launch**: forgot `-H=windowsgui`.
- **Generic default icon**: `.syso` wasn't regenerated, or `assets/icon.ico` is missing/corrupt. Delete `.syso`, re-run `goversioninfo`, rebuild.
- **"Unknown publisher" dialog**: expected — that's SmartScreen for unsigned code.
- **Can't overwrite running exe on upgrade**: stop the process first, or rename-in-place (`MoveFileEx`).
- **WebView2 missing on old Windows 10**: bundle or install the evergreen runtime; in practice >99% of active W10 machines already have it.
