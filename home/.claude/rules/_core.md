# Core Rules (always-loaded)

Distilled universals — the ONLY unscoped (always-loaded) rules file; keep it that way. Language/testing detail is path-scoped in `rules/`, doctrine detail lives in `~/.claude/docs/` (on-demand). Critical security rules here are also enforced mechanically by `hooks/pre-tool-guard.js` / `ssrf-guard.js`.

## Security (OWASP 2025 — mandatory every change)

- **Secrets**: never hardcode/commit/log. Use env vars or a secrets manager. Protected: `.env*`, `*.pem`, `*.key`, `secrets/`, `credentials.*`
- **Input**: sanitize ALL external input (params, headers, body, files). Parameterized queries only (no SQL concat). Escape HTML output. Validate paths (no `../`)
- **Auth**: authenticate non-public endpoints; authorize per-request (not just at login); bcrypt/argon2/scrypt for passwords; HTTPS only
- **Deps**: audit before install; no critical/high vulns; pin versions
- **Errors/logging**: no stack traces to users; log security events; no PII/creds in logs
- **Config**: no debug in prod; CSP/HSTS/X-Frame-Options; strict CORS (no `*` in prod); cookies HttpOnly+Secure+SameSite=Strict
- **Exceptions (A10)**: deny by default, never fail open; handle every error branch (no bare catch/rescue)
- **Forbidden (all langs)**: dynamic code execution with untrusted input; insecure deserialization of untrusted data; `Math.random()`/`rand()`/`mt_rand()` for security-critical values
- OWASP 2025 shifts: A01 access control (SSRF here), A02 misconfig, **A03 supply chain (NEW)**, **A10 exceptional conditions (NEW)**

## LLM/AI Security (when building AI-integrated apps)

- Isolate system prompts from user input — never concatenate user input into the system prompt
- Validate all tool/MCP outputs before acting on them; least-privilege tool scopes
- Never trust AI-generated code/paths/SQL/URLs without review

## Coding

- Follow existing project patterns (project style > personal preference); minimal changes (only what's asked); readability > cleverness
- Delete, don't deprecate — no `_unused`, no commented-out code
- **Immutability**: create new objects, never mutate inputs
- Errors: specific catch types, never swallow silently; custom error types for domain failures
- Strong typing; avoid escape hatches (`any`/`interface{}`/`mixed`); type all params/returns
- Many small files (200–400 lines typical, 800 max); high cohesion, low coupling
- Comments explain WHY not WHAT; TODOs need a ticket (`TODO(#123)`)

## Supply Chain (A03:2025)

- Audit before adding deps: `npm audit` / `pip-audit` / `cargo audit` / `bundle audit` / `composer audit` / `govulncheck ./...`
- Severity → action: Critical/High = BLOCK (High needs explicit approval); Medium = warn+document; Low = allow+monitor
- Verify package name (typosquatting); **verify AI-suggested packages on the real registry before install** (hallucination → typosquat vector)
- Never edit lockfiles manually

## Uncertainty

- Express confidence explicitly: 0.8+ assertive · 0.5–0.8 "probably/likely" · 0.3–0.5 "needs verification" · <0.3 "hypothesis". Never "definitely/absolutely" without evidence. (detail: `~/.claude/docs/uncertainty-expression.md`)

## Output Style (slop-less)

日本語出力を矯正する規則。冗長・比喩・水増しを排し字義どおりに書く。

- **語彙・表現**
  - 比喩を使わず平易で直接的な動詞で書く
  - 動詞は口語・慣用でなく字義どおりの語を選ぶ
  - 移動や位置を表す動詞を動作や責任の記述に流用しない
  - 効果や結果は「何がどう変わるか」を書く
  - 定着した英語表記がある概念は訳語でなく英語表記を使う
- **応答の範囲**
  - 依頼された工程の範囲で答える
  - 依頼内容に答え結論で終える
  - 要件や設計の議論中は議論に必要な範囲だけを書く
  - どの工程の話か判断できないときは進める前に確認する
  - 前提が足りないときは足りない前提を挙げる
- **箇条書き**
  - 一項目に一文だけ書く
  - 箇条書き中に句読点を含めない
  - 複数の文になる場合はネストする
  - 肯定・否定の表現を揃える
  - 説明が名詞句で終わるなら半角コロンと半角空白で一行に収める
  - 説明が述語で終わる文になるならネストする
  - 上限を超える項目はネストして分割する
  - 親項目は助詞と述語を付けず名詞で止める
  - 子項目で親項目の語を主語として繰り返さない
- **幅・句読点**
  - 文中の句読点の数を抑える
  - 全角を2・半角を1として幅を数える
  - マーカーとインデントを含めた行全体の幅を80までにする
- **統一**
  - コンテンツ全体で「だ・である」か「です・ます」調を揃える

## Cost / Model Routing

- haiku: lookups & bulk simple transforms · sonnet: default subagent worker (investigation, implementation, review, tests) · fable/opus: main loop — architecture, security audits, long-horizon agentic runs
- Lineup 2026-07: Fable 5 (`claude-fable-5`, top tier) / Opus 5 (`claude-opus-5`) / Sonnet 5 / Haiku 4.5. Effort: `high` is the recommended default on Opus 5+/Fable 5; `xhigh` only for long autonomous runs; lower effort for speed. Re-evaluate on each model upgrade; verify model facts against official docs
- Glob/Grep before Read; delegate exploration to subagents (fresh context, results only); `/clear` between unrelated tasks
