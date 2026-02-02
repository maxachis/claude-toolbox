# Commit Message Convention

## Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Formatting, no code change
- `refactor` - Code change that neither fixes a bug nor adds a feature
- `perf` - Performance improvement
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

## Rules

- Subject line max 72 characters
- Use imperative mood: "add" not "added"
- Don't end subject with period
- Separate subject from body with blank line
- Body should explain what and why, not how

## Examples

```
feat(auth): add OAuth2 login with Google

Implement Google OAuth2 flow using passport.js.
Users can now sign in with their Google accounts.

Closes #123
```

```
fix(api): handle null user in profile endpoint

Return 404 instead of 500 when user doesn't exist.
```

```
refactor(database): extract query builders

Move complex queries to dedicated builder classes
for better testability and reuse.
```
