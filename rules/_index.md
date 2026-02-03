# Rules Index

CLAUDE.md templates and rule snippets for project-specific instructions.

## Categories

### [Project Types](project-types/)
Complete CLAUDE.md templates for different project types.
- Python projects
- TypeScript/Node projects
- React applications
- Vue applications

### [Conventions](conventions/)
Reusable rule snippets for common conventions.
- Commit message format
- Code style guidelines
- Documentation standards

## What Are Rules?

Rules tell Claude how to behave in your project. They're defined in:
- `CLAUDE.md` in project root (main rules file)
- `.claude/rules/` directory (additional rule files)

## Installation

### Project Root

Copy a template to your project root:

```bash
cp rules/project-types/python-project.md ./CLAUDE.md
```

### Multiple Rule Files

Use the rules directory for modular rules:

```bash
mkdir -p .claude/rules
cp rules/conventions/commit-messages.md .claude/rules/
cp rules/conventions/code-style.md .claude/rules/
```

## Creating Rules

Rules are markdown files with instructions for Claude:

```markdown
# Project Rules

## Code Style
- Use 2-space indentation
- Prefer async/await

## Testing
- All PRs require tests
- Use fixtures for test data
```

Keep rules focused and actionable. Claude reads these automatically when working in your project.
