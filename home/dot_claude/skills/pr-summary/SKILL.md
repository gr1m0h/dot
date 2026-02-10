---
name: pr-summary
description: Generate a comprehensive Pull Request summary with risk assessment
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[pr-number]"
---

## Pull Request Context

- PR metadata: !`gh pr view $ARGUMENTS --json title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,labels,reviewRequests 2>/dev/null || echo "Please specify a valid PR number"`
- PR diff: !`gh pr diff $ARGUMENTS 2>/dev/null || echo "No diff available"`
- PR comments: !`gh pr view $ARGUMENTS --comments 2>/dev/null || echo ""`
- PR checks: !`gh pr checks $ARGUMENTS 2>/dev/null || echo "No checks"`
- Linked issues: !`gh pr view $ARGUMENTS --json body 2>/dev/null | grep -oE '#[0-9]+' || echo "None"`

## Analysis Tasks

### 1. Change Classification

Categorize this PR:
- **Type**: feature / bugfix / refactor / docs / test / chore / security
- **Scope**: Which modules/components are affected
- **Size**: S (< 50 lines) / M (50-200) / L (200-500) / XL (500+)

### 2. Change Summary

- What problem does this PR solve?
- What approach was taken?
- What are the key implementation decisions?

### 3. Risk Assessment

| Risk Factor | Level | Details |
|------------|-------|---------|
| Breaking changes | LOW/MED/HIGH | [details] |
| Security impact | LOW/MED/HIGH | [details] |
| Performance impact | LOW/MED/HIGH | [details] |
| Test coverage | LOW/MED/HIGH | [details] |
| Rollback difficulty | LOW/MED/HIGH | [details] |

### 4. Review Focus Areas

Identify the most critical files/sections that reviewers should focus on, with specific line references and reasoning.

### 5. Missing Items Check

- [ ] Tests for new/changed behavior
- [ ] Documentation updates
- [ ] Migration steps (if breaking)
- [ ] Error handling for new paths
- [ ] Logging for observability

## Output Format

Provide the summary in a structured format suitable for posting as a PR comment.
