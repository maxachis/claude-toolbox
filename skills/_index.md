# Skills Index

Skills provide background knowledge and context that Claude can draw upon automatically.

## Categories

### [Languages](languages/)
Language-specific knowledge and best practices.
- Python conventions
- TypeScript patterns
- Rust idioms
- And more...

### [Frameworks](frameworks/)
Framework-specific guidance and patterns.
- React best practices
- Django conventions
- FastAPI patterns
- And more...

### [Practices](practices/)
Development practices and methodologies.
- Test-driven development (TDD)
- Code review guidelines
- Git workflow standards

## Installation

Skills are placed in `~/.claude/skills/`:

```bash
# Install all skills
cp -r skills/* ~/.claude/skills/

# Install a single skill
cp skills/languages/python.md ~/.claude/skills/
```

## Creating Skills

Skills are markdown files with domain knowledge:

```markdown
# Python Best Practices

## Code Style
- Follow PEP 8
- Use type hints
- Prefer f-strings

## Project Structure
- Use src/ layout
- Separate tests from source
```

Skills are automatically loaded as context, unlike commands which must be explicitly invoked.
