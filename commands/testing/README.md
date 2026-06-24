# Testing Commands

Commands for testing and debugging.

## Commands

| Command | Description |
|---------|-------------|
| `test` | Generate tests for code |
| `test-audit` | Audit existing tests for coverage gaps |
| `debug` | Diagnose and fix bugs |

## Usage

```bash
# Generate tests for a file
/test src/utils/validation.ts

# Generate tests for a function
/test validateEmail

# Audit existing tests for gaps, then optionally fill them
/test-audit src/utils/validation.ts

# Debug an issue
/debug "TypeError: Cannot read property 'id' of undefined"

# Debug with context
/debug users are not being saved to the database
```

## Installation

```bash
# Install all testing commands
cp commands/testing/*.md ~/.claude/commands/

# Install a single command
cp commands/testing/test.md ~/.claude/commands/
```

## Supported Test Frameworks

- Jest / Vitest (JavaScript/TypeScript)
- pytest (Python)
- Go testing
- JUnit (Java)
- RSpec (Ruby)
- And others based on project detection
