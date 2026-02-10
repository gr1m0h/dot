---
name: search-memory
description: Search and retrieve relevant information from the cognitive memory system
user-invocable: true
allowed-tools: Read, Grep, Glob
---

# Cognitive Memory Search

Searches the cognitive memory system for information related to $ARGUMENTS.

## Dynamic Context

- Memory structure: !`find .claude/memory -type f 2>/dev/null | head -30 || echo "No memory files found"`

## Search Hierarchy

Search order follows cognitive memory architecture (fallback to available directories):

### 1. Working Memory (immediate context)

Most relevant and recent information

- `.claude/memory/local/session-state.json`
- `.claude/memory/local/current-task.md`

### 2. Episodic Memory (related experiences)

Session history and interaction patterns

- `.claude/memory/local/session-metrics.jsonl`
- `.claude/memory/local/edit-audit.jsonl`
- `.claude/memory/local/learnings.md`

### 3. Semantic Memory (abstract knowledge)

Generalized patterns, architecture decisions, and project knowledge

- `.claude/memory/project/architecture.md`
- `.claude/memory/project/` (all project-level knowledge)

## Search Strategy

1. **Keyword Matching**: Direct term matching across all memory files
2. **Scope Priority**: local/ (session) → project/ (cross-session) → CLAUDE.md (global)
3. **Temporal Proximity**: Prioritize recent entries in JSONL files
4. **Semantic Expansion**: Follow references between memory files

## Output Format

```markdown
## Memory Search Results: "$ARGUMENTS"

### Working Memory

- [Recent context information]

### Relevant Episodic Memories

- [Session 2026-02-01] Experience solving a similar problem
    - Situation: ...
    - Solution: ...

### Semantic Knowledge

- [Concept: error-handling] Related patterns
    - ...

### Confidence Score

Overall relevance: 0.85
```
