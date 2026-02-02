# Component Creator

Create UI components following project patterns.

## Arguments

- `$ARGUMENTS` - Component description (e.g., "user avatar with status indicator")

## Instructions

1. **Detect the framework** by examining the codebase:
   - React (JSX, hooks)
   - Vue (SFCs, composition API)
   - Svelte
   - Angular
   - Solid
   - Plain web components

2. **Identify project patterns**:
   - Component file structure (single file vs folder)
   - Styling approach (CSS modules, Tailwind, styled-components, etc.)
   - State management patterns
   - Naming conventions
   - TypeScript usage

3. **Create the component with**:
   - Clear prop interface with types
   - Sensible defaults for optional props
   - Proper event handling
   - Loading and error states if applicable
   - Responsive considerations

4. **Follow best practices**:
   - Keep components focused (single responsibility)
   - Extract reusable logic into hooks/composables
   - Use semantic HTML elements
   - Include basic accessibility (aria labels, keyboard handling)
   - Handle edge cases (empty states, long text, etc.)

5. **Include**:
   - TypeScript types/interfaces
   - Basic prop documentation
   - Example usage in comments if complex

## Output

- Component file(s) matching project structure
- Any new types needed
- Required imports or dependencies
- Example usage
