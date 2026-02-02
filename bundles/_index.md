# Bundles Index

Curated collections of components for specific roles and workflows.

## Available Bundles

| Bundle | Description |
|--------|-------------|
| [fullstack-developer](fullstack-developer/) | Complete toolkit for fullstack web development |
| [backend-api](backend-api/) | Backend API development with security focus |

## What Are Bundles?

Bundles combine multiple components into role-based packages:
- Commands for common tasks
- CLAUDE.md templates with project rules
- Pre-configured for specific workflows

## Installation

```bash
# Copy commands from a bundle
cp -r bundles/fullstack-developer/commands/* ~/.claude/commands/

# Copy project rules
cp bundles/fullstack-developer/CLAUDE.md ./CLAUDE.md
```

## Bundle Contents

### fullstack-developer
- API commands (design, endpoint, test)
- Frontend commands (component, style, a11y)
- Database commands (architect, query)
- Testing commands (test, debug)
- Git commands (commit, pr, review)
- Fullstack project CLAUDE.md

### backend-api
- API commands (design, endpoint, docs, test)
- Database commands (architect, migrate, query)
- Security commands (audit, auth)
- Testing commands (test, debug)
- Git commands (commit, pr, review)
- Backend API project CLAUDE.md

## Creating Bundles

1. Create a directory in `bundles/`
2. Add a `README.md` describing the bundle
3. Add a `CLAUDE.md` with project rules
4. Create `commands/` with selected commands
5. Optionally add other component types
