---
name: create-pr
description: Analyze changes, generate a well-structured PR, and create it via gh CLI. Use when user says "create PR", "open pull request", "submit PR", or after completing a feature branch. Includes summary, risk assessment, and test plan.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[base-branch]"
---

# Create Pull Request

Create a high-quality Pull Request for the current branch.

## Dynamic Context

- Current branch: !`git branch --show-current 2>/dev/null`
- Base branch: !`echo "${ARGUMENTS:-$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main)}"`
- Changed files: !`git diff --name-status origin/main...HEAD 2>/dev/null || git diff --name-status origin/master...HEAD 2>/dev/null || echo "N/A"`
- Commit history: !`git log --oneline origin/main...HEAD 2>/dev/null || git log --oneline origin/master...HEAD 2>/dev/null || echo "N/A"`
- Diff stats: !`git diff --stat origin/main...HEAD 2>/dev/null || git diff --stat origin/master...HEAD 2>/dev/null || echo "N/A"`

## Process

### 1. Analyze Changes

- Read all diffs and commit messages thoroughly
- Categorize changes: feature / fix / refactor / docs / test / chore
- Identify breaking changes and affected modules
- Detect linked issues from commit messages or branch name

### 2. Generate PR Title

Conventional Commits format, in English, under 70 characters:

- `feat: Add user authentication flow`
- `fix: Resolve race condition in payment processing`
- `refactor!: Extract shared validation logic` (breaking)

### 3. Generate PR Body

Same structure as the `/pr-summary` output (keep the two skills aligned — if one template changes, update the other):

```markdown
| Field | Value |
|-------|-------|
| Type | feature / bugfix / refactor / docs / test / chore / security |
| Scope | affected modules/components |
| Size | S (< 50 lines) / M (50-200) / L (200-500) / XL (500+) |

## What

1-2 sentence description of what this PR does.

## Why

1-2 sentence description of the problem being solved.

## How

Key implementation decisions and approach taken.

## Risk Assessment

| Risk Factor | Level | Details |
|:--|:--|:--|
| Breaking changes | LOW/MED/HIGH | details (with migration steps if any) |
| Security impact | LOW/MED/HIGH | details |
| Performance impact | LOW/MED/HIGH | details |
| Test coverage | LOW/MED/HIGH | details |
| Rollback difficulty | LOW/MED/HIGH | details |

## Review Focus Areas

| File | Lines | Reason |
|:--|:--|:--|
| `path/to/file.ts` | L10-L25 | reason to focus here |

## Checklist

- [ ] Tests for new/changed behavior
- [ ] Documentation updates
- [ ] Migration steps (if breaking)
- [ ] Error handling for new paths
- [ ] Logging for observability

## Related Issues

<!-- Closes #123, Fixes #456, or "None" -->
```

### 4. Create PR

- Push current branch to remote if not already pushed
- Run `gh pr create` with the generated title and body
- Set labels based on change type (feature, bugfix, etc.)
- Add reviewers if CODEOWNERS or team conventions exist

### 5. Post-Creation

- Verify the PR URL is accessible
- Report CI status if available
- Display the PR link
