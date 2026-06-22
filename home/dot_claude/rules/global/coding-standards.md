# Coding Standards

## Principles
1. Follow existing patterns (project style > personal preference)
2. Minimal changes (only what's requested)
3. Readability > cleverness
4. Delete, don't deprecate (no `_unused` or `// removed`)

## Naming

Follow the project language's standard convention. In short:
- **TS/JS, PHP**: camelCase vars/funcs, PascalCase types, SCREAMING_SNAKE constants, `is/has/can` booleans
- **Ruby**: snake_case methods, PascalCase classes, `?` predicates, `!` destructive
- **Go**: PascalCase exported / camelCase unexported, lowercase packages, `-er` interfaces

Full per-language naming + style detail lives in the on-demand language pattern
files (`@rules/backend/go-patterns.md`, `ruby-patterns.md`, `php-patterns.md`,
`@rules/frontend/react-patterns.md`).

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

## Types

Strong typing everywhere; avoid escape hatches (`any`/`interface{}`/`mixed`).
Type all params and returns. Per-language specifics (Sorbet/RBS, `strict_types`,
PHPStan level max, Go generics, discriminated unions) → see the on-demand
language pattern files.
