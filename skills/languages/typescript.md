# TypeScript Best Practices

## Code Style

- Use strict TypeScript configuration
- Prefer `const` over `let`, avoid `var`
- Use explicit return types on functions
- Prefer interfaces over type aliases for object shapes
- Use enums sparingly; prefer union types

## Types

- Avoid `any`; use `unknown` when type is truly unknown
- Use utility types: `Partial<T>`, `Pick<T>`, `Omit<T>`, `Record<K,V>`
- Define types close to where they're used
- Export types that are part of the public API

## Naming Conventions

- PascalCase for types, interfaces, classes, enums
- camelCase for variables, functions, methods
- SCREAMING_SNAKE_CASE for constants
- Prefix interfaces with `I` only if project convention requires it

## Functions

- Use arrow functions for callbacks
- Use regular functions for methods and hoisted functions
- Prefer async/await over raw Promises
- Handle errors with try/catch or `.catch()`

## Null Handling

- Enable `strictNullChecks`
- Use optional chaining: `obj?.property`
- Use nullish coalescing: `value ?? default`
- Prefer `undefined` over `null` for optional values

## Modules

- Use ES modules (import/export)
- One class/function per file for larger items
- Use barrel exports (index.ts) for public API
- Avoid circular dependencies
