# Test-Driven Development (TDD)

## The TDD Cycle

1. **Red** - Write a failing test
2. **Green** - Write minimal code to pass
3. **Refactor** - Improve code while tests pass

## Principles

### Write Tests First
- Think about what you want before how
- Tests document expected behavior
- Forces you to consider edge cases early

### Small Steps
- One test at a time
- One assertion per test (generally)
- Commit after each green phase

### FIRST Properties
- **Fast** - Tests run quickly
- **Independent** - No test depends on another
- **Repeatable** - Same result every time
- **Self-validating** - Pass or fail, no interpretation
- **Timely** - Written before production code

## Test Structure (AAA)

```
Arrange - Set up test data and conditions
Act - Execute the code under test
Assert - Verify the expected outcome
```

## What to Test

- Happy paths (expected usage)
- Edge cases (boundaries, empty inputs)
- Error cases (invalid inputs, failures)
- Business rules and invariants

## What NOT to Test

- Framework/library code
- Simple getters/setters
- Configuration
- Third-party integrations (mock instead)

## Mocking Guidelines

- Mock external dependencies
- Don't mock what you own (test it)
- Keep mocks simple
- Verify interactions when relevant
