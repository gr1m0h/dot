---
paths:
    - "src/components/**/*.{tsx,jsx}"
    - "src/pages/**/*.{tsx,jsx}"
    - "src/app/**/*.{tsx,jsx}"
    - "src/features/**/*.{tsx,jsx}"
---

# React Component Rules

## Component Design

- Function components only — no class components
- Define `Props` type explicitly for every component
- Use `children: React.ReactNode` for wrapper components
- Prefer composition over prop drilling — use compound components or context
- One component per file — small private helpers are OK in the same file
- Co-locate related files: `Button.tsx`, `Button.test.tsx`, `Button.module.css`

## Hooks

- Custom hooks must use the `use` prefix: `useAuth`, `useDebounce`
- Never call hooks conditionally — always at the top level
- Extract complex logic into custom hooks (keep components as thin render functions)
- Use `useCallback` for callback props passed to memoized children
- Use `useMemo` only for genuinely expensive computations — don't memoize by default
- Cleanup effects: return cleanup function from `useEffect` for subscriptions, timers, listeners

## State Management

- Local state first (`useState`) — lift only when shared
- Use `useReducer` for complex state logic with multiple sub-values
- Server state: use TanStack Query, SWR, or equivalent (not manual fetch+state)
- Global state: use context for low-frequency updates, external store for high-frequency
- Never store derived state — compute it inline or with `useMemo`

## Performance

- Wrap list item components with `React.memo` when parent re-renders frequently
- Use `key` prop correctly — stable, unique identifiers (not array index for dynamic lists)
- Lazy load routes and heavy components: `React.lazy()` + `Suspense`
- Avoid inline object/array creation in JSX props (causes unnecessary re-renders)
- Image optimization: use `next/image`, `loading="lazy"`, proper `srcset`

## Accessibility

- Interactive elements must be semantic: `<button>`, `<a>`, `<input>` (not `<div onClick>`)
- All images require `alt` text (decorative images: `alt=""`)
- Form inputs require associated `<label>` elements
- Keyboard navigation: ensure `tabIndex`, focus management, `onKeyDown` handlers
- Use ARIA attributes only when semantic HTML is insufficient

## Error Handling

- Use Error Boundaries for UI crash recovery
- Handle loading and error states explicitly (not just happy path)
- Show user-friendly error messages — never raw error objects or stack traces
