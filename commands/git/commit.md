# Commit Changes

Generate a commit message and commit staged changes.

## Instructions

1. Run `git status` and `git diff --cached` to see staged changes
2. If nothing is staged, show unstaged changes and ask what to stage
3. Write a concise commit message following conventional commits format:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation
   - `refactor:` for refactoring
   - `test:` for tests
   - `chore:` for maintenance
4. Keep the first line under 72 characters
5. Add a body if the change needs explanation
6. Commit the changes (do not push unless asked)
