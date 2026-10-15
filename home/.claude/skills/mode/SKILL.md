---
name: mode
description: Switch the session to Learning mode — give the map, not the answer; never write final solution code. Use when the user says "/mode learning", "Learning", "学習モード", "勉強モード", or starts a study session in a personal repo. The switching criterion is time-and-place (client work = Speed, study time = learning), not task type. Speed (default, full velocity) resumes when the user says "Speed".
user-invocable: true
argument-hint: "[learning]"
---

# Session mode

Two positions only. The switching criterion is **time and place, not task type**:

| Context | Mode |
|---|---|
| Work (client repos, deliverables) | **Speed** — default, no skill needed, max velocity |
| Study time (personal repos, `~/learn/`, night study) | **learning** — this skill |

There is no in-between mode. If the user wants a collaborative style during work
("I'll write the skeleton, you fill in details", "show me options first"), treat it as an
ad-hoc instruction for that task — do not enter a mode.

The mode persists for the rest of the session until the user says "Speed".

## /mode learning

The user learns by doing; your job is orientation, not answers. **Never write the final solution code.**

- **Before**: give reference URLs / doc sections to research — not approaches, not answers.
  If multiple approaches exist, name them; let the user choose what to investigate.
- **During**: review-mode — react to what the user writes, don't pre-write it. Escalating
  hints, one level per turn: reference → approach → pseudocode → code fragment. Pre-warn
  only pitfalls that would cost 30+ minutes; let cheap mistakes happen.
- **After**: surface 2-3 adjacent concepts + the reusable pattern extracted from what was built.

## Routing — which learning tool when

| Situation | Use |
|---|---|
| Study session in a personal repo | `/mode learning` (this skill) |
| Starting a new technology from scratch | `/learn-map` (generates GUIDE.md + exercises + STRUGGLE_LOG.md), then work under `/mode learning` |
| Stuck on a `/learn-map` exercise | `/learn-coach` — its L1-L4 hint ladder and STRUGGLE_LOG recording **supersede** the generic hint behavior above while working exercises |
| Session produced something worth persisting | `/reflect` (retrospective) or `/learn` (pattern → skill) |

Relationship in one line: `/mode learning` is the session **stance**, `learn-map` is the material
**generator**, `learn-coach` is the specialized **in-exercise coach**.

## Exit

Revert to Speed (default, full velocity) when the user says "Speed".
