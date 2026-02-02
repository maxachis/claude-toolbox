# Documentation Commands

Commands for code documentation and explanation.

## Commands

| Command | Description |
|---------|-------------|
| `doc` | Generate or update documentation |
| `explain` | Explain how code works |

## Usage

```bash
# Generate docs for a file
/doc src/services/auth.ts

# Generate docs for a function
/doc validateUserInput

# Explain a file
/explain src/utils/parser.ts

# Explain a concept
/explain how the caching layer works
```

## Installation

```bash
# Install all documentation commands
cp commands/documentation/*.md ~/.claude/commands/

# Install a single command
cp commands/documentation/explain.md ~/.claude/commands/
```

## Documentation Formats

The `doc` command generates documentation matching your project's existing style:

- JSDoc (JavaScript/TypeScript)
- Docstrings (Python)
- GoDoc (Go)
- Javadoc (Java)
- XML comments (C#)
- And others
