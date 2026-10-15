---
name: insights-apply
description: From a Claude Code /insights report, generate a Japanese-translated HTML report AND reflect its actionable recommendations into the config (~/.claude/), confirming EACH item one-by-one (apply or skip). Skipped items are left untouched. Use when the user says "insights apply", "insightを設定に反映", "insightを日本語HTML", "apply insights to config".
triggers: ["insights apply", "insight apply", "insightを設定に反映", "insights 反映", "apply insights", "insightを日本語HTML", "insights html"]
user-invocable: true
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, AskUserQuestion
---

# /insights-apply — Japanese HTML + apply /insights recommendations (one-by-one)

Two jobs from one `/insights` report:
1. Produce a **Japanese-translated HTML** report of the insights.
2. Reflect the report's actionable recommendations into the Claude Code config under
   `~/.claude/`, confirming EACH item individually (approved → applied, rejected → skipped).

## 1. Locate the insights report (try in this order)
The built-in `/insights` skill is the source. It emits a full structured JSON payload
in-conversation and writes an HTML report under `~/.claude/usage-data/`.
1. If `/insights` was just run in this conversation → use that in-conversation JSON
   directly (richest source; contains `suggestions.claude_md_additions`, `features_to_try`,
   `friction_analysis`, etc.).
2. Arguments contain a file path → read that file.
3. Recent reports — run: `ls -t ~/.claude/usage-data/report*.html 2>/dev/null | head -3`
   (latest is also `~/.claude/usage-data/report.html`; facet data in `~/.claude/usage-data/facets`).
4. Otherwise ASK the user to run `/insights` first, or to provide the report/path.
Never invent content that is not in the report.

## 2. Generate the Japanese HTML report
Translate the located insights report into a self-contained **Japanese** HTML file.
- Translate ALL sections faithfully (project areas / interaction patterns / friction points /
  suggestions / on-the-horizon). It is a translation, not a rewrite — do not add, drop,
  reorder, or editorialize. Match orthography (correct kana/kanji, no ASCII substitution).
- Keep technical terms and identifiers in original form — command/tool names (`Bash`, `Edit`...),
  file paths, flags, code, metrics, and numbers stay verbatim.
- Render a single self-contained `.html` (inline CSS, no external assets, no JS required):
  Japanese-capable font stack `font-family:"Hiragino Sans","Noto Sans JP",system-ui,sans-serif;`,
  centered max-width container (~820px), responsive, comfortable line-height, header with title
  (日本語) + generated timestamp + source path, friction points visually flagged (warning color),
  suggestions as a checklist, `prefers-color-scheme: dark` support.
- Save it: `mkdir -p ~/.claude/insights` then write
  `~/.claude/insights/insight-<YYYYMMDD-HHMMSS>.html` (timestamp via `date +%Y%m%d-%H%M%S`).
- Print the absolute path and offer to open it (`open <path>` on macOS) — do not auto-open
  without saying so.

## 3. Extract actionable items
- Parse the report into concrete, actionable items (friction points with a fix, suggested
  settings, missing skills/agents, rule/hook changes, etc.). Drop pure observations.
- For each item, determine: **title**, **rationale** (quoted/derived from the report),
  **target file(s)** under `~/.claude/`, and the **concrete change** (diff-level if possible).
- Cross-check against the CURRENT config: if a recommendation is already satisfied, mark it
  **already-covered** (recommend skip); if it is project-specific, mark it **project-scoped**
  (recommend it go in the project's `.claude/CLAUDE.md`, not global).
- Mark anything ambiguous or unverifiable — prefer asking over guessing (the user's
  "Verification Before Claims" rule).

## 4. Safety first (before ANY config edit)
- Create a backup dir: `TS=$(date +%Y%m%d-%H%M%S); mkdir -p ~/.claude/backups/insights-apply-$TS`
  Copy each target file into it immediately before editing that file.
- Re-read each target file right before editing it (no stale snapshots).
- For removals: verify references first (`grep -r`), never delete interconnected
  skills/agents blindly. Prefer disabling over deleting.
- Respect always-loaded budget: flag any item that would push CLAUDE.md + `@`-loaded rules
  over ~2k tokens; prefer on-demand `rules/*` files over always-loaded for tactical tips.

## 5. Per-item confirmation loop (the core behavior)
For EACH extracted item, in order:
1. Present a compact card: **What** (change), **Why** (rationale), **Where** (target file),
   **Diff** (before → after when feasible), and any **already-covered / project-scoped** flag.
2. Ask the user to choose **Apply** or **Skip** with the AskUserQuestion tool, one item at a
   time, allowing a free-text note. (Never batch into a single yes-to-all; one control per item.)
   - **Apply** → make the edit, then verify it (JSON validity for `*.json`, `node --check` for
     hook `*.js`, only the intended `@`-auto-load in CLAUDE.md). On failure, revert from backup.
   - **Skip** → make NO change; record as skipped; continue.

## 6. Summary
- Print a table: `item | decision (applied/skipped) | file(s) touched`.
- State the saved HTML path, the backup directory, and the rollback command
  (`cp -r <backup>/* ~/.claude/`).
- Confirm the config still loads cleanly (valid `settings.json`, single intended `@`-auto-load).
- If a dotfiles repo is in use, offer to sync applied changes there (do not commit without
  explicit approval).

## Notes
- This skill MODIFIES config. Default to caution: when unsure, skip and tell the user.
- HTML output is Japanese; this instruction file stays English; speak to the user in their
  configured language.
- If the user only wants the HTML (no config changes), generate step 2 and stop.
