# Create Pull Request

Create a pull request for the current branch.

## Arguments

- `$ARGUMENTS` - Optional: base branch (defaults to main/master)

## Instructions

1. Check current branch and ensure it's not main/master
2. Run `git log` to see commits since branching from base
3. Run `git diff <base>...HEAD` to see all changes
4. Create a PR with:
   - **Title**: Brief, descriptive (under 70 chars)
   - **Summary**: Bullet points of what changed and why
   - **Test plan**: How to verify the changes work
5. Use `gh pr create` to create the PR
6. Return the PR URL
