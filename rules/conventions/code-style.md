# Code Style Convention

## General Principles

- Write clear, readable code
- Prefer explicit over implicit
- Keep functions small and focused
- Use meaningful names

## Naming

### Variables and Functions
- Use descriptive names: `userEmail` not `e`
- Boolean variables: `isActive`, `hasPermission`, `canEdit`
- Functions: verb + noun: `getUserById`, `validateEmail`

### Constants
- SCREAMING_SNAKE_CASE: `MAX_RETRY_COUNT`
- Or camelCase for complex objects: `defaultConfig`

### Classes/Types
- PascalCase: `UserService`, `ApiResponse`

## Functions

- Single responsibility
- Max 20-30 lines when possible
- Max 3-4 parameters
- Return early for guard clauses

## Comments

- Explain why, not what
- Keep comments up to date
- Use JSDoc/docstrings for public APIs
- Remove commented-out code

## Error Handling

- Handle errors at appropriate level
- Use specific exception types
- Provide helpful error messages
- Log with context

## Formatting

- Consistent indentation (2 or 4 spaces)
- Max line length: 80-120 characters
- One statement per line
- Use formatter (Prettier, Black, etc.)
