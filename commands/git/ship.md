# Ship

Stage, commit, and push changes in one step.

## Arguments

- `$ARGUMENTS` - Optional: `commit` (skip push), or a quoted commit message to use instead of generating one

## Instructions

1. Run `git status` (never use `-uall`), `git diff` (staged + unstaged), and `git log --oneline -5` in parallel to understand the current state.

2. **Check for secrets.** Scan untracked and modified files for probable secrets:
   - Files named `.env`, `.env.*`, `credentials.json`, `*.pem`, `*.key`, `*secret*`
   - Files containing patterns like `API_KEY=`, `SECRET=`, `password`, `token` followed by a literal value
   - If any are found, list them and **stop**. Do not stage or commit until the user confirms.

3. **Stage changes.** Add modified and untracked files by name — never use `git add -A` or `git add .`. Exclude files that:
   - Match `.gitignore` patterns
   - Were flagged as potential secrets in step 2
   - Are large binaries or build artifacts (e.g., `node_modules/`, `dist/`, `*.exe`, `*.dll`)

4. **Generate a commit message** (unless one was provided in `$ARGUMENTS`):
   - Examine `git log --oneline -10` to match the repo's existing commit message style
   - If the repo uses conventional commits, follow that format (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, etc.)
   - First line under 72 characters, focused on **why** not **what**
   - Add a body only if the change spans multiple concerns
   - Always append the trailer: `Co-Authored-By: Claude <noreply@anthropic.com>`

5. **Commit.** Use a HEREDOC to pass the message:
   ```bash
   git commit -m "$(cat <<'EOF'
   message here

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```
   - Always create a **new** commit — never amend unless the user explicitly said to
   - If a pre-commit hook fails, fix the issue, re-stage, and create a new commit (do not use `--no-verify`)

6. **Push** (skip this step if `$ARGUMENTS` is `commit`):
   - Push to the current branch's upstream remote
   - If no upstream is set, use `git push -u origin HEAD`
   - Never force-push. If the push is rejected, stop and explain instead of using `--force`

7. **Report.** Show a short summary:
   - Files committed (count)
   - Commit hash and message (first line)
   - Push status (pushed / skipped / failed)

## Output Format

```
Shipped: <short-hash> <first line of commit message>
  <N> files changed
  Pushed to <remote>/<branch>
```
