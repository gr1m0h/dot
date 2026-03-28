---
name: prompt-optimize
description: Optimize Claude Code system prompt and instructions for token efficiency
triggers: ["prompt optimize", "optimize prompt", "slim prompt", "reduce tokens"]
---

# Prompt Optimize

Analyze and optimize CLAUDE.md and rules for token efficiency.

## When to Use
- CLAUDE.md exceeds 3000 tokens
- Rules directory has 15+ files
- Session startup feels slow
- Token costs are high

## How It Works

1. **Measure** current token count
   - Count CLAUDE.md tokens
   - Count all rules file tokens
   - Count agent/skill definition tokens
   - Calculate total system prompt overhead

2. **Identify Waste**
   - Redundant instructions across files
   - Verbose explanations that could be tables
   - Rules that overlap with Claude's defaults
   - Unused rule references

3. **Optimize**
   - Merge similar rules into single files
   - Convert prose to tables/lists
   - Remove instructions that match default behavior
   - Use @references instead of inline content

4. **Report**
   - Before/after token counts
   - Estimated cost savings per session
   - List of changes made

## Guidelines

- Target: <2000 tokens for CLAUDE.md
- Target: <500 tokens per rule file
- Prefer tables over prose (3x more token-efficient)
- Use cross-references (@rules/file.md) not inline content
