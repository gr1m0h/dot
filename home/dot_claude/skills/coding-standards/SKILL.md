---
name: coding-standards
description: Universal coding standards and best practices for TypeScript, JavaScript, React, and Node.js. Load when writing new code, reviewing code quality, or enforcing naming conventions, immutability patterns, error handling, and type safety standards.
---

# Coding Standards & Best Practices

Universal coding standards applicable across all projects.

## Code Quality Principles

1. **Readability First** - Code is read more than written
2. **KISS** - Simplest solution that works
3. **DRY** - Extract common logic into functions
4. **YAGNI** - Don't build features before they're needed

## TypeScript/JavaScript Standards

### Naming

```typescript
// Descriptive names with verb-noun pattern
async function fetchMarketData(marketId: string) { }
function calculateSimilarity(a: number[], b: number[]) { }
function isValidEmail(email: string): boolean { }
```

### Immutability (CRITICAL)

```typescript
// ALWAYS use spread operator
const updatedUser = { ...user, name: 'New Name' }
const updatedArray = [...items, newItem]

// NEVER mutate directly
// user.name = 'New Name'  // BAD
// items.push(newItem)     // BAD
```

### Error Handling

```typescript
async function fetchData(url: string) {
  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    return await response.json()
  } catch (error) {
    console.error('Fetch failed:', error)
    throw new Error('Failed to fetch data')
  }
}
```

### Async/Await

```typescript
// Parallel execution when possible
const [users, markets, stats] = await Promise.all([
  fetchUsers(), fetchMarkets(), fetchStats()
])
```

### Type Safety

```typescript
interface Market {
  id: string
  name: string
  status: 'active' | 'resolved' | 'closed'
  created_at: Date
}
// No 'any' - use explicit types
```

## React Best Practices

- Functional components with typed Props
- Custom hooks for reusable logic
- Functional state updates: `setCount(prev => prev + 1)`
- Clear conditional rendering (avoid ternary hell)

## API Design

- REST conventions: resource-based URLs, proper HTTP methods
- Consistent response format: `{ success, data?, error?, meta? }`
- Schema validation with Zod
- Proper status codes

## Testing (AAA Pattern)

```typescript
test('calculates similarity correctly', () => {
  // Arrange
  const vector1 = [1, 0, 0]
  // Act
  const similarity = calculateCosineSimilarity(vector1, vector2)
  // Assert
  expect(similarity).toBe(0)
})
```

## Code Smells to Avoid

1. **Long Functions** (>50 lines) - Split into smaller functions
2. **Deep Nesting** (>3 levels) - Use early returns
3. **Magic Numbers** - Use named constants
4. **Copy-Paste** - Extract shared logic

## Comments

- Explain WHY, not WHAT
- JSDoc for public APIs
- No commented-out code
