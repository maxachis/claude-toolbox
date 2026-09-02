---
description: Create a pull request for the current branch
argument-hint: "<base branch>"
---

# Create Pull Request

Create a pull request for the current branch.

## Arguments

- `$ARGUMENTS` - Optional: base branch (defaults to main/master)

## Instructions

0. **Get the user's go-ahead before creating the PR.** Opening a PR starts required checks and requests review, so it is the user's call, not yours — every time, regardless of how small the change is. Do the prep below, show them the diffstat and the title and body you intend to use, and wait for an explicit OK before step 5. Committing and pushing the branch beforehand is fine and does not need asking; a draft PR is the same outward-facing action and does not satisfy this.

1. Check current branch and ensure it's not main/master
2. Run `git log` to see commits since branching from base
3. Run `git diff <base>...HEAD` to see all changes
4. Create a PR with:
   - **Title**: Brief, descriptive (under 70 chars)
   - **Summary**: Bullet points of what changed and why
   - **Test plan**: How to verify the changes work
5. Use `gh pr create` to create the PR
6. Return the PR URL
