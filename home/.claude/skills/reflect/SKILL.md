---
name: reflect
description: Structured reflection on completed work using the Reflexion framework. Use when user says "reflect", "session review", "what did I learn", "extract pattern", "save this technique", or after completing a complex task / solving a non-trivial problem. Extracts persistent learnings, and skill-ifies reusable patterns to ~/.claude/skills/learned/ (absorbed the former /learn default verb, 2026-08).
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

### 6. Skill-ify Reusable Patterns (absorbed from the former /learn, 2026-08)

For learnings that should AUTO-FIRE in future sessions (error resolutions, debugging
techniques, workarounds, integration patterns — not one-time issues or trivial fixes),
additionally create a skill file at `~/.claude/skills/learned/[pattern-name].md`:

```markdown
# [Descriptive Pattern Name]

**Extracted:** [Date]
**Context:** [Brief description of when this applies]

## Problem
[What problem this solves - be specific]

## Solution
[The pattern/technique/workaround]

## Example
[Code example if applicable]

## When to Use
[Trigger conditions - what should activate this skill]
```

Rules: one pattern per file; ask user to confirm before saving; client-repo sessions must
be generalized (no customer names / private repo names). This is also the canonical format
for pattern candidates harvested by the weekly retro-learn task (saved via `/learn review`).

## Output

Provide a concise reflection summary and confirm which learnings were persisted (memory entries and/or skills/learned/ files).
