# Common Patterns

## API Response Format

### TypeScript
```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total: number
    page: number
    limit: number
  }
}
```

### Ruby
```ruby
class ApiResponse
  attr_reader :success, :data, :error, :meta

  def initialize(success:, data: nil, error: nil, meta: nil)
    @success = success
    @data = data
    @error = error
    @meta = meta
  end
end
```

### PHP
```php
class ApiResponse {
    public function __construct(
        public readonly bool $success,
        public readonly mixed $data = null,
        public readonly ?string $error = null,
        public readonly ?array $meta = null,
    ) {}
}
```

### Go
```go
type ApiResponse[T any] struct {
    Success bool   `json:"success"`
    Data    T      `json:"data,omitempty"`
    Error   string `json:"error,omitempty"`
    Meta    *Meta  `json:"meta,omitempty"`
}

type Meta struct {
    Total int `json:"total"`
    Page  int `json:"page"`
    Limit int `json:"limit"`
}
```

## Custom Hooks Pattern

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}
```

## Repository Pattern

### TypeScript
```typescript
interface Repository<T> {
  findAll(filters?: Filters): Promise<T[]>
  findById(id: string): Promise<T | null>
  create(data: CreateDto): Promise<T>
  update(id: string, data: UpdateDto): Promise<T>
  delete(id: string): Promise<void>
}
```

### Ruby
```ruby
module Repository
  def find_all(filters: {}) = raise NotImplementedError
  def find_by_id(id) = raise NotImplementedError
  def create(attrs) = raise NotImplementedError
  def update(id, attrs) = raise NotImplementedError
  def delete(id) = raise NotImplementedError
end
```

### PHP
```php
interface Repository {
    public function findAll(array $filters = []): array;
    public function findById(string $id): ?object;
    public function create(array $data): object;
    public function update(string $id, array $data): object;
    public function delete(string $id): void;
}
```

### Go
```go
type Repository[T any] interface {
    FindAll(ctx context.Context, filters Filters) ([]T, error)
    FindByID(ctx context.Context, id string) (*T, error)
    Create(ctx context.Context, data CreateDTO) (*T, error)
    Update(ctx context.Context, id string, data UpdateDTO) (*T, error)
    Delete(ctx context.Context, id string) error
}
```

## Skeleton Projects

When implementing new functionality:
1. Search for battle-tested skeleton projects
2. Use parallel agents to evaluate options:
   - Security assessment
   - Extensibility analysis
   - Relevance scoring
   - Implementation planning
3. Clone best match as foundation
4. Iterate within proven structure
