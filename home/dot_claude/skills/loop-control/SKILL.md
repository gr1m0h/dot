---
name: loop-control
description: Manage autonomous improvement loops for build, test, and quality
triggers: ["loop start", "loop status", "start loop", "fix loop"]
---

# Loop Control

Manage autonomous iteration loops for continuous improvement.

## When to Use
- Multiple build errors to fix iteratively
- Test suite with cascading failures
- Quality improvements needed across codebase
- Iterative refinement of generated code

## Loop Types

### build
Fix build/compilation errors iteratively until clean.
```
/loop-start build [command]
```

### test
Fix test failures iteratively until all pass.
```
/loop-start test [command]
```

### quality
Fix linter/type/style issues iteratively.
```
/loop-start quality [command]
```

## Controls

- **Max iterations**: 10 (stop after 10 attempts)
- **Circuit breaker**: Stop if same error appears 3 times
- **Progress gate**: Each iteration must reduce error count
- **Escalation**: Ask user if stuck

## Status Tracking

```
/loop-status

Loop: build | Iteration: 4/10 | Errors: 3→1 | Progress: 67%
Last fix: Resolved type mismatch in UserService.ts
Remaining: 1 import error in index.ts
```
