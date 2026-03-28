# Coding Standards

## Principles
1. Follow existing patterns (project style > personal preference)
2. Minimal changes (only what's requested)
3. Readability > cleverness
4. Delete, don't deprecate (no `_unused` or `// removed`)

## Naming

Follow the convention of the project language:

### TypeScript / JavaScript
| Element | Style | Example |
|---------|-------|---------|
| vars/funcs | camelCase | `getUserName` |
| classes/types | PascalCase | `UserService` |
| constants | SCREAMING_SNAKE | `MAX_RETRY` |
| booleans | is/has/can prefix | `isActive` |

### Ruby
| Element | Style | Example |
|---------|-------|---------|
| vars/methods | snake_case | `get_user_name` |
| classes/modules | PascalCase | `UserService` |
| constants | SCREAMING_SNAKE | `MAX_RETRY` |
| predicates | ? suffix | `active?` |
| destructive | ! suffix | `save!` |

### PHP
| Element | Style | Example |
|---------|-------|---------|
| vars/funcs | camelCase | `getUserName` |
| classes/interfaces | PascalCase | `UserService` |
| constants | SCREAMING_SNAKE | `MAX_RETRY` |
| booleans | is/has/can prefix | `$isActive` |

### Go
| Element | Style | Example |
|---------|-------|---------|
| exported | PascalCase | `GetUserName` |
| unexported | camelCase | `getUserName` |
| packages | lowercase | `userservice` |
| constants | PascalCase or SCREAMING_SNAKE | `MaxRetry` |
| interfaces | -er suffix (single method) | `Reader`, `Writer` |

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

### TypeScript
- No `any` (use `unknown` + guards)
- Explicit return types, discriminated unions
- Prefer `readonly`/`const`

### Ruby
- Use Sorbet (`sig` annotations) or RBS for type checking
- Prefer `T.nilable` over implicit nil
- Use `T::Struct` for typed data objects

### PHP
- Use `declare(strict_types=1)` in every file
- PHPStan/Psalm level max for static analysis
- Type-hint all parameters and return types
- Use union types (`string|int`) over mixed

### Go
- Use strong typing (no `interface{}` / `any` without reason)
- Prefer concrete types, use interfaces at consumer side
- Define custom types for domain concepts (`type UserID string`)
- Use generics (1.18+) for type-safe collections
