---
name: go-app-distribution
description: Shipping a Go application to end users — tag-triggered GitHub Releases with cross-compiled binaries and checksums, a check-on-launch update banner against the Releases API, and Windows desktop packaging (embedded icon, version metadata, windowed launch, WebView2, PowerShell installer). Load when setting up releases, versioning, auto-update, or installers for a Go app.
---

# Shipping a Go App

Three jobs, each with its own reference file. Read only the one you need — they are
not loaded with this page.

| Job | Read |
|-----|------|
| Push a `vX.Y.Z` tag and get a GitHub Release with cross-compiled binaries and checksums | [releases.md](releases.md) |
| Tell users on launch that a newer version exists, without a background updater | [update-check.md](update-check.md) |
| Make the binary feel like a real Windows desktop app — icon, version metadata, no console window, installer | [windows-packaging.md](windows-packaging.md) |

They compose in that order: the release pipeline bakes in the version string the
update check compares against, and the Windows packaging step consumes the same
version metadata. Set up releases first.
