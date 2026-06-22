---
name: learn-guide
description: Generate a personalized learning guide (text + hands-on script) for a technology/topic, tuned to the user's level and case context — like an AI-personalized intro book. Use when the user says "学習ガイド", "入門ガイド", "ハンズオンを作って", "learn guide", "この技術を学びたい", or wants a guided, output-oriented way to learn something. Powers the learning half of learn_cycle.md.
triggers: ["学習ガイド", "入門ガイド", "ハンズオンを作って", "learn guide", "この技術を学びたい", "勉強したい"]
user-invocable: true
allowed-tools: Read, Write, Bash, Glob, WebFetch, WebSearch
---

# /learn-guide — Personalized learning guide + hands-on script

Produce a tailored "personalized intro book" for a technology/topic: a structured learning
path plus a runnable hands-on scaffold. The point is **output-driven learning** — learn by
doing and then publish small notes (高い定着率 + 速い学習速度), per `~/learn_cycle.md` L7.

## 1. Scope the guide (ask if missing)
- **Topic**: the technology/concept to learn (e.g. "eBPF", "Pulumi", "OpenTelemetry traces").
- **Goal / why now**: shipping a feature, a case need, general depth — shapes scope.
- **Current level**: assume the user's background (SRE / インフラ / Go・Ruby・PHP・TS,
  Terraform/AWS/Kubernetes) unless told otherwise; calibrate prerequisites accordingly.
- **Time budget & depth**: quick orientation vs. multi-session deep dive.

## 2. Ground in primary sources (do not hallucinate)
- Use WebFetch/WebSearch to pull from official docs / source / specs. Prefer 1次情報.
- Verify version-specific facts against current docs; cite every external claim with its URL.
- Flag anything you could not verify as unverified rather than asserting it.

## 3. Build the guide (Japanese)
Output a structured Markdown guide with these parts (adapt depth to §1):
1. **前提知識** — what to already know; quick refreshers/links for gaps
2. **全体像** — the mental model in a few sentences + a `[ここに図: 〜]` placeholder
3. **概念** — core concepts, each defined then contrasted with what the user already knows
4. **ハンズオン** — numbered, runnable steps; each step states the goal, the command/code, and
   the expected result, plus the *why* behind each decision
5. **演習** — 2-3 small exercises that force application (not just reading)
6. **よくある落とし穴** — pitfalls worth knowing (pre-warn only those costing 30+ min)
7. **次の一歩 + 1次情報リンク** — where to go deeper, with cited official sources
- Japanese style: follow the **k16shikano 文章規範** in `skills/write-article/SKILL.md`
  (one sentence per line, concrete, sparse bold, no LLM-ish phrasing). Plain 常体 is fine for
  a study guide; do not force the ぐりもお blog voice here.

## 4. Hands-on scaffold (runnable)
- Create a working dir (ask for path, else `~/learn/<topic-slug>/`) with `mkdir -p`.
- Write the minimal runnable scaffold the hands-on needs (scripts, config, sample code,
  a `README.md` that mirrors the ハンズオン steps). Keep commands copy-pasteable.
- Save the guide as `~/learn/<topic-slug>/GUIDE.md` (or the user's chosen path).
- Do NOT run install/network commands automatically; show them for the user to run.

## 5. Close the loop
- Print the guide path and the scaffold location.
- Remind: as you work through it, capture small notes — a fresh, small-granularity
  **personal-blog** post via `/write-article` is the 定着装置 in learn_cycle.md. If the
  learning came from a case, the generalized version can later become a `/company-blog` draft.
