# Project Rules

## Overview

This is a Vue 3 project using the Composition API. Follow these conventions when making changes.

## Code Style

- Use Vue 3 Composition API with `<script setup>`
- Use TypeScript with strict mode
- Use Prettier for formatting
- Use ESLint with `eslint-plugin-vue`

## Component Structure

- PascalCase for component files: `UserProfile.vue`
- One component per file
- Use Single File Components (SFCs) by default

```
components/
├── AppHeader.vue
├── UserProfile/
│   ├── UserProfile.vue
│   ├── UserAvatar.vue
│   └── index.ts
```

### File Organization: SFC vs Split Files

**Keep as SFC when:**
- Component is under ~200 lines total
- Styles are tightly coupled to script (e.g., chart components with colors in both)
- Dynamic classes or computed styles reference script variables

**Split styles to separate file when:**
- Styles exceed ~100 lines
- Styles are purely presentational (layout, spacing, typography)
- Component is props-driven with variant classes

| Component Type | Recommendation |
|----------------|----------------|
| Chart-heavy (ECharts, D3) | Keep as SFC - colors couple script to styles |
| Presentational/shared | Consider splitting - styles are independent |
| Form/input components | Evaluate - often medium coupling |
| Layout containers | Consider splitting - styles rarely need script context |

Split example:
```
components/
├── DataTable/
│   ├── DataTable.vue      # template + script only
│   ├── DataTable.css      # styles
│   └── index.ts
```

## Composition API Patterns

- Use `ref` for primitives, `reactive` for objects
- Extract reusable logic into composables (`use*.ts`)
- Prefer `computed` over methods for derived state
- Use `watch` sparingly; prefer computed when possible

```
composables/
├── useAuth.ts
├── useFetch.ts
└── useLocalStorage.ts
```

## Props and Events

- Define props with `defineProps<T>()` for type safety
- Define emits with `defineEmits<T>()`
- Use `withDefaults()` for default prop values
- Prefer props over v-model for simple data flow

```vue
<script setup lang="ts">
interface Props {
  title: string
  count?: number
}

const props = withDefaults(defineProps<Props>(), {
  count: 0
})

const emit = defineEmits<{
  update: [value: string]
  close: []
}>()
</script>
```

## State Management

- Use Pinia for global state
- Keep stores focused and modular
- Use composables for shared non-global logic
- Prefer `storeToRefs` for reactive store access

```
stores/
├── useUserStore.ts
├── useCartStore.ts
└── index.ts
```

## Styling

- Use scoped styles by default: `<style scoped>`
- Use CSS variables for theming
- Follow BEM or utility-first conventions
- Support dark mode via CSS variables or class toggle

## Testing

- Use Vitest for unit tests
- Use Vue Test Utils for component tests
- Use `@testing-library/vue` for behavior-focused tests
- Test composables independently

```
components/
├── UserProfile.vue
└── UserProfile.test.ts
```

## Performance

- Use `v-once` for static content
- Use `v-memo` for expensive list items
- Lazy load routes with `defineAsyncComponent`
- Use `shallowRef` when deep reactivity isn't needed
- Virtualize long lists with vue-virtual-scroller

## Git

- Use conventional commits
- Keep PRs focused and reviewable
