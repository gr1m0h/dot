---
name: harness-audit
description: Audit Claude Code harness configuration for optimization opportunities, including system-prompt/token efficiency of CLAUDE.md and rules (absorbed the former prompt-optimize skill)
triggers: ["harness audit", "audit harness", "check setup", "optimize harness", "prompt optimize", "optimize prompt", "slim prompt", "reduce tokens"]
---

# Harness Audit

Comprehensive audit of Claude Code configuration quality.

## When to Use
- After initial setup or major configuration changes
- Periodically (monthly) to identify optimization opportunities
- When experiencing slow sessions or high costs
- Before starting a new project

## How It Works

1. **Read Configuration**
   - Parse `~/.claude/settings.json` (global)
   - Parse `~/.claude/CLAUDE.md` (instructions)
   - Scan `~/.claude/hooks/` (hook scripts)
   - Scan `~/.claude/rules/` (rule files)
   - Scan `~/.claude/skills/` (skill definitions)
   - Scan `~/.claude/agents/` (agent definitions)

2. **Score Dimensions** (0-100 each)
   - Token efficiency (model routing, compaction, thinking budget)
   - Security posture (permissions, hooks, secret protection)
   - Workflow coverage (skills, agents, commands for common tasks)
   - Hook quality (performance, error handling, coverage)

3. **Prompt/Token Optimization** (formerly the `prompt-optimize` skill — run this pass when CLAUDE.md exceeds ~3000 tokens, rules/ has 15+ files, or startup feels slow)
   - Measure: token counts of CLAUDE.md, rules files, agent/skill definitions → total system-prompt overhead
   - Identify waste: redundant instructions across files, prose that could be tables, rules overlapping Claude defaults, unused references
   - Optimize: merge similar rules, convert prose to tables/lists, delete default-behavior instructions, prefer cross-references over inline content
   - Targets: <2000 tokens for CLAUDE.md, <500 tokens per rule file; tables ≈ 3x more token-efficient than prose

4. **Generate Report**
   - Overall score with letter grade
   - Per-dimension breakdown
   - Prioritized recommendations (incl. before/after token counts when step 3 ran)
   - Quick wins highlighted

## Output Format

```
## Harness Audit Report

Overall: **B+ (82/100)**

| Dimension | Score | Grade |
|-----------|-------|-------|
| Token Efficiency | 90 | A |
| Security | 85 | B+ |
| Workflows | 75 | B |
| Hooks | 78 | B |

### Recommendations
1. [Quick Win] Add CLAUDE_CODE_SUBAGENT_MODEL=haiku
2. [Strategic] Add database-reviewer agent
3. [Nice-to-have] Add Rust/Go language rules
```
