---
name: release
description: Automate semantic versioning, changelog generation, and release creation
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
context: fork
agent: oss-contributor
argument-hint: "[major|minor|patch] or [version]"
---

Create a new release for this project.

## Context

Current version:
!`cat package.json 2>/dev/null | grep '"version"' | head -1 || cat Cargo.toml 2>/dev/null | grep '^version' | head -1 || cat pyproject.toml 2>/dev/null | grep '^version' | head -1 || echo "version not found"`

Recent changes since last tag:
!`git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~20")..HEAD --oneline 2>/dev/null || echo "no git history"`

## Release Type: $ARGUMENTS

## Process

1. **Determine Version** - Based on argument (major/minor/patch) or explicit version
2. **Generate Changelog** - Categorize commits since last release (Added/Changed/Fixed/Removed/Security)
3. **Update Version** - Bump version in all manifest files
4. **Update CHANGELOG.md** - Prepend new version entry
5. **Create Release Commit** - `chore(release): vX.Y.Z`
6. **Create Git Tag** - `vX.Y.Z`
7. **Summary** - Show release notes preview
