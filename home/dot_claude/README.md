# Claude Code 設定

個人用 Claude Code ハーネス（`~/.claude/`）。chezmoi により `home/dot_claude/` から管理する。
設計原則: **CLAUDE.md は地図であり百科事典ではない** — 常時ロードは最小限、ドメイン知識はオンデマンド（skills / docs）、品質ゲートは機械的に強制（hooks）。

インベントリ（2026-07）: **8 rules · 15 docs · 16 agents · 40 skills · 18 hooks**

> ユースケース別ガイド: [docs/claude-skills-by-usecase.html](../../docs/claude-skills-by-usecase.html)

## 構成

| パス | 役割 | ロード |
|---|---|---|
| `CLAUDE.md` | ナビゲーションマップ: 作業スタイル・委譲方針・セッションプロトコル | 常時 |
| `rules/_core.md` | 普遍ルールの蒸留（セキュリティ・コーディング・サプライチェーン・不確実性・モデルルーティング） | 常時 |
| `rules/**`（path-scoped） | `paths:` frontmatter 付きの言語/ドメイン別ルール | 該当ファイルを触ったとき |
| `docs/` | オンデマンドの詳細ドクトリン（自動ロードされない） | 必要時 |
| `agents/` | subagent 定義（委譲先） | 呼び出し時 |
| `skills/` | スラッシュコマンド型ワークフロー（`/name`） | 呼び出し時 |
| `hooks/` | 決定論的なガード・自動化（LLM トークン消費ゼロ） | イベント発火時 |
| `settings.json` | モデル・effort・権限・hook 配線・sandbox・プラグイン | 起動時 |
| `statusline.sh` | カスタムステータスライン | 常時 |
| `tracked-orgs.txt` | クライアント業務ルールが参照する org 一覧（org 名は public dotfiles に書かない） | 必要時 |

## settings.json の要点

- `model: fable`（Fable 5、最上位ティア）· `effortLevel: high`（Opus 5+/Fable 5 世代の公式推奨デフォルト。`xhigh` は長時間自律実行専用）
- `CLAUDE_CODE_SUBAGENT_MODEL: sonnet` — subagent は調査・実装・レビューの実務を担うため
- 権限: allow 70（開発ツールチェーン）/ deny 57（破壊的操作・secrets・PR/Issue 自動コメント禁止 — `gh api` のコメント POST はフラグ順序・`-f body=` 形式まで網羅）/ ask 32（push・デプロイ・依存追加・`npx` = 任意リモートパッケージ実行のため）
- hooks は 14 種のイベントに配線（[Hooks](#hooks) 参照）
- プラグイン（topotal marketplace）: `sreaas` · `case-reflect` · `proposal-review` · `brainstorming`

## Rules

ロード機構: `paths:` frontmatter の**ない** `rules/**/*.md` は起動時に全て自動ロードされる。
unscoped は `_core.md` のみ — 追加してはならない。

| ファイル | スコープ | 内容 |
|---|---|---|
| `_core.md` | 常時 | OWASP 2025 + LLM セキュリティ、コーディング原則、サプライチェーン（A03）、不確実性表現、コスト/モデルルーティング |
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

Agent ツールから呼び出す subagent 定義。デフォルトの worker モデルは sonnet（`CLAUDE_CODE_SUBAGENT_MODEL`）。

| Agent | 用途 |
|---|---|
| `architect` | システム設計・スケーラビリティ・技術意思決定（新機能設計・大規模リファクタ時） |
| `planner` | 複雑な機能/リファクタをフェーズ分割し、リスク付き計画に落とす |
| `tdd-guide` | テストファースト強制（RED → GREEN → IMPROVE）、カバレッジ 80%+ |
| `code-reviewer` | 多面的レビュー: 正当性・セキュリティ（OWASP 2025）・パフォーマンス・保守性 |
| `security-reviewer` | 入力処理・認証・API・機密データを触るコードの脆弱性検出と修正 |
| `evaluator` | 成功基準に対する懐疑的評価（明示的に求められたときのみ — Opus 5+/Fable 5 は自己検証するため常用しない） |
| `build-error-resolver` | ビルド/型エラーの最小差分修正に特化（アーキテクチャ変更はしない） |
| `refactor-cleaner` | デッドコード削除・重複統合（knip / depcheck / ts-prune） |
| `doc-updater` | codemap とドキュメントの同期（`/update-codemaps` `/update-docs`） |
| `e2e-runner` | Playwright E2E: ジャーニー管理・アーティファクト・flaky 検疫 |
| `batch-worker` | `/batch` 専用の制限付きバックグラウンドワーカー: branch + diff + 検証 + 推奨を用意し、publish は絶対にしない |
| `cognitive/ensemble-reasoner` | 独立した複数の推論パス + 多数決（高リスク判断用） |
| `oss/oss-contributor` | OSS リリースワークフロー・changelog 生成・コミュニティ標準準拠 |
| `oss/supply-chain-auditor` | 依存の脆弱性・typosquatting・完全性検証 |
| `qa/security-auditor` | OWASP 2025 Top 10 + LLM Top 10 に基づく包括監査 |
| `worker/database-reviewer` | DB スキーマ・クエリ・マイグレーションのレビュー |

## Skills

`/name` で呼び出す（説明文にマッチする発言でも自動起動する）。

### 運用・SREaaS

| Skill | 用途 |
|---|---|
| `batch` | 朝バッチ投入: `~/.claude/batch/inbox.md` のタスクを spec contract に整えて案件ごとに background subagent へファンアウト |
| `investigation-report` | 顧客調査 → 検証済み・Issue 貼り付け可能な Markdown 報告書（成果物契約を先に固定） |
| `incident-analysis` | 障害調査の横断収集（AWS CLI・Datadog・リポジトリ）→ タイムライン・根本原因・対策 |
| `dashboard` | セッションメトリクス: ツール使用・トークン・コスト推定（cost-report を吸収） |
| `harness-audit` | 本ハーネス設定の監査。CLAUDE.md/rules のトークン効率も採点（prompt-optimize を吸収） |
| `manage-context` | コンテキスト/メモリ健全性: CLAUDE.md サイズ・メモリ鮮度・`/clear` タイミング |
| `insights-apply` | `/insights` レポート → 日本語 HTML 化 + 推奨事項を 1 件ずつ確認しながら設定に反映 |

### Git・PR

| Skill | 用途 |
|---|---|
| `create-pr` | 変更分析 → サマリ・リスク評価・テストプラン付き PR を gh で作成 |
| `pr-summary` | PR のリスク評価付きサマリとレビュー注視点 |
| `pr-review-respond` | レビュー指摘を確信度スコア付きで評価 → working tree に修正適用 + 返信ドラフト生成（**自動投稿は絶対にしない**） |
| `fix-issue` | GitHub Issue → 体系的な根本原因分析 → 修正 |
| `release` | semver 判定・changelog 生成・リリース作成の自動化 |

### 品質・テスト

| Skill | 用途 |
|---|---|
| `plan` | リスク評価付きの実装計画を提示し、承認を待ってから着手 |
| `tdd-workflow` | TDD 強制。カバレッジ 80%+（unit / integration / E2E） |
| `test-coverage` | カバレッジ分析 + 閾値未満のファイルに不足テストを生成 |
| `mutation-test` | ミューテーションテストでテストスイートの検出力をスコア化 |
| `property-test` | ランダム入力に対する不変条件検証（プロパティベーステスト） |
| `fuzz` | ファズテストでクラッシュ・エッジケース・脆弱性を発見 |
| `e2e` | Playwright E2E の生成・実行・flaky 検出 |
| `eval` | eval 駆動開発: define / check / report、pass@k 追跡 |
| `refactor-clean` | テスト検証付きの安全なデッドコード削除 |
| `coding-standards` | TS/JS/React/Node の汎用標準リファレンス |

### セキュリティ・サプライチェーン

| Skill | 用途 |
|---|---|
| `security-scan` | OWASP 2025 Top 10 監査 + STRIDE 脅威モデリングモード（`threat-model` 引数） |
| `audit-supply-chain` | サプライチェーンセキュリティ + ライセンスコンプライアンス（来歴・署名・脆弱性・typosquatting） |

### データベース

| Skill | 用途 |
|---|---|
| `postgres` | PostgreSQL ベストプラクティス・クエリ最適化・トラブルシュート |
| `mysql` | MySQL スキーマ・インデックス・クエリ・トランザクションのベストプラクティス |
| `clickhouse-io` | ClickHouse MergeTree 設計・分析クエリ・materialized view |

### ドキュメント・ナレッジ

| Skill | 用途 |
|---|---|
| `update-codemaps` | アーキテクチャドキュメント生成（差分追跡付き） |
| `update-docs` | source-of-truth からのドキュメント同期。90 日以上更新なしの陳腐化検出 |
| `update-memory` | 知見をメモリシステムに永続化 |
| `search-memory` | 保存済みの学び・決定・パターンを検索 |

### モード切替

CLAUDE.md の Interaction Modes 本体。Speed（デフォルト）は skill 不要、切替時のみ詳細指示がロードされる。

| Skill | 用途 |
|---|---|
| `mode` | `/mode learning`（地図を渡し答えは書かない）への切替。基準は「時間と場所」— 仕事 = Speed / 学習時間 = learning。learn-map / learn-coach との使い分け表も内包。「Speed」でデフォルト復帰 |

### 学習・執筆

| Skill | 用途 |
|---|---|
| `learn-map` | 学習マップ + ISUCON/CTF 風演習問題の生成 — 答えは絶対に出さない（学習サイクルの「before」段階） |
| `learn-coach` | 最小介入コーチ: 段階制ヒント（L1 言語化 → L4 答え）、詰まりポイントを STRUGGLE_LOG.md に記録 |
| `learn` | セッションから再利用可能なパターンを抽出して skill 化 |
| `reflect` | Reflexion フレームワークによる構造化振り返り |
| `write-article` | 「ぐりもお (@gr1m0h)」voice の技術記事（日本語スタイルガイド厳守） |
| `company-blog` | 完了した案件 → 機密除去 + 一般化した会社テックブログドラフト |
| `slide-deck` | Topotal Design System 準拠の登壇スライドデッキ生成（HTML/PDF + 台本 + プレゼンターモード） |

### 意思決定支援

| Skill | 用途 |
|---|---|
| `ensemble-vote` | 複数の独立推論パス + 多数決で高リスクな選択を決める |

## Hooks

settings.json に配線された決定論的強制（トークン消費ゼロ）。

| Hook | イベント | 用途 |
|---|---|---|
| `session-start.js` | SessionStart | 前回セッション状態の復元とオリエンテーション文脈の注入 |
| `session-end.js` | SessionEnd / Stop | 次回セッション向けの状態スナップショット保存 |
| `pre-tool-guard.js` | PreToolUse (Bash/Edit/Write) | 危険コマンド（破壊・情報漏洩・RCE）と保護ファイル書き込みのブロック |
| `ssrf-guard.js` | PreToolUse (WebFetch) | 内部ネットワークアクセスの遮断（SSRF 防止） |
| `prompt-validator.js` | UserPromptSubmit | プロンプトの明確さを検証し、問題があればガイダンスを注入 |
| `post-tool-verify.js` | PostToolUse (Edit/Write) | 編集後の linter 自動実行（ESLint/Biome・ruff・gofmt・rustfmt 等） |
| `architecture-guard.js` | PostToolUse (Edit/Write) | コード変更後のアーキテクチャ違反検出 |
| `test-runner.js` | PostToolUse (Edit/Write, async) | ソース変更に関連するテストの自動実行 |
| `cost-monitor.js` | PostToolUse (async) | トークン使用量・ツール呼び出し回数の記録 |
| `telemetry-collector.js` | PostToolUse (async) | OpenTelemetry 互換のトレース/メトリクス収集 |
| `circuit-breaker.js` | PostToolUse / PostToolUseFailure | 失敗を追跡し、閾値超過でサーキットを開く |
| `post-tool-batch.js` | PostToolBatch | 並列バッチ操作後の整合性検証（競合編集の検出） |
| `on-failure-recover.js` | PostToolUseFailure | エラー分類（構文/ランタイム/権限/ネットワーク等）と復旧提案 |
| `permission-denied-tracker.js` | PermissionDenied | 拒否されたツール呼び出しを記録し、権限リストのギャップを特定 |
| `pre-compact-protector.js` | PreCompact | コンパクション前に重要コンテキストを保護 |
| `subagent-monitor.js` | SubagentStart / SubagentStop | subagent ライフサイクルのメトリクス収集 |
| `quality-gate.js` | TeammateIdle | チームメイトがアイドルになる前の品質チェック |
| `task-validator.js` | TaskCompleted | タスク完了条件の検証 |

## 運用モデル

- **メインセッション = 司令塔**（仕様・レビュー・意思決定）。実行はバックグラウンド subagent / worktree / workflow にファンアウトする。詳細は `CLAUDE.md` → Delegation & Parallelism。
- **朝**: タスクをキューに積んで `/batch`。**調査形の依頼** → `/investigation-report`。**タスクの締め** → `/sreaas:task report`（プラグイン）。
- 委譲された各トラックはレビュー可能な成果物（diff + 検証 + 推奨）で終わる。自動公開はしない — PR/Issue へのコメント投稿は権限レベルで拒否される。
