# Context Engineering

2026 core paradigm: Context > Prompt. Structure of context determines model performance.

## Principles

1. **Lean System Prompt**: CLAUDE.md is a map, not an encyclopedia (<200 lines)
2. **Progressive Disclosure**: Domain knowledge in skills, loaded on-demand
3. **Mechanical Enforcement**: Hooks > Rules > Documentation (enforcement reliability)
4. **Context Isolation**: Subagents get fresh context, only results return

## Promotion Ladder

```
CLAUDE.md (always loaded, expensive) ← MINIMIZE
    ↓ promote to
Skills (on-demand, triggered by context) ← MAXIMIZE
    ↓ promote to
Hooks (mechanical, zero LLM tokens) ← PREFER
```

When to promote:
- Rule in CLAUDE.md that only applies to specific domains → Skill
- Skill that must happen every time without exception → Hook
- Hook that blocks with unhelpful error → Add self-correction hint

## Context Window Budget

| Layer | Budget | Purpose |
|-------|--------|---------|
| CLAUDE.md + @rules | <2k tokens | Universal navigation |
| Active skills | <5k tokens | Current domain context |
| Working memory | Remainder | Task-specific content |

## Context Rot Prevention

Performance degrades at ~300k-400k tokens even with 1M available.

| Strategy | When | Mechanism |
|----------|------|-----------|
| `/rewind` | Failed attempt | Drops failure, preserves learning |
| `/btw` | Side question | Overlay, no history impact |
| `/compact <hints>` | Task milestone | Distills to dense brief |
| `/clear` | Task switch | Full reset |
| Subagent | Investigation | Fresh context per child |
| Checkpoints | Multi-phase work | Persist across sessions |

## Structured Context Design

- Place static content first, dynamic last (cache prefix matching)
- Use @references to defer loading (don't inline large docs)
- Scope searches narrowly before expanding (Glob → Grep → Read)
- Batch independent tool calls in single message (parallel execution)

## Anti-Patterns

| Anti-Pattern | Fix |
|--------------|-----|
| Bloated CLAUDE.md (>200 lines) | Promote to skills |
| Domain rules always loaded | Progressive disclosure |
| Manual checks in CLAUDE.md | Promote to hooks |
| Full file reads "just in case" | Glob/Grep first |
| Context as dump | Context as curated briefing |
