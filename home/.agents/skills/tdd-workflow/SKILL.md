---
name: tdd-workflow
description: Use this skill when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests.
---

# Test-Driven Development Workflow

Ensures all code development follows TDD principles with comprehensive test coverage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new components

## Core Principles

1. **Tests BEFORE Code** - Always write tests first
2. **80% Coverage** minimum (unit + integration + E2E)
3. **All edge cases covered** - Error scenarios, boundary conditions

## TDD Workflow Steps

1. **Write User Journeys** - As a [role], I want to [action], so that [benefit]
2. **Generate Test Cases** - Comprehensive tests for each journey
3. **Run Tests (Should Fail)** - `npm test`
4. **Implement Code** - Minimal code to make tests pass
5. **Run Tests Again (Should Pass)** - `npm test`
6. **Refactor** - Improve code quality while keeping tests green
7. **Verify Coverage** - `npm run test:coverage` (80%+)

## Testing Patterns

### Unit Test (Jest/Vitest)
```typescript
describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)
    fireEvent.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### API Integration Test
```typescript
describe('GET /api/markets', () => {
  it('returns markets successfully', async () => {
    const request = new NextRequest('http://localhost/api/markets')
    const response = await GET(request)
    expect(response.status).toBe(200)
  })

  it('validates query parameters', async () => {
    const request = new NextRequest('http://localhost/api/markets?limit=invalid')
    const response = await GET(request)
    expect(response.status).toBe(400)
  })
})
```

### E2E Test (Playwright)
```typescript
test('user can search and filter markets', async ({ page }) => {
  await page.goto('/')
  await page.click('a[href="/markets"]')
  await expect(page.locator('h1')).toContainText('Markets')
  await page.fill('input[placeholder="Search markets"]', 'election')
  await page.waitForTimeout(600)
  const results = page.locator('[data-testid="market-card"]')
  await expect(results).toHaveCount(5, { timeout: 5000 })
})
```

## Test File Organization

```
src/
├── components/Button/
│   ├── Button.tsx
│   └── Button.test.tsx
├── app/api/markets/
│   ├── route.ts
│   └── route.test.ts
└── e2e/
    ├── markets.spec.ts
    └── auth.spec.ts
```

## Common Mistakes to Avoid

- Testing implementation details (test user-visible behavior instead)
- Brittle selectors (use semantic selectors)
- No test isolation (each test sets up its own data)

## Best Practices

1. Write Tests First (TDD)
2. One Assert Per Test
3. Descriptive Test Names
4. Arrange-Act-Assert pattern
5. Mock External Dependencies
6. Test Edge Cases (null, undefined, empty, large)
7. Test Error Paths
8. Keep Tests Fast (<50ms each for unit tests)
9. Clean Up After Tests
10. Review Coverage Reports
