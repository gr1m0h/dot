---
name: investigation-report
description: Standardized "investigate → written report" pipeline for SRE client work. Fixes the deliverable contract up front (format + done-criteria), delegates repo/infra scanning to subagents, verifies every claim, and outputs an issue-ready Markdown report. Use when the user says "調査して", "調べてレポート", "investigation report", "報告書にまとめて", or hands over an investigation-shaped task.
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Agent, Write, WebSearch, WebFetch
argument-hint: "<question or target> [--out <file>] [--depth quick|thorough]"
---

# investigation-report

Investigation requests are the most frequent work type (docs/debugging/PR-analysis ≈ 60% of sessions) and the main source of `misunderstood_request` friction. This skill removes the ambiguity by fixing the contract BEFORE any work, then running hands-off.

## Phase 0 — Contract (one round max)

From `$ARGUMENTS` and context, fill this contract. Ask the user ONE batched question only for fields you genuinely cannot infer; otherwise state your assumption and proceed:

- **Question**: the exact question the report must answer
- **Audience**: customer-facing / internal / self
- **Deliverable**: Markdown report (default), destination file (default `./reports/YYYY-MM-DD-<slug>.md`, or `--out`)
- **Done-criteria**: what makes this answerable ("root cause identified or 3 hypotheses ranked", "migration steps listed with risks", ...)
- **Depth**: `quick` (single-pass, ~1 subagent) / `thorough` (default; parallel subagents + verification pass)

Echo the contract in 3 lines, then start. Do not wait for approval unless the user is clearly present and the task is client-facing.

## Phase 1 — Collect (delegate, don't read inline)

- Spawn `Explore`/`general-purpose` subagents for repo scanning, `gh` history, cloud CLI reads. Parallelize independent angles (code, config, CI history, docs, external references).
- The main context receives conclusions only, not file dumps.

## Phase 2 — Verify (mandatory)

Per the user's global policy: no technical claim without a citation or a check.

- Every finding gets a source: `file:line`, command output, or doc URL.
- Claims that could not be verified are labeled **unverified hypothesis** — never silently promoted to fact.
- For `thorough`: spawn one adversarial subagent to refute the top conclusion before writing.

## Phase 3 — Report

Structure (Japanese output for the user, this order, no extras):

```
# <Question>
## 結論        — 1-3 sentences, answers the question directly
## 根拠        — findings with citations
## 推奨アクション — ranked, with effort estimates
## 未検証・残課題 — hypotheses and follow-ups
## 参考        — commands run, sources
```

Write to the destination file. Final message: 結論 + file path + (if client repo) suggest `/sreaas:task report`.
