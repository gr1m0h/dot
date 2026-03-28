# Continuous Learning

## Pattern Extraction

After solving non-trivial problems:
1. Use `/learn` to extract reusable patterns
2. Capture: error resolution, debugging techniques, workarounds
3. Store as instincts with confidence scoring

## Instinct System

Instincts are learned patterns with metadata:
- **Confidence** (0.0-1.0): How reliable the pattern is
- **Frequency**: How often the pattern applies
- **Context**: When to apply the pattern

### Lifecycle
1. **Observe**: Hook captures behavioral data
2. **Score**: Pattern evaluated for reliability
3. **Store**: Saved as instinct with metadata
4. **Evolve**: High-confidence instincts (>0.8) → skills/commands

## Commands

| Command | Purpose |
|---------|---------|
| `/learn` | Extract patterns from current session |
| `/instinct-status` | View all instincts with confidence scores |
| `/instinct-export` | Export instincts for sharing/backup |
| `/instinct-import` | Import instincts from external source |
| `/evolve` | Promote high-confidence instincts to skills |

## Session Memory

- Session state persisted via hooks (SessionStart/SessionEnd)
- Cross-session context via `.claude/memory/` files
- Use `/search-memory` to recall previous learnings
- Use `/update-memory` to persist new knowledge

## When to Learn

- After debugging a hard-to-find issue
- When discovering an undocumented API behavior
- After finding a performance optimization
- When a workaround is needed for a tool limitation
- After establishing a new project pattern
