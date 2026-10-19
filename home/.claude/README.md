# Claude Code 設定

個人用 Claude Code ハーネス（`~/.claude/`）。`scripts/sync-claude.sh` / `scripts/apply-main.sh` で `home/.claude/` と同期する。
設計原則: **CLAUDE.md は地図であり百科事典ではない** — 常時ロードは最小限、ドメイン知識はオンデマンド（skills / docs）、品質ゲートは機械的に強制（hooks）。2026-10 に `.codex`/`.agents` と同じ evidence-based アーキテクチャへ統合（根拠: Anthropic context-engineering / Agent Skills、arXiv:2602.11988、OpenAI Astra post）。

インベントリ（2026-10）: **8 rules · 15 docs · 8 agents · 26 skills（うち 8 は `~/.agents/skills` への router）· 7 hooks**

> ユースケース別ガイド: [docs/claude-skills-by-usecase.md](../../docs/claude-skills-by-usecase.md)

## 構成

| パス | 役割 | ロード |
|---|---|---|
| `CLAUDE.md` | ナビゲーションマップ: 作業スタイル・委譲方針・セッションプロトコル | 常時 |
| `rules/_core.md` | 普遍ルールの蒸留（セキュリティ・コーディング・サプライチェーン・不確実性・モデルルーティング） | 常時 |
| `rules/**`（path-scoped） | `paths:` frontmatter 付きの言語/ドメイン別ルール | 該当ファイルを触ったとき |
| `docs/` | オンデマンドの詳細ドクトリン（自動ロードされない） | 必要時 |
| `agents/` | subagent 定義（委譲先） | 呼び出し時 |
| `skills/` | スラッシュコマンド型ワークフロー（`/name`）。共有 skill は `~/.agents/skills/` が正本で、ここには trigger description を持つ薄い router を置く | 呼び出し時 |
| `hooks/` | 決定論的なガード・自動化（LLM トークン消費ゼロ） | イベント発火時 |
| `settings.json` | モデル・effort・権限・hook 配線・sandbox・プラグイン | 起動時 |
| `statusline.sh` | カスタムステータスライン（BATCH_QUEUE / unreported 等） | 常時 |

## settings.json の要点

- `model: fable`（Fable 5、最上位ティア）· `effortLevel: high`（`xhigh` は長時間自律実行専用）
- `CLAUDE_CODE_SUBAGENT_MODEL: sonnet` — subagent は調査・実装・レビューの実務を担うため
- 権限: allow（開発ツールチェーン）/ deny（破壊的操作・secrets・PR/Issue 自動コメント禁止）/ ask（push・デプロイ・依存追加・`npx`）
- hooks は 5 イベントに配線（[Hooks](#hooks) 参照）
- プラグイン（topotal marketplace）: `sreaas` · `case-reflect` · `proposal-review` · `brainstorming`

## Rules

ロード機構: `paths:` frontmatter の**ない** `rules/**/*.md` は起動時に全て自動ロードされる。
unscoped は `_core.md` のみ — 追加してはならない。

| ファイル | スコープ | 内容 |
|---|---|---|
| `_core.md` | 常時 | OWASP 2025 + LLM セキュリティ、コーディング原則、サプライチェーン(A03)、不確実性表現、コスト/モデルルーティング |
| `coding-style.md` | path-scoped | 汎用コーディングスタイル規約 |
| `testing.md` | path-scoped | テスト標準 |
| `backend/api-guidelines.md` | path-scoped | API 設計ガイドライン |
| `backend/go-patterns.md` | path-scoped | Go のイディオム・パターン |
| `backend/ruby-patterns.md` | path-scoped | Ruby / Rails パターン |
| `backend/php-patterns.md` | path-scoped | PHP パターン |
| `frontend/react-patterns.md` | path-scoped | React パターン |

## docs/（オンデマンドドクトリン）

`agents` · `batch-permissions` · `coding-standards` · `context-engineering` · `continuous-learning` ·
`cost-optimization` · `forbidden-apis` · `git-workflow` · `harness-engineering` · `llm-security` ·
`patterns` · `performance` · `security` · `supply-chain-security` · `uncertainty-expression`

話題に上がったときに読む。`rules/` に戻さない（全セッションが肥大化するため）。

## Agents

Agent ツールから呼び出す subagent 定義（8）。2026-10 に `.codex/agents/*.toml` と同内容へ統一。
デフォルトの worker モデルは sonnet（`CLAUDE_CODE_SUBAGENT_MODEL`）。

| Agent | 用途 |
|---|---|
| `architect` | 重要な設計判断の根拠付き設計パッケージ（caller 起点のスケッチ・代替案比較・検証計画） |
| `code-reviewer` | 割り当てられた diff の evidence-based レビュー（スタイル好みをバグとして出さない） |
| `security-reviewer` | trust boundary と実証インパクトに基づくセキュリティ評価 + OWASP/LLM Top 10 監査 |
| `qa-engineer` | acceptance / E2E / property / fuzz / mutation / LLM eval の的を絞った実行（qa-testing skill と対） |
| `sre-investigator` | 運用エビデンス収集・タイムライン再構成・仮説弁別（sre-operations skill と対） |
| `doc-editor` | ドキュメント・記事の編集（write-article skill と対、codemap/doc 同期を含む） |
| `database-reviewer` | DB スキーマ・クエリ・マイグレーションのレビュー |
| `batch-worker` | `/batch` 専用の制限付きバックグラウンドワーカー: publish は絶対にしない |

**意図的に agent にしないもの**: 計画（ビルトイン plan mode）・自己検証（Fable 5/Opus 4.5+ は自己検証、機械チェックで足りる）・TDD 強制とビルド修正（メインループ + coding-workflow skill）・デッドコード掃除（coding-workflow + knip/depcheck/ts-prune）。

## Skills

`/name` で呼び出す（説明文にマッチする発言でも自動起動する）。**説明文は常時コンテキストに載る恒常コスト**なので、本数を絞り「いつ発動するか」を狭く書く。

### 共有 skill への router（正本は `~/.agents/skills/` — Codex と共用）

| Skill | 用途 |
|---|---|
| `coding-workflow` | 実装・バグ修正・リファクタ（旧 tdd-workflow / fix-issue / refactor-clean / coding-standards を統合） |
| `qa-testing` | acceptance / E2E / property / fuzz / mutation / LLM eval（旧 e2e / property-test / fuzz / mutation-test / test-coverage / eval を統合） |
| `sre-operations` | 障害調査・SLO・運用変更。references/ に AWS CLI・Datadog コマンド集（旧 incident-analysis を統合） |
| `investigation-report` | 技術調査 → 出典検証済みレポート |
| `pr-review-respond` | レビュー指摘の検証・修正適用・返信ドラフト（自動投稿しない） |
| `audit-supply-chain` | 依存の脆弱性・来歴・ライセンス監査 |
| `write-article` | 「ぐりもお」voice の日本語記事編集 |
| `learning-coach` | 段階ヒントの学習コーチ（旧 learn-coach） |

### 運用・SREaaS

| Skill | 用途 |
|---|---|
| `batch` | 朝バッチ投入: inbox.md のタスクを spec contract に整えて background subagent へファンアウト |
| `deepwork` | 深い案件タスクの直列プル（WIP=1、prefetch で次タスクを温める） |
| `harness-audit` | 本ハーネス設定の監査（トークン効率採点込み） |
| `insights-apply` | `/insights` レポート → 日本語 HTML 化 + 推奨を 1 件ずつ設定反映 |

### Git・PR・リリース

| Skill | 用途 |
|---|---|
| `create-pr` | 変更分析 → スコープ確認 → リスク評価付き PR 作成 |
| `release` | semver 判定・changelog 生成・リリース作成 |

### セキュリティ・DB

| Skill | 用途 |
|---|---|
| `security-scan` | コードベース全体の OWASP 2025 監査 + STRIDE 脅威モデリング（diff 対象のビルトイン /security-review と使い分け） |
| `postgres` / `mysql` / `clickhouse-io` | DB ベストプラクティス・最適化リファレンス |

### ドキュメント・学習・執筆

| Skill | 用途 |
|---|---|
| `update-codemaps` / `update-docs` | アーキテクチャ文書生成・source-of-truth からの同期 |
| `mode` | `/mode learning` への切替（基準は時間と場所、タスク種別ではない） |
| `learn` | 学習ライフサイクルの関節（add / review / start / done） |
| `learn-map` | 学習マップ + 演習問題生成（答えは出さない） |
| `reflect` | Reflexion 振り返り + 再利用パターンの skill 化（→ `skills/learned/`） |
| `company-blog` | 案件 → 機密除去済み会社テックブログ案 |

**ビルトインに置換済み（削除）**: plan（plan mode）· pr-summary（/code-review）· search-memory / update-memory（native auto-memory）· manage-context（/context · /insights）· dashboard（/usage · /insights）· ensemble-vote（Fable 5 世代で費用対効果なし）。

## Hooks

settings.json に配線された決定論的強制（トークン消費ゼロ）。**hook は「保証」にだけ使う** — 判断は CLAUDE.md/skills、観測はネイティブ（/insights · /usage · OTEL）。

| Hook | イベント | 用途 |
|---|---|---|
| `session-start.js` | SessionStart | 前回セッション状態の復元・BATCH_QUEUE/LEARN_BACKLOG 表示・retro-learn 自動投入 |
| `session-end.js` | SessionEnd / Stop | 状態スナップショット保存・unreported 検知 |
| `pre-tool-guard.js` | PreToolUse (Bash/Edit/Write) | 危険コマンド・保護ファイル書き込み・シークレット混入のブロック |
| `ssrf-guard.js` | PreToolUse (WebFetch) | 内部ネットワークアクセスの遮断 |
| `org-leak-guard.js` | PreToolUse (Bash/GitHub MCP) | クロス org 参照の漏洩防止 |
| `post-tool-verify.js` | PostToolUse (Edit/Write) | 編集後の linter/formatter/型チェック自動実行 |
| `test-runner.js` | PostToolUse (Edit/Write, async) | 関連テストの自動実行 |

**削除済み（2026-10）**: 観測系 3（cost-monitor / telemetry-collector / subagent-monitor → ネイティブ /insights · /usage）、judgment 系 5（prompt-validator / architecture-guard / on-failure-recover / circuit-breaker / pre-compact-protector → モデル自身とネイティブ compaction が担う）、低頻度イベント系 4（post-tool-batch / permission-denied-tracker（→ ビルトイン /fewer-permission-prompts）/ quality-gate / task-validator）。

## 運用モデル

- **メインセッション = 司令塔**（仕様・レビュー・意思決定）。実行はバックグラウンド subagent / worktree / workflow にファンアウトする。詳細は `CLAUDE.md` → Delegation & Parallelism。
- **朝**: タスクをキューに積んで `/batch`。**深い案件タスク** → `/deepwork`。**調査形の依頼** → `/investigation-report`。**タスクの締め** → `/sreaas:task report`（プラグイン）。
- 委譲された各トラックはレビュー可能な成果物（diff + 検証 + 推奨）で終わる。自動公開はしない — PR/Issue へのコメント投稿は権限レベルで拒否される。
