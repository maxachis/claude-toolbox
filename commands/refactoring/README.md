# Refactoring Commands

Commands for improving code quality.

## Commands

| Command | Description |
|---------|-------------|
| `refactor` | Refactor code to improve quality without changing behavior |

## Usage

```bash
# Refactor a file
/refactor src/services/userService.ts

# Refactor with specific focus
/refactor extract common validation logic in src/api/

# Refactor for clarity
/refactor simplify the conditionals in handlePayment
```

## Installation

```bash
# Install refactoring commands
cp commands/refactoring/*.md ~/.claude/commands/
```

## Refactoring Techniques

The `refactor` command may apply:

- **Extract Method** - Pull repeated code into reusable functions
- **Rename** - Improve naming for clarity
- **Simplify Conditionals** - Reduce nested if/else complexity
- **Apply Patterns** - Use appropriate design patterns
- **Reduce Coupling** - Decrease dependencies between modules
- **Increase Cohesion** - Group related functionality together
