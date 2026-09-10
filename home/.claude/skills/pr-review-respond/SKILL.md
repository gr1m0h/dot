---
name: pr-review-respond
description: Read existing PR review comments (human reviewers, Copilot, other bots), evaluate each with a confidence score, apply fixes to the working tree, and generate draft reply texts. Use when user says "PR のレビュー対応", "レビュー指摘を対応", "指摘に対応", "pr review respond", "address review comments", or provides a PR number with review comments to address. NEVER auto-posts comments to GitHub — draft replies are printed to the user for manual posting.
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
argument-hint: "[pr-number]"
---

# PR Review Respond: #$ARGUMENTS

Consume review comments already posted on a Pull Request, evaluate each, apply fixes locally, and hand the user a decision table + draft reply texts. **This skill NEVER writes to GitHub** (no `gh pr comment`, no `gh api ... POST` to comments/reviews). All posting is left to the user, per the durable directive in `~/.claude/CLAUDE.md` (PR / Issue Communication Boundary).

## Dynamic Context

- PR metadata: !`gh pr view $ARGUMENTS --json title,state,baseRefName,headRefName,author,additions,deletions,changedFiles,url 2>/dev/null || echo "Please specify a valid PR number"`
- Current branch: !`git branch --show-current 2>/dev/null`
- Head branch of PR: !`gh pr view $ARGUMENTS --json headRefName --jq .headRefName 2>/dev/null`
- Review threads (top-level): !`gh pr view $ARGUMENTS --json reviews --jq '.reviews[] | {author: .author.login, state, body: (.body[:400] // ""), submittedAt}' 2>/dev/null | head -200 || echo ""`
- Inline review comments: !`gh api "repos/$(gh repo view --json owner,name --jq '.owner.login+"/"+.name')/pulls/$ARGUMENTS/comments" --paginate --jq '.[] | {id, author: .user.login, path, line: (.line // .original_line), commit: .commit_id, body: .body[:500], in_reply_to: .in_reply_to_id, created_at}' 2>/dev/null | head -400 || echo ""`
- Issue-level comments: !`gh api "repos/$(gh repo view --json owner,name --jq '.owner.login+"/"+.name')/issues/$ARGUMENTS/comments" --jq '.[] | {id, author: .user.login, body: .body[:400], created_at}' 2>/dev/null | head -100 || echo ""`
- Latest CI status: !`gh pr checks $ARGUMENTS 2>&1 | tail -20 || echo ""`

## Phase 1: Verify Branch & Sync

Before doing anything else:

1. Check that we are on the PR's head branch (`headRefName`). If not, offer to check it out. **Do not silently switch** — ask the user first.
2. Run `git status` to confirm working tree is clean. If uncommitted work exists, warn and stop.
3. `git pull` if the PR branch tracks a remote (avoid pushing a mid-review branch out of sync).

## Phase 2: Fetch & Structure Comments

Aggregate all comments into a single decision table. Sources:

- **Inline comments** (`repos/{owner}/{repo}/pulls/{N}/comments`) — most reviewer feedback lives here, tied to file+line
- **Review bodies** (`reviews[].body`) — summary comments attached to formal reviews
- **Issue-level comments** (`issues/{N}/comments`) — general discussion

For each comment, extract:

| Field | Source |
|---|---|
| `id` | comment id (for reply threading) |
| `author` | reviewer login (skip resolved bot noise? — see Filter Rules below) |
| `path` | file path (inline only) |
| `line` | line number in the diff (inline only) |
| `body` | full comment body (do not truncate for evaluation) |
| `in_reply_to` | thread parent id (skip replies in first pass) |
| `resolved` | GraphQL `isResolved` if fetched; otherwise `unknown` |

### Filter Rules

- Skip comments authored by the current user (`gh api user --jq .login`) — these are usually author's own replies or CI notes.
- Skip comments in threads already marked resolved on GitHub. Optionally fetch resolution state via:
  ```
  gh api graphql -f query='{ repository(owner:"X",name:"Y"){ pullRequest(number:N){ reviewThreads(first:100){ nodes{ isResolved comments(first:1){ nodes{ databaseId } } } } } } }'
  ```
- Deduplicate replies within the same thread — keep only the leaf reviewer ask.

## Phase 3: Evaluate Each Comment

For every comment, produce a structured evaluation. **Do this by reading the referenced file/line first**, not from the comment body alone. Never trust the reviewer's claim without verification (see `.claude/CLAUDE.md` → "Verification Before Claims").

Output per comment:

```
### [C#] {short title in Japanese if PR is Japanese, else English}
- **File**: `path/to/file.ts:L42`
- **Reviewer**: @login
- **指摘要旨** (paraphrased in <= 2 sentences)
- **verify** (what did you Read/Grep to confirm the reviewer's premise?)
- **判定**: 対応する / 対応不要 / 要議論
  - 信頼度: 0.0–1.0
  - 根拠 (1–3 sentences)
- **修正方針** (if 対応する): concrete diff summary
- **draft reply** (Japanese if PR is Japanese, plain text, 2–4 sentences)
```

### Judgment Categories

- **対応する** — the concern is valid and can be fixed with a local change
- **対応不要** — the concern is based on a false premise, or is a style opinion the project has explicitly rejected in `.claude/rules/*`
- **要議論** — needs clarification from the reviewer, or has a design trade-off that should not be silently resolved

### Confidence Calibration

| Signal | Confidence delta |
|---|---|
| Verified via `Read` + `Grep` | +0.3 |
| Cross-checked against `.claude/rules/*` or CLAUDE.md | +0.2 |
| Reviewer is a domain owner (from CODEOWNERS) | +0.1 |
| Reviewer is a bot (Copilot, etc.) without file context | −0.2 |
| Concern requires runtime verification (not done here) | −0.3 |

Report confidence honestly per `.claude/rules/cognitive/uncertainty-expression.md`.

## Phase 4: Apply Fixes

For each comment with 判定 = **対応する** and 信頼度 ≥ 0.6:

1. Read the target file(s) immediately before Editing (never act on a stale snapshot — CLAUDE.md rule).
2. Apply the minimal change (project convention > personal preference).
3. If the change spans > 5 files, pause and confirm approach with the user before continuing (CLAUDE.md rule: "Batch-editing 10+ files: pause after 3-5 edits").
4. Never bundle unrelated cleanups — one comment ⇒ one focused edit set.

After all edits:

- `yarn type-check` / language-appropriate compile check
- `yarn lint-check` if fast
- `yarn prettier-check`
- Run the affected spec files if any (do not run the full suite by default — too slow, let CI handle)

If any check fails, iterate on the specific failure. Do not commit yet.

## Phase 5: Commit & Push (Optional, User-Directed)

Only commit when the user explicitly asks. Suggested commit message format:

```
fix(<scope>): address review comments (#<pr-number>)

- [C1] <short summary> (@<reviewer>)
- [C2] <short summary> (@<reviewer>)
```

Push if requested. **Do not post any comment on GitHub** — the user will do that manually.

## Phase 6: Output — Decision Table + Draft Replies

At the end, print two sections to the user:

### A. Decision Table

| # | File:Line | Reviewer | 判定 | 信頼度 | Action |
|---|---|---|---|---|---|
| C1 | `src/x.ts:42` | @foo | 対応する | 0.85 | Edit applied to L42 |
| C2 | `src/y.ts:10` | @bar | 対応不要 | 0.7 | Explanation in draft reply |
| C3 | — (thread) | @baz | 要議論 | 0.4 | Question drafted |

### B. Draft Replies (Manual Post)

For each comment, provide a copy-pasteable draft. Group by comment id so the user can navigate the PR page and paste each reply on the corresponding thread.

```
---
[C1] path/to/file.ts:42
Reply-to: <comment-id>
Draft (paste on GitHub):
> ご指摘ありがとうございます。〜のため、〜のように修正しました。commit <sha> で反映しています。
---
[C2] path/to/other.ts:10
Reply-to: <comment-id>
Draft (paste on GitHub):
> こちらは意図的に〜としています。理由は〜のため、現状の実装を維持したいです。
---
```

## Guardrails (Do NOT do these)

- **Do NOT** run `gh pr comment`, `gh pr review --body`, `gh api POST .../comments`, or any variant that writes to GitHub review threads. These are also denied in `~/.claude/settings.json`.
- **Do NOT** mark reviewer threads as resolved via GraphQL — that is a review-conversation state change owned by the author, not by an agent.
- **Do NOT** rewrite the PR description without an explicit user request (allowed by CLAUDE.md if asked, but not automatic).
- **Do NOT** force-push. Regular `git push` is fine after commit.
- **Do NOT** delete or amend commits already on the remote — always create new commits.
- **Do NOT** silently switch branches. Ask before checkout.

## Notes

- **Language matching**: If the PR is written in Japanese (Description / most comments in JP), produce evaluations and draft replies in Japanese. Otherwise use English.
- **CI signals**: If `run-test-*` is failing in the latest CI, prioritize fixing those failures before addressing style-level review comments.
- **Bot noise**: Copilot / dependabot / renovate comments are often mechanical suggestions. Evaluate on merit — many are valid, some are noise. Do not skip categorically.
- **Draft-only replies**: The output draft replies must be plain markdown text, not `gh` commands. The user pastes them into GitHub manually.
