# PHP / Laravel Patterns

## Code Style

- Follow PSR-12 coding standard (enforced by PHP-CS-Fixer)
- Use `declare(strict_types=1)` in every file
- Use typed properties and return types
- Prefer named arguments for clarity
- Use enums (PHP 8.1+) over string constants

## Laravel Conventions

- Use Form Request classes for validation (not inline validation in controllers)
- Use Resource classes for API responses
- Use Policies for authorization
- Use Events/Listeners for side effects
- Use Jobs for async processing

## Service Pattern

```php
final class CreateUserService
{
    public function __construct(
        private readonly UserRepository $repository,
        private readonly EventDispatcher $events,
    ) {}

    public function execute(CreateUserDTO $dto): User
    {
        $user = $this->repository->create($dto);
        $this->events->dispatch(new UserCreated($user));
        return $user;
    }
}
```

## Repository Pattern

```php
interface UserRepositoryInterface
{
    public function findById(string $id): ?User;
    public function findAll(array $filters = []): LengthAwarePaginator;
    public function create(CreateUserDTO $dto): User;
    public function update(string $id, UpdateUserDTO $dto): User;
    public function delete(string $id): void;
}
```

## DTO Pattern

```php
final readonly class CreateUserDTO
{
    public function __construct(
        public string $name,
        public string $email,
        public ?string $phone = null,
    ) {}

    public static function fromRequest(CreateUserRequest $request): self
    {
        return new self(
            name: $request->validated('name'),
            email: $request->validated('email'),
            phone: $request->validated('phone'),
        );
    }
}
```

## Error Handling

- Use custom exceptions extending base exception classes
- Use `render()` method on exceptions for API responses
- Use `report()` for logging side effects
- Use `Handler::renderable()` for global exception mapping

## Testing (PHPUnit / Pest)

- Use `RefreshDatabase` trait for database tests
- Use Factories for test data
- Use `fake()` helper for generating test data
- Prefer Feature tests for API endpoints
- Use `assertDatabaseHas` / `assertDatabaseMissing` for DB state

## Security

- Use Eloquent / Query Builder (never raw SQL with user input)
- Use `{!! !!}` only with `e()` helper or on trusted content
- Enable CSRF middleware on all state-changing routes
- Use `Gate::authorize()` for authorization checks
- Hash passwords with `Hash::make()` (bcrypt/argon2)

## Performance

- Use `with()` / `load()` to prevent N+1 queries
- Use `chunk()` / `lazy()` for large datasets
- Use `Cache::remember()` for expensive queries
- Use `select()` to limit columns
- Use database indexes on frequently queried columns
- Queue non-critical operations with `dispatch()`
