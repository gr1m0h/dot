# Continuous Learning

## Pattern Extraction

After solving non-trivial problems:
1. Use `/learn` to extract reusable patterns
2. Capture: error resolution, debugging techniques, workarounds
3. Promote recurring patterns to skills; recurring must-happen rules to hooks

(The former "instinct system" skills were pruned 2026-07; native auto memory
`~/.claude/projects/<project>/memory/` now covers cross-session learning.)

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
