# Project Rules

## Overview

This is a TypeScript project. Follow these conventions when making changes.

## Code Style

- Use strict TypeScript configuration
- Prefer `const` over `let`, never use `var`
- Use explicit return types on functions
- Maximum line length: 100 characters
- Use Prettier for formatting

## Types

- Avoid `any`; use `unknown` when type is truly unknown
- Define types in dedicated `.types.ts` files or colocated
- Export types that are part of the public API
- Use utility types: `Partial<T>`, `Pick<T>`, `Omit<T>`

## Project Structure

```
src/
├── index.ts          # Entry point
├── types/            # Shared type definitions
├── utils/            # Utility functions
├── services/         # Business logic
└── api/              # API handlers
tests/
├── setup.ts          # Test configuration
└── *.test.ts         # Test files
```

## Testing

- Use Jest or Vitest for testing
- Name test files `*.test.ts` or `*.spec.ts`
- Colocate tests with source or in `tests/` directory
- Mock external dependencies
- Aim for high coverage on business logic

## Imports

- Use absolute imports with path aliases (`@/utils`)
- Group: external packages, internal modules, relative imports
- Use barrel exports (`index.ts`) for public APIs

## Error Handling

- Use custom error classes extending `Error`
- Type errors appropriately
- Handle async errors with try/catch
- Log errors with context

## Git

- Use conventional commits: `feat:`, `fix:`, `docs:`, etc.
- Keep commits focused on single changes
- Write descriptive commit messages
