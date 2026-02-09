# Coding Standards

## Core Principles

1. **Follow existing patterns** — match the project's style, not personal preference
2. **Minimal changes** — implement only what's requested, avoid unrelated refactoring
3. **Readability over cleverness** — clear code > concise code > "smart" code
4. **Delete, don't deprecate** — remove unused code completely, no `_unused` prefixes or `// removed` comments

## Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Variables, functions | camelCase | `getUserName`, `isValid` |
| Classes, types, interfaces | PascalCase | `UserService`, `ApiResponse` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` |
| Files (JS/TS) | kebab-case or PascalCase | `user-service.ts`, `UserService.tsx` |
| Files (Python) | snake_case | `user_service.py` |
| Files (Go) | snake_case | `user_service.go` |
| Boolean variables | is/has/can/should prefix | `isActive`, `hasPermission` |
| Event handlers | handle/on prefix | `handleClick`, `onSubmit` |

## Function Design

- **Single responsibility** — one function does one thing
- **3 or fewer parameters** — use an options object for more
- **Early returns** — avoid deep nesting, guard clauses first
- **Pure functions preferred** — minimize side effects, return values instead of mutating
- **Max 30 lines** — extract helper if longer (guideline, not hard rule)

## Error Handling

- Catch specific exception types — never bare `catch` without purpose
- Never swallow errors silently — at minimum, log them
- Use custom error types for domain-specific failures
- Return errors explicitly in Go-style when appropriate
- Handle Promise rejections — no unhandled async errors

## Imports & Organization

- Group imports: stdlib → external packages → internal modules → relative imports
- No unused imports — remove immediately
- Prefer named exports over default exports (easier to refactor and search)
- One component/class per file (with small private helpers allowed)

## Comments

- Write **WHY**, not **WHAT** — code shows what, comments explain why
- No comments for self-explanatory code
- TODOs must include ticket/issue number: `// TODO(#123): description`
- Remove commented-out code — use version control instead
- JSDoc/docstrings for public API surfaces only

## Type Safety

- Avoid `any` (TypeScript) — use `unknown` with type guards when type is uncertain
- Define explicit return types for public functions
- Use discriminated unions over optional fields for variant types
- Prefer `readonly` and `const` where mutation isn't needed
