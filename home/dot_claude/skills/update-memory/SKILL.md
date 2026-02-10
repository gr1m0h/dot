---
name: update-memory
description: Persist new knowledge, update existing entries, and maintain the cognitive memory system
user-invocable: true
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Cognitive Memory Update

Persists new knowledge or updates existing entries in the cognitive memory system.

Input: $ARGUMENTS (knowledge to persist, or "auto" to extract from current session)

## Dynamic Context

- Memory files: !`find .claude/memory -type f 2>/dev/null | head -30 || echo "No memory files found"`
- Current learnings: !`wc -l .claude/memory/local/learnings.md 2>/dev/null || echo "0 lines"`
- Architecture: !`wc -l .claude/memory/project/architecture.md 2>/dev/null || echo "0 lines"`
- Session state: !`cat .claude/memory/local/session-state.json 2>/dev/null | head -10 || echo "No session state"`

## Memory Layers

### 1. Local Memory (session-scoped)

Files in `.claude/memory/local/`:

| File | Purpose | Format |
|---|---|---|
| `learnings.md` | Reusable patterns and lessons | Markdown (categorized) |
| `session-state.json` | Current session context | JSON |
| `current-task.md` | Active task description | Markdown |
| `error-log.txt` | Error history | Plain text |
| `session-metrics.jsonl` | Session performance data | JSONL |
| `edit-audit.jsonl` | File edit history | JSONL |

### 2. Project Memory (cross-session)

Files in `.claude/memory/project/`:

| File | Purpose | Format |
|---|---|---|
| `architecture.md` | System architecture overview | Markdown |

## Update Operations

### 1. Add Learning

Append a new learning to `.claude/memory/local/learnings.md`:

```markdown
## [YYYY-MM-DD] [Category]

**Context**: [When does this apply?]
**Learning**: [What was learned?]
**Action**: [What to do differently next time?]
**Confidence**: HIGH / MEDIUM / LOW
```

Categories: `architecture`, `debugging`, `testing`, `tooling`, `performance`, `security`, `patterns`, `workflow`

Before appending:
- Search existing entries for duplicates (Grep for key terms)
- If duplicate found: update confidence level and merge context
- If contradicted: replace old entry with new evidence
- Keep total entries under 100 (archive oldest LOW confidence items)

### 2. Update Architecture

Modify `.claude/memory/project/architecture.md` when:
- New system components are discovered
- Architectural decisions are made
- Integration patterns change

Preserve existing structure. Add or update specific sections only.

### 3. Update Session State

Write to `.claude/memory/local/session-state.json`:

```json
{
  "updated_at": "ISO-8601",
  "current_branch": "branch-name",
  "active_task": "task description",
  "context_notes": ["relevant context items"],
  "blockers": []
}
```

### 4. Log Error

Append to `.claude/memory/local/error-log.txt`:

```
[YYYY-MM-DD HH:MM] [CATEGORY] Description
  Context: ...
  Resolution: ...
```

### 5. Auto-Extract (when $ARGUMENTS = "auto")

Analyze the current session and automatically:
1. Extract learnings from completed work
2. Update session state with current context
3. Log any errors encountered
4. Update architecture if structural changes were made

## Deduplication Rules

1. Compare new entry against existing entries using key terms
2. Merge if >70% semantic overlap
3. Prefer higher confidence entries
4. Preserve oldest date, update content to latest
5. Link related entries via `**Related**: [category/topic]`

## Output Format

```markdown
## Memory Update Report

### Updates Applied

| Layer | File | Action | Details |
|---|---|---|---|
| local | learnings.md | Added | [Category]: [summary] |
| project | architecture.md | Updated | [section]: [change] |

### Deduplication

- [N] duplicates found and merged
- [N] contradictions resolved

### Memory Health

- Local entries: [count] / 100 max
- Project files: [count]
- Staleness: [OK / entries older than 7 days found]
```
