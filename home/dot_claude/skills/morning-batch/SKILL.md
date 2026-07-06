---
name: morning-batch
description: Morning dispatch — read queued tasks from ~/batch/inbox.md, fix each task's spec contract, fan them out to background subagents per case, and leave the user free until review time. Also surfaces unreported client sessions (~/batch/unreported.md). Use when the user says "morning batch", "朝バッチ", "タスク投入", "/morning-batch", or at the start of a work day with queued tasks.
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, Skill
argument-hint: "[dispatch (default) | status | add <case>: <task>]"
---

# morning-batch

Turns the working day into "invest 15 min in the morning, review at noon and evening". The user's role is dispatcher/reviewer, not implementer.

## Files

- `~/batch/inbox.md` — task queue. One task per line under `## Queue`:
  `- [ ] <case>: <task> | 成果物: <format> | 完了条件: <criteria>`
  (`成果物`/`完了条件` may be omitted; see Phase 1.)
- `~/batch/log-YYYY-MM-DD.md` — dispatch log for the day
- `~/batch/unreported.md` — sessions in tracked orgs (`~/.claude/tracked-orgs.txt`) that ended without leaving a report (appended by the SessionEnd hook; client orgs use the sreaas marker, personal orgs can use reflect/learn)
- `~/batch/kpi.md` — weekly KPI table (appended by sreaas-draft weekly)

## Verb: `dispatch` (default)

1. Read `~/batch/inbox.md`. If empty, say so and stop (do not invent work).
2. **Contract check**: for tasks missing 成果物 or 完了条件, infer them when obvious from the task text; otherwise collect ALL open questions into ONE AskUserQuestion round (batched — never one question per task).
3. **Dispatch**: for each task, spawn a background subagent (`run_in_background: true`; `general-purpose`, or `Explore` for pure investigation):
   - Prompt = task + 成果物 + 完了条件 + "write the deliverable to `~/batch/out/YYYY-MM-DD-<case>-<slug>.md`" (for code tasks: work in the case repo, prepare a branch + diff, do NOT push or open PRs)
   - **Machine verification is mandatory**: every dispatch prompt must include "run the repo's mechanical checks (test / lint / `terraform|tofu plan` as applicable) and attach the results to the deliverable; a deliverable without verification output is incomplete"
   - Model routing (cost/limit stretching): `Explore`+haiku for lookups and inventory scans, sonnet for implementation and report drafting; reserve the default (inherited) model for tasks needing judgment
   - Client-repo policy applies: no GitHub writes from background agents, ever. Artifacts land locally for human review.
   - Independent tasks are dispatched in a single message (parallel). Tasks in the SAME repo working tree must use `isolation: "worktree"` or run sequentially.
4. Mark dispatched tasks `- [~]` in inbox with agent IDs; write `~/batch/log-YYYY-MM-DD.md` (task → agent ID → expected artifact path).
5. If `~/batch/unreported.md` is non-empty, list its entries and propose `/sreaas-draft apply` or per-session `/sreaas:task report`.
6. Final message: dispatch table (case / task / agent ID / artifact path) + "レビューは昼と夕方に" reminder. Then stop — do not babysit the agents.

## Verb: `status`

Check background task outputs (TaskOutput / artifact files under `~/batch/out/`), summarize per task: done (artifact path) / running / failed (reason). Mark finished tasks `- [x]` in inbox and move their line to the day's log.

## Verb: `add <case>: <task>`

Append to `## Queue` in inbox (create the contract fields inline if given). No dispatch.

## Notes

- Friday variant: after dispatch, remind the user to queue next week's tasks (金曜仕込み — prevents the Monday rush).
- Never dispatch more than 6 concurrent background agents; queue the rest and say so.
