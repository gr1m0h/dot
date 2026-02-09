---
name: reflect
description: Structured reflection on completed work using Reflexion framework with persistent learnings
user-invocable: true
allowed-tools: Read, Write, Grep
---

# Reflection: Session Analysis

## Dynamic Context

- Session state: !`cat .claude/memory/local/session-state.json 2>/dev/null | head -20 || echo "No session state"`
- Recent learnings: !`cat .claude/memory/local/learnings.md 2>/dev/null | tail -20 || echo "No previous learnings"`
- Git activity: !`git log --oneline --since="8 hours ago" 2>/dev/null | head -10 || echo "No recent commits"`
- Failed commands: !`cat .claude/memory/local/error-log.txt 2>/dev/null | tail -5 || echo "No error log"`

## Reflexion Framework

### 1. Result Evaluation

- **Goal Achievement**: What was requested vs what was delivered?
- **Quality Assessment**: Does the output meet professional standards?
- **Unexpected Issues**: What problems arose during execution?
- **Deviation Analysis**: Where did the approach diverge from the plan?

### 2. Process Analysis

- **Efficiency**: Were there unnecessary steps or redundant operations?
- **Tool Usage**: Were the right tools used for each task?
- **Decision Points**: What key decisions were made and why?
- **Bottlenecks**: What slowed down progress?

### 3. Pattern Extraction

Identify reusable patterns:

- **What Worked Well** (to repeat):
  - Approach patterns that led to success
  - Tool combinations that were effective
  - Problem-solving strategies that worked

- **What Didn't Work** (to avoid):
  - Anti-patterns encountered
  - Common mistakes made
  - Inefficient approaches used

- **New Knowledge** (to remember):
  - Codebase patterns discovered
  - Framework/library quirks found
  - Project-specific conventions learned

### 4. Actionable Learnings

For each learning, format as:

```markdown
## [YYYY-MM-DD] [Category]

**Context**: [When does this apply?]
**Learning**: [What was learned?]
**Action**: [What to do differently next time?]
**Confidence**: HIGH / MEDIUM / LOW
```

Categories: `architecture`, `debugging`, `testing`, `tooling`, `performance`, `security`, `patterns`

### 5. Persist Learnings

Append new learnings to `.claude/memory/local/learnings.md`, merging with existing entries:
- Deduplicate similar learnings (update confidence if repeated)
- Remove learnings contradicted by new evidence
- Keep the file under 100 entries (archive oldest LOW confidence items)

## Output

Provide a concise reflection summary and confirm which learnings were persisted.
