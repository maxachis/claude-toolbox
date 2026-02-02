# React Best Practices

## Component Structure

- One component per file
- Use functional components with hooks
- Keep components small and focused
- Extract logic into custom hooks

## Naming

- PascalCase for components: `UserProfile.tsx`
- camelCase for hooks: `useAuth.ts`
- Prefix custom hooks with `use`

## State Management

- Use `useState` for local state
- Use `useReducer` for complex state logic
- Lift state up only when needed
- Consider context for deeply shared state
- Use external state management (Redux, Zustand) for complex apps

## Performance

- Memoize expensive calculations with `useMemo`
- Memoize callbacks with `useCallback`
- Use `React.memo` for pure components that re-render often
- Avoid inline object/array literals in JSX props
- Use virtualization for long lists

## Effects

- Keep effects focused on one concern
- Always include cleanup functions when needed
- Use dependency arrays correctly
- Avoid effects for derived state

## Patterns

- Composition over inheritance
- Render props or hooks for shared logic
- Controlled components for forms
- Error boundaries for error handling

## Accessibility

- Use semantic HTML elements
- Include aria attributes where needed
- Ensure keyboard navigation works
- Test with screen readers
