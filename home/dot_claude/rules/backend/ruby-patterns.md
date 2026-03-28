# Ruby / Rails Patterns

## Code Style

- Follow community Ruby style guide (enforced by RuboCop)
- Prefer `frozen_string_literal: true` at top of every file
- Use `&&` / `||` over `and` / `or`
- Prefer `each` over `for`
- Use guard clauses for early returns

## Rails Conventions

- Fat models, skinny controllers — extract to Service Objects when model grows
- Use Strong Parameters for mass assignment protection
- Prefer scopes over class methods for queries
- Use `find_each` for batch processing (not `each` on large datasets)
- Use `Time.current` over `Time.now` (respects time zone)

## Service Object Pattern

```ruby
class CreateUser
  def initialize(params)
    @params = params
  end

  def call
    validate!
    user = User.new(@params)
    user.save!
    notify(user)
    user
  end

  private

  def validate!
    raise ArgumentError, "Email required" if @params[:email].blank?
  end

  def notify(user)
    UserMailer.welcome(user).deliver_later
  end
end
```

## Query Object Pattern

```ruby
class UserQuery
  def initialize(scope = User.all)
    @scope = scope
  end

  def active
    @scope = @scope.where(active: true)
    self
  end

  def recent(days: 30)
    @scope = @scope.where("created_at > ?", days.days.ago)
    self
  end

  def resolve
    @scope
  end
end
```

## Error Handling

- Use custom error classes inheriting from `StandardError`
- Rescue specific exceptions, never bare `rescue`
- Use `rescue_from` in controllers for consistent API error responses

```ruby
class ApplicationError < StandardError; end
class NotFoundError < ApplicationError; end
class ValidationError < ApplicationError; end
```

## Testing (RSpec)

- Use `let` / `let!` for test data setup
- Use `described_class` to reference the class under test
- Use `shared_examples` for common behavior
- Prefer `build_stubbed` over `create` (faster, no DB)
- Use `freeze_time` for time-dependent tests

## Security

- Use `html_safe` only on trusted content
- Prefer `where(column: value)` over string interpolation
- Use `content_security_policy` in controllers
- Enable `protect_from_forgery` (CSRF)
- Use `has_secure_password` for authentication

## Performance

- Use `includes` / `preload` / `eager_load` to avoid N+1
- Use `pluck` instead of `map(&:attribute)` for single columns
- Use `counter_cache` for count queries
- Use `find_each` with `batch_size` for large datasets
- Use `select` to limit columns returned
