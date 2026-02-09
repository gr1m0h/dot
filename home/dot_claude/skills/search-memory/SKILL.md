---
name: search-memory
description: Search and retrieve relevant information from the cognitive memory system
user-invocable: true
allowed-tools: Read, Grep, Glob
---

# Cognitive Memory Search

Searches the cognitive memory system for information related to $ARGUMENTS.

## Search Hierarchy

### 1. Working Memory (immediate)

Most relevant and recent information

- `.claude/memory/working/current-context.json`

### 2. Episodic Memory (related experiences)

Similar past experiences

- `.claude/memory/episodic/sessions/`
- `.claude/memory/episodic/interactions/`

### 3. Semantic Memory (abstract knowledge)

Generalized patterns and knowledge

- `.claude/memory/semantic/concepts/`
- `.claude/memory/semantic/skills/`

## Search Strategy

1. **Keyword Matching**: Direct term matching
2. **Concept Relevance**: Expand related concepts from relationships.json
3. **Temporal Proximity**: Prioritize recent episodes

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
