# Coding Standards

## Principles
1. Follow existing patterns (project style > personal preference)
2. Minimal changes (only what's requested)
3. Readability > cleverness
4. Delete, don't deprecate (no `_unused` or `// removed`)

## Naming
| Element | Style | Example |
|---------|-------|---------|
| vars/funcs | camelCase | `getUserName` |
| classes/types | PascalCase | `UserService` |
| constants | SCREAMING_SNAKE | `MAX_RETRY` |
| booleans | is/has/can prefix | `isActive` |

## Functions
- Single responsibility, ≤3 params (use options object)
- Early returns, pure preferred, ≤30 lines

## Errors
- Specific catch types, never swallow silently
- Custom error types for domain failures

## Imports
- Order: stdlib → external → internal → relative
- No unused imports, prefer named exports

## Comments
- WHY not WHAT, TODOs need ticket# (`TODO(#123)`)
- No commented-out code

## Types (TS)
- No `any` (use `unknown` + guards)
- Explicit return types, discriminated unions
- Prefer `readonly`/`const`
