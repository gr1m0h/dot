---
name: tdd
description: Execute a test-driven development workflow with mutation testing and coverage tracking. Ensures high-quality, well-tested code through Red-Green-Refactor cycles.
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
argument-hint: "[feature-name]"
metadata:
  version: "2.0.0"
  updated: "2025-02"
hooks:
  - type: command
    command: |
      node -e "
        const fs = require('fs');
        const found = ['package.json','pytest.ini','pyproject.toml','Cargo.toml','go.mod'].filter(f => { try { fs.accessSync(f); return true; } catch { return false; } });
        if (found.length === 0) { console.log(JSON.stringify({additionalContext:'WARNING: No test framework config found. Install a test framework before starting TDD.'})); }
        else if (found.includes('package.json')) {
          const pkg = JSON.parse(fs.readFileSync('package.json','utf8'));
          const deps = {...pkg.devDependencies,...pkg.dependencies};
          const fw = ['vitest','jest','mocha','ava'].find(t => deps && deps[t]);
          if (!fw) console.log(JSON.stringify({additionalContext:'WARNING: No JS test framework in dependencies. Run npm install -D vitest (or jest) first.'}));
        }
      "
    once: true
---

# Test-Driven Development

Implement **$ARGUMENTS** using strict TDD methodology.

**Reference:** [Test-Driven Development by Example (Kent Beck)](https://www.oreilly.com/library/view/test-driven-development/0321146530/)

## TDD Strategy

The TDD workflow follows a strict cycle:

1. **RED** - Write a failing test first
2. **GREEN** - Write minimal code to pass
3. **REFACTOR** - Clean up while keeping tests green
4. **REPEAT** - Add next behavior

## Dynamic Context

- Test framework: !`ls package.json 2>/dev/null && node -e "const p=require('./package.json');const d={...p.devDependencies,...p.dependencies};const f=['vitest','jest','mocha','ava','playwright','cypress'].find(t=>d[t]);console.log(f||'unknown')" 2>/dev/null || ls pytest.ini setup.cfg pyproject.toml Cargo.toml go.mod 2>/dev/null | head -1 || echo "unknown"`
- Existing test patterns: !`find . -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.*' 2>/dev/null | head -5 || echo "No tests found"`
- Source structure: !`ls src/ app/ lib/ 2>/dev/null | head -10 || echo "N/A"`
- Coverage config: !`cat jest.config.* vitest.config.* pytest.ini pyproject.toml 2>/dev/null | grep -i coverage | head -3 || echo "N/A"`

## Red-Green-Refactor Protocol

### Phase 1: RED - Write Failing Test

Write a test that describes the desired behavior.

```markdown
**Checklist:**
- [ ] Test describes ONE specific behavior
- [ ] Test name clearly states expected behavior
- [ ] Test uses AAA pattern (Arrange-Act-Assert)
- [ ] Test fails with expected error message
- [ ] Test does not depend on other tests
```

#### Example: JavaScript (Vitest/Jest)

```typescript
// user.test.ts
import { describe, it, expect } from 'vitest';
import { createUser } from './user';

describe('createUser', () => {
  it('should create a user with email and name', () => {
    // Arrange
    const email = 'test@example.com';
    const name = 'Test User';

    // Act
    const user = createUser({ email, name });

    // Assert
    expect(user.email).toBe(email);
    expect(user.name).toBe(name);
    expect(user.id).toBeDefined();
  });

  it('should throw when email is invalid', () => {
    expect(() => createUser({ email: 'invalid', name: 'Test' }))
      .toThrow('Invalid email format');
  });
});
```

#### Example: Python (pytest)

```python
# test_user.py
import pytest
from user import create_user

class TestCreateUser:
    def test_creates_user_with_email_and_name(self):
        # Arrange
        email = "test@example.com"
        name = "Test User"

        # Act
        user = create_user(email=email, name=name)

        # Assert
        assert user.email == email
        assert user.name == name
        assert user.id is not None

    def test_raises_on_invalid_email(self):
        with pytest.raises(ValueError, match="Invalid email format"):
            create_user(email="invalid", name="Test")
```

### Phase 2: GREEN - Minimal Implementation

Write the **minimum** code to make the test pass.

```markdown
**Rules:**
- [ ] Only write code that makes the current test pass
- [ ] Do NOT anticipate future requirements
- [ ] Do NOT optimize or generalize yet
- [ ] Hardcoding is acceptable at this stage
- [ ] Run tests after every change
```

#### Example: Minimal Implementation

```typescript
// user.ts - First pass (hardcoded)
export function createUser({ email, name }) {
  if (!email.includes('@')) {
    throw new Error('Invalid email format');
  }
  return {
    id: '1',  // Hardcoded is fine in GREEN
    email,
    name,
  };
}
```

### Phase 3: REFACTOR - Improve Design

Improve the code while keeping all tests green.

```markdown
**Checklist:**
- [ ] Remove duplication
- [ ] Improve naming
- [ ] Extract functions/methods
- [ ] Apply design patterns if appropriate
- [ ] Run tests after EVERY change
- [ ] Do NOT add new behavior (that's RED phase)
```

#### Example: Refactored Implementation

```typescript
// user.ts - After refactor
import { randomUUID } from 'crypto';

interface CreateUserInput {
  email: string;
  name: string;
}

interface User {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
}

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function validateEmail(email: string): void {
  if (!EMAIL_REGEX.test(email)) {
    throw new Error('Invalid email format');
  }
}

export function createUser({ email, name }: CreateUserInput): User {
  validateEmail(email);

  return {
    id: randomUUID(),
    email,
    name,
    createdAt: new Date(),
  };
}
```

## Test Types and Patterns

### Unit Tests

Test single functions/methods in isolation.

```typescript
// Pure function test
it('should calculate total with tax', () => {
  const result = calculateTotal(100, 0.1);
  expect(result).toBe(110);
});
```

### Integration Tests

Test interactions between components.

```typescript
// Database integration test
it('should persist user to database', async () => {
  const user = await userService.create({ email: 'test@test.com', name: 'Test' });
  const found = await userRepository.findById(user.id);
  expect(found).toEqual(user);
});
```

### Edge Case Tests

Test boundary conditions and error cases.

```typescript
describe('edge cases', () => {
  it('should handle empty string', () => { /* ... */ });
  it('should handle null input', () => { /* ... */ });
  it('should handle maximum length', () => { /* ... */ });
  it('should handle special characters', () => { /* ... */ });
  it('should handle concurrent calls', () => { /* ... */ });
});
```

## Test Naming Conventions

| Pattern | Example |
|---------|---------|
| should_when | `should_throw_when_email_invalid` |
| given_when_then | `given_valid_user_when_save_then_persists` |
| method_condition_expectation | `createUser_invalidEmail_throws` |

## Cycle Discipline

```markdown
**Hard Rules:**
- ONE assertion per test (except related state checks)
- NO production code without a failing test first
- NO refactoring while RED - get GREEN first
- Commit after each GREEN phase
- Never skip the RED phase
```

## Test Double Patterns

| Type | Use Case | Example |
|------|----------|---------|
| **Stub** | Return canned answers | `userRepo.findById = () => mockUser` |
| **Mock** | Verify interactions | `expect(emailService.send).toHaveBeenCalled()` |
| **Spy** | Record calls, use real impl | `vi.spyOn(service, 'method')` |
| **Fake** | Working implementation | In-memory database |

## Coverage Guidelines

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

```markdown
**Before declaring done:**
- [ ] All acceptance criteria covered by tests
- [ ] Edge cases tested (null, empty, boundary, invalid)
- [ ] Error paths tested (exceptions, failure modes)
- [ ] No skipped or commented-out tests
- [ ] All tests pass in isolation and as suite
- [ ] Existing tests unbroken (no regressions)
- [ ] Coverage meets project standards
```

## Final Summary

```markdown
## TDD Session Summary

**Feature:** $ARGUMENTS
**Duration:** [time]
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

## Common Pitfalls

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Testing implementation | Tests break on refactor | Test behavior, not internals |
| Large test steps | Hard to debug failures | Smaller increments |
| Skipping RED | False confidence | Always see test fail first |
| Over-mocking | Tests don't reflect reality | Use real implementations where possible |
| Slow tests | Developers skip them | Keep unit tests fast (<100ms) |

## Related Skills

- [mutation-test](/mutation-test) - Verify test quality
- [property-test](/property-test) - Property-based testing
- [review-code](/review-code) - Code review

## Resources

- [Test-Driven Development by Example](https://www.oreilly.com/library/view/test-driven-development/0321146530/)
- [Growing Object-Oriented Software, Guided by Tests](http://www.growing-object-oriented-software.com/)
- [The Art of Unit Testing](https://www.manning.com/books/the-art-of-unit-testing-third-edition)

---

*Version 2.0.0 - Updated 2025-02*
