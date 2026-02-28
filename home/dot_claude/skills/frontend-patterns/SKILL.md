---
name: frontend-patterns
description: Frontend development patterns for React, Next.js, state management, performance optimization, and UI best practices.
---

# Frontend Development Patterns

Modern frontend patterns for React, Next.js, and performant user interfaces.

## Component Patterns

### Composition Over Inheritance

```typescript
interface CardProps {
  children: React.ReactNode
  variant?: 'default' | 'outlined'
}

export function Card({ children, variant = 'default' }: CardProps) {
  return <div className={`card card-${variant}`}>{children}</div>
}

export function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="card-header">{children}</div>
}
```

### Compound Components

```typescript
const TabsContext = createContext<TabsContextValue | undefined>(undefined)

export function Tabs({ children, defaultTab }: { children: React.ReactNode; defaultTab: string }) {
  const [activeTab, setActiveTab] = useState(defaultTab)
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      {children}
    </TabsContext.Provider>
  )
}
```

### Render Props Pattern

```typescript
export function DataLoader<T>({ url, children }: DataLoaderProps<T>) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    fetch(url).then(res => res.json()).then(setData).catch(setError).finally(() => setLoading(false))
  }, [url])

  return <>{children(data, loading, error)}</>
}
```

## Custom Hooks

### useToggle, useDebounce, useQuery

```typescript
export function useToggle(initialValue = false): [boolean, () => void] {
  const [value, setValue] = useState(initialValue)
  const toggle = useCallback(() => setValue(v => !v), [])
  return [value, toggle]
}

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(handler)
  }, [value, delay])
  return debouncedValue
}
```

## State Management

### Context + Reducer Pattern

```typescript
type Action =
  | { type: 'SET_MARKETS'; payload: Market[] }
  | { type: 'SELECT_MARKET'; payload: Market }
  | { type: 'SET_LOADING'; payload: boolean }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'SET_MARKETS': return { ...state, markets: action.payload }
    case 'SELECT_MARKET': return { ...state, selectedMarket: action.payload }
    case 'SET_LOADING': return { ...state, loading: action.payload }
    default: return state
  }
}
```

## Performance Optimization

### Memoization

```typescript
const sortedMarkets = useMemo(() => markets.sort((a, b) => b.volume - a.volume), [markets])
const handleSearch = useCallback((query: string) => setSearchQuery(query), [])
export const MarketCard = React.memo<MarketCardProps>(({ market }) => { /* ... */ })
```

### Code Splitting & Lazy Loading

```typescript
const HeavyChart = lazy(() => import('./HeavyChart'))

export function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart data={data} />
    </Suspense>
  )
}
```

### Virtualization for Long Lists

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

// Use for lists with 100+ items to avoid DOM bloat
```

## Form Handling

- Controlled forms with validation
- Functional state updates: `setFormData(prev => ({ ...prev, name: e.target.value }))`
- Error state management per field

## Error Boundary

```typescript
export class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }
  render() {
    if (this.state.hasError) return <ErrorFallback error={this.state.error} />
    return this.props.children
  }
}
```

## Accessibility

- Keyboard navigation with ArrowDown/ArrowUp/Enter/Escape handlers
- Focus management: save/restore focus for modals
- ARIA attributes: role, aria-expanded, aria-modal
- Semantic HTML elements

## Animation (Framer Motion)

```typescript
<AnimatePresence>
  {items.map(item => (
    <motion.div key={item.id}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
    />
  ))}
</AnimatePresence>
```

**Remember**: Choose patterns that fit your project complexity.
