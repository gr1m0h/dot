# Batch Permission Scoping

How background batch workers are constrained. Referenced by `~/.claude/skills/batch/SKILL.md`.

## Principle

**Security boundary = writes.** Read and verify are granted broadly so agents self-serve
facts and run mechanical checks unattended. Writes (git push, PR/Issue create/comment,
`apply`/state mutation) are denied to agents and gated behind human approval.

The enforcement is layered (most reliable first):

1. **Hard deny (all sessions)** — `permissions.deny` in `~/.claude/settings.json`.
   Truly-never ops: `git push --force*`, `git reset --hard`, `git clean -fd`,
   PR/Issue comment POSTs (`gh pr comment`, `gh pr review`, `gh api .../comments|replies -X POST`),
   reading `**/.aws/*`.
2. **Human gate via `ask` (all sessions)** — writes that a *present human* may approve but a
   *headless background agent cannot* (no approver ⇒ effectively blocked):
   `git push`, `gh pr create`, `tofu|terraform apply|destroy|state|import`,
   `kubectl apply|delete`. This is the key mechanism: the same rule that prompts you in the
   main session auto-blocks background workers.
3. **Restricted agent type** — batch dispatch prefers the `batch-worker` agent
   (`~/.claude/agents/batch-worker.md`): no `Agent` tool (no recursive fan-out), tools scoped to
   read + local write + Bash-for-checks. Defense-in-depth on top of (1)(2).
4. **Skill prompt** — every dispatch prompt states "no push / PR / comment — ever; prepare a
   branch + diff locally". Weakest layer, but reinforces the rest.

## What background agents MAY do (self-serve, no human)

- Read the repo; `gh` read-only (`pr view/checks/diff`, `run view`, `issue view`, `api` GET).
- Read-only network to package/registry sources for fact-checking (versions, provider metadata).
- Mechanical checks: `test` / `lint` / `tofu fmt` / `tofu validate` / config validators
  (`renovate-config-validator`), and `tofu plan` **via the read-only plan role** (below).
- Write **local artifacts only**: the deliverable under `~/.claude/batch/out/`, and a prepared
  branch + commit in a worktree (commit is local; push is blocked).
  Enforced by `Write/Edit(~/.claude/batch/out/**)` in `permissions.allow` (added 2026-08-06 —
  without it, `defaultMode: "default"` prompts on Write and headless agents are auto-denied).

## What background agents MUST NOT do

- `git push`, `gh pr create`, any PR/Issue comment or review, merge/close.
- `tofu|terraform apply`, `destroy`, `state`, `import`; any state/backend mutation.
- Read secrets (`.aws`, `*.pem`, `*.key`, `.env*`), spawn sub-agents, install global tooling.

## `tofu plan` read-only role (closes the biggest autonomy gap)

The recurring "agent can't verify infra changes" gap is because `tofu plan` needs credentials.
`plan` is **read-only** (no state mutation) → safe to grant. For tfaction repos a plan-only
assume-role already exists (e.g. `GitHubActions_Terraform_opentofu_terraform_plan`). Provide a
**local read-only credential path** scoped to that role so background agents can run
`tofu plan` unattended and attach real plan output to the deliverable. Never provide apply/state
credentials to agents.

Status: **recommended, not yet provisioned.** Until then, agents fall back to
`fmt`/`validate`/lint and must state "plan 未検証（認証なし）" in the 機械検証 section.

## Human-gated publish

Writes happen only via the batch `publish` verb, run in the **main session** (human present),
which trips the `ask` prompts above. **Every write is preceded by a plain-language intent line**
(何を・なぜ・影響範囲) — a bare shell/gh command is never the thing approved; the sentence is.
