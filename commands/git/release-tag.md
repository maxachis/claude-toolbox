---
description: Cut a new semver release tag and push it to trigger the release workflow
argument-hint: "[major|minor|patch|<explicit vX.Y.Z>]"
---

# Release Tag

Cut a new semver-tagged release. Assumes a `release.yml` workflow that fires on `v*` tag pushes (see `skills/practices/go-github-releases.md`).

## Arguments

- `$ARGUMENTS` — optional bump type (`major`, `minor`, `patch`, default `patch`) or an explicit version (`v1.4.0`)

## Instructions

1. **Verify clean state.** Run in parallel:
   - `git status` (not `-uall`) — must be clean, or stop and ask the user
   - `git rev-parse --abbrev-ref HEAD` — warn if not on the main branch
   - `git fetch --tags origin` — make sure we have the latest remote tags
   - `git log @{u}..HEAD --oneline` — warn if there are unpushed commits; `git log HEAD..@{u} --oneline` — stop if the branch is behind

2. **Determine the next version.**
   - Run `git describe --tags --abbrev=0` to find the last tag (fallback to `v0.0.0` if none).
   - If `$ARGUMENTS` is an explicit `vX.Y.Z`, use it. Validate it's greater than the last tag.
   - Otherwise bump according to `$ARGUMENTS` (default `patch`).
   - Show the user: last tag → proposed new tag, plus `git log <last-tag>..HEAD --oneline` so they can sanity-check what's included.

3. **Confirm.** Ask the user to approve the tag name before proceeding. Tagging is push-able but rewriting a pushed tag is nasty — get explicit confirmation.

4. **Create and push the annotated tag.**
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```
   Use an annotated tag (`-a`), not lightweight — annotated tags carry author/date metadata and show up properly in release notes.

5. **Watch the workflow.** If `gh` is available:
   ```bash
   gh run watch $(gh run list --workflow=release.yml --limit=1 --json databaseId -q '.[0].databaseId')
   ```
   Otherwise print the Actions URL: `https://github.com/<owner>/<repo>/actions`.

6. **Report.** When the run finishes, print the release URL: `gh release view vX.Y.Z --web` or construct `https://github.com/<owner>/<repo>/releases/tag/vX.Y.Z`.

## Safety

- **Never force-push a tag.** If you tagged the wrong commit, delete locally (`git tag -d`) and remotely (`git push origin :refs/tags/vX.Y.Z`) only after confirming no release artifacts exist yet. If artifacts were already published, bump to the next patch instead.
- **Never skip the confirmation step.** A bad tag push triggers CI, creates a real release, and emails subscribers — it's visible to the outside world.
- **Check for a clean tree before tagging.** Uncommitted changes won't be in the release but they'll confuse `git describe` in future local builds.
