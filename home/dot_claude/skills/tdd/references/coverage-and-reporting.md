# Coverage Guidelines and Reporting

## Coverage Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Line coverage | 80%+ | Minimum for production code |
| Branch coverage | 75%+ | All if/else paths |
| Function coverage | 90%+ | All public functions |
| Critical paths | 100% | Auth, payments, data handling |

## Per-Cycle Report

After each Red-Green-Refactor cycle:

```markdown
## Cycle [N]

**Test:** `should_create_user_with_valid_email`
**File:** `src/user.test.ts:15`

### RED Phase
- Test written: `createUser returns user with email`
- Expected error: `createUser is not defined`
- Actual error: `createUser is not defined`

### GREEN Phase
- Implementation: `src/user.ts:1-10`
- Tests passing: 1/1

### REFACTOR Phase
- Changes: Extracted email validation
- Tests still passing: 1/1

**Commit:** `feat(user): add createUser function`
```

## Completion Criteria

**Before declaring done:**
- [ ] All acceptance criteria covered by tests
- [ ] Edge cases tested (null, empty, boundary, invalid)
- [ ] Error paths tested (exceptions, failure modes)
- [ ] No skipped or commented-out tests
- [ ] All tests pass in isolation and as suite
- [ ] Existing tests unbroken (no regressions)
- [ ] Coverage meets project standards

## Final Summary Template

```markdown
## TDD Session Summary

**Feature:** $ARGUMENTS
**Cycles completed:** [N]

### Files Created
- `src/feature.ts`
- `src/feature.test.ts`

### Files Modified
- `src/index.ts` (export added)

### Test Statistics
- Tests added: [N]
- Tests passing: [N/N]
- Coverage: [X]%

### Commits
1. `feat: add createUser function`
2. `feat: add email validation`
3. `refactor: extract validation helpers`
```
