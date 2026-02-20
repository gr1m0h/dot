# Test Types and Patterns

## Unit Tests

Test single functions/methods in isolation.

```typescript
// Pure function test
it('should calculate total with tax', () => {
  const result = calculateTotal(100, 0.1);
  expect(result).toBe(110);
});
```

## Integration Tests

Test interactions between components.

```typescript
// Database integration test
it('should persist user to database', async () => {
  const user = await userService.create({ email: 'test@test.com', name: 'Test' });
  const found = await userRepository.findById(user.id);
  expect(found).toEqual(user);
});
```

## Edge Case Tests

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

## Test Double Patterns

| Type | Use Case | Example |
|------|----------|---------|
| **Stub** | Return canned answers | `userRepo.findById = () => mockUser` |
| **Mock** | Verify interactions | `expect(emailService.send).toHaveBeenCalled()` |
| **Spy** | Record calls, use real impl | `vi.spyOn(service, 'method')` |
| **Fake** | Working implementation | In-memory database |

## Common Pitfalls

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Testing implementation | Tests break on refactor | Test behavior, not internals |
| Large test steps | Hard to debug failures | Smaller increments |
| Skipping RED | False confidence | Always see test fail first |
| Over-mocking | Tests don't reflect reality | Use real implementations where possible |
| Slow tests | Developers skip them | Keep unit tests fast (<100ms) |
