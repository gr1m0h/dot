---
name: create-pr
description: Analyze changes, generate a well-structured PR, and create it via gh CLI
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

Conventional Commits format, under 72 characters:

- `feat: Add user authentication flow`
- `fix: Resolve race condition in payment processing`
- `refactor!: Extract shared validation logic` (breaking)

### 3. Generate PR Body

```markdown
## Summary

<!-- 1-3 bullet points describing WHY this change was made -->

## Changes

<!-- Grouped by category with file references -->

### Added

- `path/file.ts`: Description

### Modified

- `path/file.ts`: Description

## Breaking Changes

<!-- List any breaking changes with migration steps, or "None" -->

## Test Plan

- [ ] Unit tests added/updated
- [ ] Integration tests verified
- [ ] Manual testing steps documented

## Security Considerations

<!-- Any security implications, or "None identified" -->

## Related Issues

<!-- Closes #123, Fixes #456 -->
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
