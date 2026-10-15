---
name: deepwork
description: Serial deep-work pull flow for large 🟡🔴 client tasks (investigate → understand → hands-on). The human works ONE task at a time (WIP=1); machine parallelism is confined to warming that single task. Use when the user says "deepwork", "深堀り", "タスクを引く", "pull", "次のタスク", "深い作業", or starts a focused deep-work block on a substantial client task. NOT for mechanical rubber-stamp tasks — those go to /batch.
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, Skill, AskUserQuestion
argument-hint: "[pull (default) · prefetch <task> · status · done]"
---

# deepwork

The serial half of the work engine. `batch` fans **rubber-stamp-reviewable** tasks out horizontally; `deepwork` pulls ONE large **deep-engagement** task and keeps the human in the loop through it.

## Why this exists (READ FIRST)

For substantial client SRE work the deliverable value comes from the human actually understanding the system and making judgement calls — "read report → investigate → understand → hands-on". That is deep work: it cannot be rubber-stamped, and it cannot be truly parallelised in one head (context-switch tax + attention residue, ~15–23 min re-immersion per switch). So the governing principle:

> **Parallelism belongs to the machine; seriality belongs to the human.**
> The machine may fan out — but only to warm the ONE task the human is about to touch. It must never surface to the human as "think deeply about N tasks at once".

Consequences:
- **WIP = 1.** The human holds exactly one active deep task. A second `pull` is refused until `done`. (A task in handoff/review may coexist; only one is in active hands-on.)
- **Machine parallelism is confined to a single task** (prefetch fan-out), never spread across many tasks the human then juggles.
- **The human stays engaged.** This is NOT batch's fire-and-forget. deepwork prepares a *warm start*, then the human does the deep work in the main session.

## Routing gate (batch vs deepwork)

The axis is **how deep the human's review/engagement must be**, not the raw task size:
- Review is a **rubber-stamp** (mechanical change, "agent prepared the diff, human glances + approves publish", "agent drafted the message, human sends") → **`/batch`** (horizontal fan-out).
- Review is itself **deep work** (must read → understand → make judgement → hands-on; cannot rubber-stamp) → **deepwork** (this skill).

If a task pulled here turns out to be rubber-stamp-shallow → redirect to `/batch`; do not occupy WIP with it.

## State: the WIP lock

`~/.claude/deepwork/active.md` holds the current active task (front-matter: `case`, `task`, `pulled`, `phase`, `report`). Its presence = WIP is taken.
- `pull` refuses if an unfinished active task exists — surface it and tell the user to `done` first (or explicitly override).
- The session-start hook surfaces the active task every session (`DEEPWORK_WIP` line).
- Create the dir on first write (`mkdir -p ~/.claude/deepwork`). This tree is runtime state (not synced to dotfiles).

## Verb: `pull` (default)

Pull ONE deep task into active deep work.

1. **WIP guard**: if `~/.claude/deepwork/active.md` exists and its `phase` ≠ `done` → STOP. Show the active task + "WIP=1: 先に `/deepwork done` を。別タスクに切り替えるなら明示的に指示を". Do not pull a second task.
2. **Pick the task**: from the argument, else from the deep (🟡🔴) entries in `~/.claude/batch/inbox.md` — present the candidates and let the user choose exactly one (AskUserQuestion).
3. **Intake grill** (kills wrong_approach up front — the #1 friction): run a short brainstorming-style interrogation. Prefer invoking the `brainstorming` skill; otherwise ask 3–5 targeted questions covering **scope (in/out) · success criteria (done = ?) · hard constraints · known pitfalls · the one decision the user is least sure about**. Pin the answers as the spec. Do NOT start fan-out until the user confirms the spec.
4. **Prefetch fan-out (warm the report)**: delegate fact-gathering *for this one task only* to subagents via the `investigation-report` engine — repo/infra scan, evidence collection, read-only mechanical checks, claim verification. Produce a warm report the human can start from. Confine all parallelism to this task; never touch other tasks. Same write boundary as batch: agents read/verify/draft, **never push/PR/comment/apply**.
5. **Write the WIP lock**: `~/.claude/deepwork/active.md` (`case`, `task`, the confirmed spec, `phase: understanding`, `report:` path).
6. **Hand off to the human**: present the warm report and stop. The human now does the deep work — read → understand → hands-on — engaged, in the main session. deepwork does **not** auto-implement deep 🟡🔴 changes; it accelerates understanding, the human makes the calls.

## Verb: `prefetch <task>` (JIT next-task warming)

Fire when the active task is ~80% done, to warm the NEXT task's report **without taking WIP**. Runs step-4's fan-out only and writes the report to `~/.claude/deepwork/prefetch/<slug>.md`. Does NOT create the WIP lock (the human is still on the current task). When the human later `pull`s that task, the warm report is already waiting → the next deep block starts warm instead of cold. This is how throughput scales on serial work: overlap the *machine's* prep with the *human's* current focus, never the human's focus with itself.

## Verb: `status`

Show the active WIP task (`phase`, how long held) + any prefetched-but-not-yet-pulled reports under `prefetch/`. If the active task looks stalled (held many days with no phase progress), say so plainly and suggest decomposing or `done`-ing it.

## Verb: `done`

Close the active task: confirm success criteria met (from the pinned spec), record the artifact — for client repos suggest `/sreaas:task report` — then clear `~/.claude/deepwork/active.md` (archive the line to `~/.claude/deepwork/log-YYYY-MM-DD.md`). WIP is now free; the user may `pull` the next task (or the one already prefetched).

## Principles (always)

- **WIP=1 is the whole point.** Never let the human hold two active deep tasks. If they insist, make it an explicit, acknowledged override — never a silent default.
- **Spec before fan-out.** The intake grill runs before any subagent work. wrong_approach is the #1 friction and it is cheapest to kill at intake — one approval round beats five correction rounds.
- **No writes from prefetch agents.** pushes / PRs / comments / apply stay human-gated in the main session (same boundary as batch — see `~/.claude/docs/batch-permissions.md`).
- **Warm, don't finish.** Prefetch prepares understanding; the human does the judgement. deepwork is an accelerator, not an autopilot.
