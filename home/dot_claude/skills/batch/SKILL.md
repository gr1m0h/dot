---
name: batch
description: Batch dispatch — read queued tasks from ~/.claude/batch/inbox.md, fix each task's spec contract, fan them out to background subagents per case, and leave the user free until review time. Also surfaces unreported client sessions (~/.claude/batch/unreported.md). Use when the user says "batch", "morning batch", "朝バッチ", "タスク投入", "/batch", "/morning-batch", or at the start of a work day with queued tasks.
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, Skill
argument-hint: "[dispatch (default) | status | publish <task> | add <case>: <task>]"
---

# batch

Turns the working day into "invest 15 min in the morning, review at noon and evening". The user is dispatcher/reviewer, not implementer.

## Operating model (READ FIRST)

The goal is **"dispatch → go do other work → come back to a decision-ready package"**, NOT "come back to something half-done that keeps interrupting you". To make that real:

- **Background agents prepare up to a decision point; they never publish.** A deliverable is a *reviewable package* (branch + diff + verification + recommendation + the explicit human calls), not a merged change. Writes (push / PR / comment / apply) happen only through the human-gated `publish` verb.
- **Surface every judgment call in the deliverable, never mid-run.** If a task forks (approach A vs B, ambiguous requirement, irreversible/business/customer decision), the agent explores *all* branches and presents them with a recommendation — it does not stall waiting for a human. Interrupting the human belongs at the single review gate, not scattered through the run.
- **Security boundary = writes.** Read and verify are granted broadly (so agents self-serve facts and run checks); writes are denied to agents and gated behind human approval. See `~/.claude/docs/batch-permissions.md`.

### Task triage (decide BEFORE queuing)

- 🟢 **Fully autonomous** — mechanical / well-specified (dep bump, lint/fmt fix, lockfile regen, inventory scan, investigation report). Fire-and-forget; review is a rubber stamp.
- 🟡 **Prep + one approval** — code change that needs a human `go` before publishing (config fix, targeted refactor). Agent prepares branch+diff+verification locally; human approves; `publish` opens the PR.
- 🔴 **Not for autonomous completion** — the *essence* is a human/customer/irreversible decision (delete infra, force a breaking migration, close someone's PR). **Still automate everything up to the decision**: investigate → analyze → lay out options with trade-offs → **draft the client/stakeholder confirmation message**. Hand the human a ready-to-send message + a recommendation, not a blank page.

The mistake is loading 🔴/🟡 tasks and expecting 🟢 hands-off behavior. Triage first; most friction is a mis-triaged task.

## Deliverable contract (mandatory)

Every dispatched task writes ONE Markdown file to `~/.claude/batch/out/YYYY-MM-DD-<case>-<slug>.md` with these sections:

1. **要約** — what was done, in 2-3 sentences.
2. **調査/根拠** — findings with evidence (paths, logs, doc links); mark unverified points "未確認仮説".
3. **成果物** — for code: branch name + diff summary (prepared locally, NOT pushed). For investigation: the report body.
4. **機械検証** — commands run + output. A deliverable without verification output is **incomplete**. Use the checks the agent *can* run autonomously (test / lint / `tofu fmt`/`validate` / `tofu plan` via the read-only plan role / config validators). State explicitly what could not be verified and why.
5. **判断が要る点（人間の関門）** — every open decision, each with: options, trade-offs, and a **推奨 (recommendation)**. This is where 🟡/🔴 decisions live. Empty for clean 🟢 tasks.
6. **公開手順（あれば）** — the exact `publish` action proposed (branch, PR title, draft?), phrased so the human can approve at a glance.

## Verb: `dispatch` (default)

1. Read `~/.claude/batch/inbox.md`. If empty, say so and stop (do not invent work).
2. **Contract + triage check**: fill missing 成果物/完了条件 when obvious; assign a triage color. Collect ALL genuinely-blocking open questions into ONE AskUserQuestion round (batched — never one per task). Do NOT ask about things the agent can investigate itself — those become deliverable sections.
3. **Dispatch**: spawn a background subagent (`run_in_background: true`) per task. Prefer the restricted `batch-worker` agent type when available (see permissions doc); else `general-purpose` / `Explore`.
   - Prompt = task + full deliverable contract (the 6 sections above) + artifact path.
   - For code tasks: "work in the case repo, prepare a branch + diff, **run mechanical checks and attach output**, do NOT push / open PRs / comment — ever."
   - For 🔴 tasks: "do not attempt to complete; produce the options analysis and a ready-to-send client/stakeholder confirmation message draft in the 判断が要る点 section."
   - Model routing: `Explore`+haiku for lookups/inventory, sonnet for implementation/report drafting; reserve the inherited model for judgment-heavy analysis.
   - Independent tasks → single message (parallel). Same repo working tree → `isolation: "worktree"` or sequential.
4. Mark dispatched tasks `- [~]` in inbox with agent IDs; append to `~/.claude/batch/log-YYYY-MM-DD.md` (task → agent ID → artifact path → triage color).
5. If `~/.claude/batch/unreported.md` is non-empty, list entries and propose `/sreaas:task report` (or `report all`).
6. Final message: dispatch table (case / task / triage / agent ID / artifact) + "レビューは昼と夕方に". Then stop — don't babysit; use `status` later.

## Verb: `status`

Check artifacts under `~/.claude/batch/out/` (and TaskOutput). Per task: done (artifact path + a one-line "判断が要る点" count) / running / failed (reason + whether partial output exists). Mark finished tasks `- [x]`, move their line to the day's log. For failed/stalled agents, note it and suggest re-dispatch as smaller sub-tasks.

## Verb: `publish <task>` (human-gated writes)

The only path that performs GitHub/infra writes. Runs in the MAIN session (human present), never from a background agent.

1. Read the task's deliverable. Confirm 機械検証 passed and 判断が要る点 are resolved (if any 🔴 decision is unresolved, stop and surface it — do not publish).
2. **Before every write action, state in plain language what it will do and why** (e.g., "energy 23テナントの再apply用に、23 dir に無害なコメントを足した内容を `topotal/reapply-566` ブランチとして push し、draft PR を作成します。infra は変更しません"). Never present a bare shell/gh command for approval without this natural-language intent line.
3. Execute the prepared branch push + `create-pr` (draft unless told otherwise). Report the PR URL.
4. Never auto-close others' PRs, comment on PRs/Issues, or run `apply`/state ops — those stay explicit human actions.

## Verb: `add <case>: <task>`

Append to `## Queue` in inbox (with 成果物/完了条件 inline if given). No dispatch.

## Principles (always)

- **No GitHub/infra writes from background agents, ever.** Enforced by the restricted agent type + hooks; also stated in every dispatch prompt.
- **Natural-language intent on every approval.** Any action put in front of the human for a yes/no — especially shell/gh/tofu commands — is preceded by a plain-language "何を・なぜ・影響範囲" line. Commands alone are hard to judge; the sentence is the thing being approved.
- **Investigate before asking.** Facts the agent can fetch (versions, registry data, logs, config validity) are never questions to the human.

## Notes

- Friday variant: after dispatch, remind the user to queue next week's tasks (金曜仕込み).
- Never dispatch more than 6 concurrent background agents; queue the rest and say so.
- Stall handling: if an agent produced no artifact, treat as failed; re-dispatch decomposed (e.g. "collect logs" → "diagnose" → "prepare fix") — smaller tasks stall less and leave partial value.
