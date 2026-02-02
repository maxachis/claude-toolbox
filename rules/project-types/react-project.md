# Project Rules

## Overview

This is a React/TypeScript project. Follow these conventions when making changes.

## Code Style

- Use functional components with hooks
- Use TypeScript strict mode
- Use Prettier for formatting
- Use ESLint for linting

## Component Structure

- One component per file
- PascalCase for component files: `UserProfile.tsx`
- camelCase for hooks: `useAuth.ts`
- Colocate styles with components

```
components/
├── Button/
│   ├── Button.tsx
│   ├── Button.styles.ts  # or Button.module.css
│   ├── Button.test.tsx
│   └── index.ts
```

## State Management

- Use `useState` for local state
- Use `useReducer` for complex state
- Use context sparingly for truly global state
- Consider Zustand/Redux for complex apps

## Props

- Define prop types with interfaces
- Use destructuring in function parameters
- Provide default values for optional props
- Document complex props with JSDoc

## Styling

- Use [CSS Modules / Tailwind / styled-components]
- Follow design system tokens
- Mobile-first responsive design
- Support dark mode if applicable

## Testing

- Use React Testing Library
- Test behavior, not implementation
- Use `userEvent` for interactions
- Mock API calls, not components

## Performance

- Use `React.memo` for expensive components
- Use `useMemo` and `useCallback` appropriately
- Lazy load routes and heavy components
- Use virtualization for long lists

## Git

- Use conventional commits
- Keep PRs focused and reviewable
