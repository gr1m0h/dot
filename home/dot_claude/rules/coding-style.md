# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate:

### JavaScript / TypeScript
```javascript
// WRONG: Mutation
function updateUser(user, name) {
  user.name = name  // MUTATION!
  return user
}

// CORRECT: Immutability
function updateUser(user, name) {
  return {
    ...user,
    name
  }
}
```

### Ruby
```ruby
# WRONG: Mutation
def update_user(user, name)
  user[:name] = name  # MUTATION!
  user
end

# CORRECT: Immutability
def update_user(user, name)
  user.merge(name: name)
end
```

### PHP
```php
// WRONG: Mutation
function updateUser(array &$user, string $name): array {
    $user['name'] = $name;  // MUTATION!
    return $user;
}

// CORRECT: Immutability
function updateUser(array $user, string $name): array {
    return array_merge($user, ['name' => $name]);
}
```

### Go
```go
// WRONG: Mutation
func UpdateUser(user *User, name string) {
    user.Name = name  // MUTATION!
}

// CORRECT: Immutability (return new struct)
func UpdateUser(user User, name string) User {
    user.Name = name
    return user
}
```

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large components
- Organize by feature/domain, not by type

## Error Handling

ALWAYS handle errors comprehensively:

### TypeScript
```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('Detailed user-friendly message')
}
```

### Ruby
```ruby
begin
  result = risky_operation
rescue SpecificError => e
  Rails.logger.error("Operation failed: #{e.message}")
  raise ApplicationError, "Detailed user-friendly message"
end
```

### Go
```go
result, err := riskyOperation()
if err != nil {
    log.Printf("Operation failed: %v", err)
    return fmt.Errorf("detailed user-friendly message: %w", err)
}
```

## Input Validation

ALWAYS validate user input:

### TypeScript (Zod)
```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

### Ruby (dry-validation)
```ruby
class UserContract < Dry::Validation::Contract
  params do
    required(:email).filled(:string)
    required(:age).filled(:integer, gt?: 0, lteq?: 150)
  end
end
```

### PHP (Laravel)
```php
$validated = $request->validate([
    'email' => 'required|email',
    'age' => 'required|integer|min:0|max:150',
]);
```

### Go (validator)
```go
type UserInput struct {
    Email string `validate:"required,email"`
    Age   int    `validate:"required,min=0,max=150"`
}

validate := validator.New()
err := validate.Struct(input)
```

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No console.log statements
- [ ] No hardcoded values
- [ ] No mutation (immutable patterns used)
