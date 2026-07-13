---
name: learn-map
description: Generate a learning map (GUIDE.md) plus ISUCON/CTF-style exercise problem statements (README.md) and an empty STRUGGLE_LOG.md for a technology/topic — the "before" stage of the learning cycle where AI involvement is maximal but answers are NEVER produced. Use when the user says "学習ガイド", "入門ガイド", "ハンズオンを作って", "learn map", "learn guide", "この技術を学びたい", or wants a guided, output-oriented way to learn something. Successor of learn-guide.
triggers: ["学習ガイド", "入門ガイド", "ハンズオンを作って", "learn map", "learn guide", "この技術を学びたい", "勉強したい"]
user-invocable: true
allowed-tools: Read, Write, Bash, Glob, WebFetch, WebSearch
---

# /learn-map — Learning map + exercise problem statements (no answers)

Compress the learner's exploration cost to near zero, then hand them problems to solve
**by themselves**. AI involvement is at its maximum here (非対称原則 — AI full-on
before the learning, minimal during, full-on after), but with one hard boundary:

> **You draw the map and write the problem statements. You never write the answers.**

The old `/learn-guide` failed because its hands-on included "command + expected result +
why" — that is a 攻略本 (walkthrough), not a map. It allows copy-paste completion and
destroys desirable difficulty. Anything that would let the learner finish an exercise by
copy-pasting from your output must be cut.

## 1. Scope the map (ask if missing)
- **Topic**: the technology/concept to learn (e.g. "eBPF", "Pulumi", "OpenTelemetry traces").
- **Goal / why now**: shipping a feature, a case need, general depth — shapes scope.
- **Current level**: assume the user's background (SRE / インフラ / Go・Ruby・PHP・TS,
  Terraform/AWS/Kubernetes) unless told otherwise; calibrate prerequisites accordingly.
- **Time budget & depth**: quick orientation vs. multi-session deep dive.

## 2. Ground in primary sources (do not hallucinate)
- Use WebFetch/WebSearch to pull from official docs / source / specs. Prefer 1次情報.
- Verify version-specific facts against current docs; cite every external claim with its URL.
- Flag anything you could not verify as unverified rather than asserting it.

## 3. Build GUIDE.md — the map (Japanese)
A map orients; it does not walk the route. Sections (adapt depth to §1):
1. **前提知識** — what to already know; quick refreshers/links for gaps
2. **全体像** — the mental model in a few sentences + a `[ここに図: 〜]` placeholder
3. **概念** — core concepts, each defined then contrasted with what the user already knows
4. **よくある落とし穴** — pre-warn ONLY pitfalls costing 30+ min; describe the symptom and
   the general area, not the fix
5. **一次情報リンク** — official sources, cited, annotated with when to reach for each
- **No hands-on section. No command sequences with expected results.** Terminology and
  orientation only — the exercises below carry the doing.
- Japanese style: follow the **k16shikano 文章規範** in `skills/write-article/SKILL.md`
  (one sentence per line, concrete, sparse bold, no LLM-ish phrasing). Plain 常体 is fine.

## 4. Build README.md — exercise problem statements (ISUCON/CTF format)
2-4 exercises, difficulty ascending. Each exercise has EXACTLY these fields:

- **問題** — the situation and the task. State what exists and what must become true.
  Never how.
- **成功条件** — self-verifiable: a command the learner can run, an observable behavior,
  or a state they can check *without an answer key*. This is what makes completion
  judgeable with no answers anywhere.
- **制約** — what is off-limits (e.g. "managed サービスは使わない", "この設定ファイル以外
  は編集しない"). Constraints are what force the learning path.
- **学習境界** — what is learning vs. what is plumbing, per exercise. Environment setup
  outside the boundary may be automated/scaffolded; everything inside must be done by hand.
  Example: installing Postfix is not learning; configuring and debugging it is.

Sanity check before writing each exercise: could the learner verify success alone, and is
every hint of the solution absent from the problem statement? If not, rewrite.

## 5. Scaffold the workspace
- Create the working dir (ask for path, else `~/learn/<topic-slug>/`) with `mkdir -p`.
- Save `GUIDE.md` and `README.md` there.
- Scaffold ONLY what each exercise's 学習境界 marks as non-learning-target (setup scripts,
  docker-compose for dependencies, sample data). Do NOT scaffold anything inside the
  boundary. Do NOT run install/network commands automatically; show them for the user to run.
- Create an empty `STRUGGLE_LOG.md` with this template:

```markdown
# STRUGGLE_LOG — <topic>

外れた仮説も検閲せず残す。/write-article の一人称素材。

<!-- entry format (appended by /learn-coach or by hand):
## YYYY-MM-DD — 演習N: <一言サマリ>
- 症状:
- 立てた仮説と結果: (外れた仮説も全部書く)
- 使ったヒント: なし / L1 / L2 / L3 / L4
- 転機: (何を見て/何に気づいて動いたか)
- 解決と学び:
-->
```

## 6. Close the loop
- Print the workspace path and list the exercises with their 成功条件 one-liners.
- Remind the learner of the cycle: walk the exercises alone → when stuck, `/learn-coach`
  (hints are staged; struggles land in `STRUGGLE_LOG.md`) → after finishing,
  `/write-article` turns GUIDE.md + STRUGGLE_LOG.md into a personal-blog post, and
  `/learn` extracts reusable debugging patterns.
