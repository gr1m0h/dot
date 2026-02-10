---
name: manage-context
description: Audit and optimize context window usage, memory files, and session efficiency
user-invocable: true
allowed-tools: Read, Write, Grep, Glob, Bash
---

# Context Management

Analyze and optimize the current session's context usage and project memory.

## Dynamic Context

- Memory files: !`find .claude/memory -type f 2>/dev/null | head -20 || echo "No memory files found"`
- CLAUDE.md size: !`wc -l .claude/CLAUDE.md 2>/dev/null || echo "Not found"`
- Rules files: !`find .claude/rules -type f -name '*.md' 2>/dev/null | head -10 || echo "No rules found"`
- Skills count: !`ls -d .claude/skills/*/ 2>/dev/null | wc -l || echo "0"`
- Hooks: !`ls .claude/hooks/ 2>/dev/null | head -10 || echo "No hooks"`

## Tasks

### 1. Context Health Check

Analyze context window utilization:

- Count loaded files and estimate token consumption
- Identify oversized files that could be split or summarized
- Detect redundant information loaded from multiple sources
- Check for stale @file references in CLAUDE.md

### 2. CLAUDE.md Audit

Verify CLAUDE.md efficiency:

- Measure total size (target: < 2,000 tokens)
- Verify all @file references resolve correctly
- Identify inline content that should be moved to @references
- Ensure IMPORTANT: directives are current and necessary
- Check for duplicated information between CLAUDE.md and rules/

### 3. Memory Optimization

Review and optimize `.claude/memory/` contents:

- Archive completed task records to a dated archive
- Consolidate duplicate or overlapping learnings
- Update stale references and outdated patterns
- Remove session states older than 7 days
- Verify high-value memories (architecture, decisions) are accessible

### 4. Skills & Hooks Audit

Review `.claude/skills/` and `.claude/hooks/` health:

- Verify all SKILL.md frontmatter parses correctly
- Check that dynamic context commands in skills execute without errors
- Verify hooks are functional and not producing errors
- Identify unused or redundant skills

### 5. Session Recommendations

Based on analysis, provide actionable recommendations:

- Whether `/clear` should be run now
- Files to re-read vs. summarize after clearing
- Memory entries to archive or consolidate
- CLAUDE.md optimizations with specific edits
- Rules that could be merged or removed

## Output Format

## Context Management Report

### Current Status

| Metric                 | Value                        | Status   |
| ---------------------- | ---------------------------- | -------- |
| CLAUDE.md              | [X] lines / ~[Y] tokens      | ✅/⚠️/🔴 |
| Memory files           | [count] files / [size] total | ✅/⚠️/🔴 |
| Agent memory           | [count] entries              | ✅/⚠️/🔴 |
| Rules                  | [count] files                | ✅/⚠️    |
| Estimated context load | [LOW/MEDIUM/HIGH/CRITICAL]   | ✅/⚠️/🔴 |

### Issues Found

1. [Issue] → [Recommended action]

### Actions Taken

1. [Action performed and result]

### Recommendations

1. [Recommendation with rationale]
