---
name: instinct-manage
description: Manage learned instincts - view, export, import, and evolve patterns
triggers: ["instinct status", "instinct export", "instinct import", "evolve instinct", "manage instincts"]
---

# Instinct Management

Manage the continuous learning instinct system.

## When to Use
- Review what patterns have been learned
- Export instincts for backup or sharing
- Import instincts from another setup
- Promote high-confidence instincts to skills

## Commands

### Status
View all instincts with confidence scores:
```
/instinct-status
```

Output:
```
| Pattern | Confidence | Frequency | Last Used |
|---------|-----------|-----------|-----------|
| Use keyset pagination | 0.92 | 12 | 2h ago |
| Zod schema for API input | 0.87 | 8 | 1d ago |
| Parallel Grep for search | 0.75 | 5 | 3d ago |
```

### Export
Save instincts to file:
```
/instinct-export [path]
```

### Import
Load instincts from file:
```
/instinct-import [path]
```

### Evolve
Promote instincts with confidence > 0.8 to skills:
```
/evolve
```

## Instinct Format

```json
{
  "pattern": "Description of the pattern",
  "confidence": 0.85,
  "frequency": 10,
  "context": "When this pattern applies",
  "example": "Concrete usage example",
  "lastUsed": "2026-03-27T00:00:00Z"
}
```

## Storage

Instincts stored in `~/.claude/memory/local/instincts.json`
