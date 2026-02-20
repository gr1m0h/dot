# Red-Green-Refactor Protocol

## Phase 1: RED - Write Failing Test

Write a test that describes the desired behavior.

**Checklist:**
- [ ] Test describes ONE specific behavior
- [ ] Test name clearly states expected behavior
- [ ] Test uses AAA pattern (Arrange-Act-Assert)
- [ ] Test fails with expected error message
- [ ] Test does not depend on other tests

### Example: JavaScript (Vitest/Jest)

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

### Example: Python (pytest)

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

## Phase 2: GREEN - Minimal Implementation

Write the **minimum** code to make the test pass.

**Rules:**
- [ ] Only write code that makes the current test pass
- [ ] Do NOT anticipate future requirements
- [ ] Do NOT optimize or generalize yet
- [ ] Hardcoding is acceptable at this stage
- [ ] Run tests after every change

### Example: Minimal Implementation

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

## Phase 3: REFACTOR - Improve Design

Improve the code while keeping all tests green.

**Checklist:**
- [ ] Remove duplication
- [ ] Improve naming
- [ ] Extract functions/methods
- [ ] Apply design patterns if appropriate
- [ ] Run tests after EVERY change
- [ ] Do NOT add new behavior (that's RED phase)

### Example: Refactored Implementation

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

## Cycle Discipline

**Hard Rules:**
- ONE assertion per test (except related state checks)
- NO production code without a failing test first
- NO refactoring while RED - get GREEN first
- Commit after each GREEN phase
- Never skip the RED phase
