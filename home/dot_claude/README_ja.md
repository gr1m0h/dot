# Claude Code 設定ガイド（完全版）

AI支援コーディングのための個人用 Claude Code 設定。セキュリティ強制、ワークフロー自動化、継続学習を統合。

**目次:**
- [ディレクトリ構成](#ディレクトリ構成)
- [クイックスタート](#クイックスタート)
- [インタラクションモード](#インタラクションモード)
- [エージェント](#エージェント)
- [スキル](#スキル)
- [ルール](#ルール)
- [フック](#フック)
- [ワークフローパターン](#ワークフローパターン)
- [環境変数](#環境変数)
- [権限設定](#権限設定)

---

## ディレクトリ構成

```
.claude/
├── CLAUDE.md                    # メイン指示・インタラクションモード定義
├── README_ja.md                 # このドキュメント
├── settings.json                # Claude Code 統合設定
├── agents/                       # 39個の専門エージェント定義
│   ├── architect.md
│   ├── build-error-resolver.md
│   ├── code-reviewer.md
│   ├── ... (計39個)
│   ├── cognitive/                # 認知エージェント（4個）
│   ├── iot/                       # IoT/ファームウェア（3個）
│   ├── leader/                    # リーダーシップ・オーケストレーション（4個）
│   ├── oss/                       # OSSガバナンス（3個）
│   ├── planning/                  # 計画アルゴリズム（1個）
│   ├── qa/                        # 品質保証（6個）
│   ├── resilience/                # 復元力（1個）
│   ├── routing/                   # ルーティング（2個）
│   ├── security/                  # セキュリティ研究（2個）
│   └── worker/                    # ワーカーエージェント（4個）
├── skills/                        # 58個のスラッシュコマンドスキル
│   ├── <スキル名>/SKILL.md
│   └── ... (計58個)
├── rules/                         # 18個のポリシー・ガイドライン
│   ├── agents.md
│   ├── coding-style.md
│   ├── continuous-learning.md
│   ├── git-workflow.md
│   ├── hooks.md
│   ├── multi-agent.md
│   ├── patterns.md
│   ├── performance.md
│   ├── security.md
│   ├── testing.md
│   ├── token-optimization.md
│   ├── global/                    # グローバルルール（4個）
│   ├── frontend/                  # Reactパターン（1個）
│   ├── backend/                   # API設計ガイドライン（1個）
│   └── cognitive/                 # 不確実性表現（1個）
├── hooks/                         # 16個の JavaScript 自動化フック
│   ├── session-start.js
│   ├── session-end.js
│   ├── pre-tool-guard.js
│   ├── post-tool-verify.js
│   ├── ... (計16個)
├── memory/                        # 永続的知識・セッション状態
│   ├── MEMORY.md                  # メモリシステムドキュメント
│   ├── architecture.md            # アーキテクチャメモ
│   ├── best-practices.md          # ベストプラクティス
│   ├── local/                     # セッション内メモリ
│   │   ├── session-state.json
│   │   ├── cost-stats.json
│   │   ├── circuit-breaker-state.json
│   │   └── learnings.md
│   └── project/                   # プロジェクト固有メモリ
└── plugins/                       # Claude プラグイン連携
```

---

## クイックスタート

### よく使うコマンド

**基本的な開発:**
```bash
/plan              # 実装計画の作成
/tdd               # テスト駆動開発（80%+カバレッジ）
/review-code       # 多次元コードレビュー
/build-fix         # TypeScript/ビルドエラーの段階的修正
/quick-fix         # 軽微な変更（Haikuモデル）
```

**セキュリティ・品質:**
```bash
/security-scan     # OWASP 2025 Top 10 監査
/threat-model      # STRIDE脅威モデリング
/verify            # コードベース検証（型・lint・テスト・セキュリティ）
/test-coverage     # カバレッジ分析・不足テスト生成
```

**ワークフロー・自動化:**
```bash
/create-pr         # PR生成・作成
/release           # セマンティックバージョニング・変更履歴
/orchestrate       # マルチエージェント順次ワークフロー
/parallel          # スキルの並列実行
```

**コンテキスト・コスト管理:**
```bash
/manage-context    # コンテキストウィンドウの最適化
/cost-report       # トークン使用量・コスト見積もり
/model-route       # タスク複雑性に基づく自動モデル選択
/strategic-compact # 手動コンテキスト圧縮
```

### モード切り替え

```bash
learning           # デフォルト - ヒント・参考資料先行
guided             # 選択肢提示・スケルトン填補
speed              # 制約なし・最大速度実装
```

---

## インタラクションモード

`CLAUDE.md` で設定。モード名を入力して切り替え。

### Learning Mode（デフォルト）

**原則:** 地図を示す、答えは示さない

**実装前:**
- 参考資料・セクション名を提示（実装方法は提示しない）
- 複数の手法が存在する場合、存在だけ示す

**実装中:**
- レビュアー役 - 検索キーワードやドキュメントを提案
- 段階的に詳細化：参考資料 → 手法 → 疑似コード → 実装コード

**実装後:**
- 2-3個の関連概念を紹介
- 再利用可能なパターンを体系化

### Guided Mode

`guided` で起動。選択肢提示 → ユーザースケルトン作成 → 詳細填補

### Speed Mode

`speed` で起動。制約なし・最大速度で実装

---

## エージェント（39個）

専門分野別に整理されたエージェント定義。`Task` ツールで起動。

### ルートエージェント（9個）

| エージェント | 用途 |
|-------------|------|
| `architect` | ソフトウェアアーキテクチャ・スケーラビリティ・技術決定 |
| `build-error-resolver` | TypeScript/ビルドエラーの修正（最小限の差分） |
| `code-reviewer` | 多次元レビュー（機能性・セキュリティ・パフォーマンス・保守性） |
| `doc-updater` | ドキュメント・コードマップ更新 |
| `e2e-runner` | Playwright E2Eテスト（テストジャーニー管理） |
| `planner` | 複雑な機能・リファクタリングの計画作成 |
| `refactor-cleaner` | デッドコード削除・統合（knip/depcheck/ts-prune使用） |
| `security-reviewer` | セキュリティ脆弱性検出・修正（OWASP Top 10） |
| `tdd-guide` | テスト駆動開発（テストファースト・80%+カバレッジ） |

### Cognitive エージェント（4個）

| エージェント | 用途 |
|-------------|------|
| `confidence-calibrator` | 回答の信頼度評価・不確実性明示化 |
| `context-optimizer` | コンテキスト圧縮・最適化 |
| `ensemble-reasoner` | 複数推論パス生成・多数決 |
| `memory-consolidator` | エピソード → 意味記憶の統合 |

### IoT エージェント（3個）

| エージェント | 用途 |
|-------------|------|
| `edge-security` | IoT/エッジファームウェアセキュリティ監査 |
| `firmware-dev` | ファームウェア開発（メモリ制約・RTOS・HAL） |
| `protocol-analyzer` | 通信プロトコル分析（正確性・セキュリティ・相互運用性） |

### Leader エージェント（4個）

| エージェント | 用途 |
|-------------|------|
| `chief-of-staff` | 複雑マルチステップタスク上級オーケストレーション |
| `loop-operator` | ビルド/テスト/品質ループの自律反復（サーキットブレーカー付き） |
| `orchestrator` | エージェントチーム・並列実行・障害回復 |
| `task-planner` | TDAG原則に基づく要件分解 |

### OSS エージェント（3個）

| エージェント | 用途 |
|-------------|------|
| `license-auditor` | 依存関係ライセンスコンプライアンス監査 |
| `oss-contributor` | OSSリリースワークフロー・changelog生成 |
| `supply-chain-auditor` | サプライチェーンセキュリティ分析（タイポスクワッティング） |

### Planning エージェント（1個）

| エージェント | 用途 |
|-------------|------|
| `tot-planner` | Tree of Thoughts による複数ソリューション探索 |

### QA エージェント（6個）

| エージェント | 用途 |
|-------------|------|
| `code-reviewer` | QA重視のコードレビュー |
| `debugger` | エラー調査・修正（ReAct + Reflexion） |
| `fuzzer` | ファズテスト設計（エッジケース・脆弱性発見） |
| `mutation-tester` | ミューテーションテスト（テスト品質評価） |
| `property-tester` | プロパティベーステスト（不変条件検証） |
| `security-auditor` | 包括的セキュリティ監査（OWASP 2025 + LLM Top 10） |

### Resilience エージェント（1個）

| エージェント | 用途 |
|-------------|------|
| `fallback-handler` | ツール/サービス障害時の代替手段 |

### Routing エージェント（2個）

| エージェント | 用途 |
|-------------|------|
| `model-selector` | タスク複雑性に基づく最適モデル選択 |
| `tool-router` | タスク最適ツール選択・効率的使用提案 |

### Security エージェント（2個）

| エージェント | 用途 |
|-------------|------|
| `reverse-engineer` | セキュリティ研究用リバースエンジニアリング |
| `threat-modeler` | STRIDE/攻撃ツリー/データフロー脅威モデリング |

### Worker エージェント（4個）

| エージェント | 用途 |
|-------------|------|
| `coder` | 機能実装（既存パターン準拠・品質チェック内蔵） |
| `database-reviewer` | スキーマ設計（3NF）・クエリパフォーマンス・マイグレーション安全性 |
| `harness-optimizer` | トークン効率・フック品質・権限・ワークフロー監査 |
| `test-writer` | テストスイート設計（カバレッジ駆動・境界値分析） |

---

## スキル（58個）

スラッシュコマンド形式のワークフロースキル。`/スキル名` で起動。

### 開発・品質スキル（16個）

| スキル | 説明 |
|--------|------|
| `/build-fix` | TypeScript/ビルドエラーを1つずつ段階的修正 |
| `/code-review` | コミット前の変更に対する包括的レビュー |
| `/coding-standards` | TS/JS/React/Nodeの汎用標準・ベストプラクティス |
| `/quick-fix` | タイポ・リネーム・軽微なリファクタリング（Haikuモデル） |
| `/refactor-clean` | テスト検証によるデッドコード削除 |
| `/review-code` | 多次元レビュー（正確性・セキュリティ・パフォーマンス・保守性） |
| `/tdd` | ミューテーションテスト・カバレッジ追跡によるTDDワークフロー |
| `/tdd-workflow` | 80%+カバレッジのTDD強制 |
| `/test-coverage` | カバレッジ分析・不足テスト生成 |
| `/verify` | 検証フェーズ実行（ビルド・型・lint・テスト・セキュリティ） |
| `/verification-loop` | ビルド→型→lint→テスト→セキュリティの繰り返し |
| `/plan` | ステップバイステップの実装計画作成 |
| `/create-pr` | 変更分析・gh CLIでPR生成 |
| `/pr-summary` | リスク評価付きPRサマリー生成 |
| `/e2e` | Playwright E2Eテスト生成・実行 |
| `/release` | セマンティックバージョニング・changelog・リリース自動化 |

### テストスキル（9個）

| スキル | 説明 |
|--------|------|
| `/e2e` | Playwright E2Eテスト管理 |
| `/eval` | 評価駆動開発ワークフロー管理 |
| `/eval-harness` | 評価駆動開発フレームワーク実装 |
| `/fuzz` | ファズテスト設定・実行 |
| `/mutation-test` | テスト品質評価のミューテーション実行 |
| `/property-test` | プロパティベーステスト設計 |
| `/tdd` | TDDワークフロー実行 |
| `/tdd-workflow` | TDD強制 |
| `/test-coverage` | カバレッジ分析・生成 |

### セキュリティスキル（8個）

| スキル | 説明 |
|--------|------|
| `/audit-license` | ライセンスコンプライアンス監査 |
| `/audit-supply-chain` | サプライチェーンセキュリティ分析 |
| `/firmware-audit` | ファームウェア/組み込みコード監査 |
| `/protocol-check` | 通信プロトコル実装分析 |
| `/security-review` | 認証・入力・シークレットチェックリスト |
| `/security-scan` | OWASP 2025 Top 10 監査 |
| `/threat-model` | STRIDE脅威モデリング |
| `/reverse-analyze` | リバースエンジニアリング分析 |

### アーキテクチャ・パターンスキル（3個）

| スキル | 説明 |
|--------|------|
| `/backend-patterns` | バックエンドアーキテクチャ・API設計・DB最適化 |
| `/frontend-patterns` | React/Next.js・状態管理・パフォーマンス |
| `/project-guidelines-example` | プロジェクト固有スキルテンプレート |

### データベーススキル（3個）

| スキル | 説明 |
|--------|------|
| `/clickhouse-io` | ClickHouseパターン・クエリ最適化・データエンジニアリング |
| `/mysql` | MySQLスキーマ設計・インデックス・クエリ最適化 |
| `/postgres` | PostgreSQLクエリ最適化・トラブルシューティング |

### ドキュメント・コンテキストスキル（9個）

| スキル | 説明 |
|--------|------|
| `/continuous-learning` | セッションパターンの自動抽出 |
| `/learn` | 再利用可能パターンの抽出 |
| `/manage-context` | コンテキストウィンドウ・メモリファイル監査・最適化 |
| `/reflect` | Reflexionフレームワークによる振り返り |
| `/search-memory` | 認知メモリからの検索・取得 |
| `/update-codemaps` | アーキテクチャドキュメント生成 |
| `/update-docs` | ソースオブトゥルースからのドキュメント同期 |
| `/update-memory` | メモリシステムへの知識保存 |
| `/strategic-compact` | 手動コンテキストコンパクション |

### コスト・パフォーマンススキル（5個）

| スキル | 説明 |
|--------|------|
| `/cost-report` | トークン使用量・ツール呼び出し・コスト見積もり |
| `/dashboard` | テレメトリデータ・セッションパフォーマンス表示 |
| `/model-route` | タスク複雑性に基づく自動モデル選択 |
| `/prompt-optimize` | トークン効率のためのシステムプロンプト最適化 |
| `/harness-audit` | ハーネス設定の最適化監査 |

### 分析・推論スキル（7個）

| スキル | 説明 |
|--------|------|
| `/ensemble-vote` | アンサンブル投票による意思決定 |
| `/loop-control` | 自律的改善ループ管理 |
| `/reverse-analyze` | リバースエンジニアリング分析 |
| `/tot` | Tree of Thoughts: 複数推論パス探索 |
| `/fix-issue` | GitHub Issueの調査・根本原因分析・修正 |
| `/instinct-manage` | インスティンクト管理（表示・エクスポート・インポート・進化） |
| `/harness-audit` | ハーネス監査 |

### ワークフロー・自動化スキル（5個）

| スキル | 説明 |
|--------|------|
| `/chain` | スキルチェーン構築・実行（データ受け渡し） |
| `/checkpoint` | Gitチェックポイント作成・検証・一覧 |
| `/orchestrate` | マルチエージェント順次ワークフロー実行 |
| `/parallel` | スキル並列実行による高速化 |
| `/fix-issue` | Issue調査・修正 |

---

## ルール（18個）

全セッションで強制されるポリシー・ガイドライン。

### グローバルルール（4個）

| ファイル | 範囲 |
|----------|------|
| `security.md` | シークレット・入力バリデーション・認証・禁止パターン |
| `coding-standards.md` | 命名規約・関数設計・エラー処理・インポート順序・型 |
| `cost-optimization.md` | モデル選択表・トークン節約DO/DON'T・ツール効率 |
| `supply-chain-security.md` | 依存関係監査・ロックファイル保護・更新ポリシー・疑わしいパターン |

### ルートルール（11個）

| ファイル | 範囲 |
|----------|------|
| `agents.md` | エージェント利用可能・即時使用・並列実行・多角的分析 |
| `coding-style.md` | 不変性パターン・ファイル構成（200-400行）・エラー・入力バリデーション |
| `continuous-learning.md` | パターン抽出・インスティンクト・スキル進化・セッションメモリ |
| `git-workflow.md` | Conventional Commitsフォーマット・PRワークフロー・機能実装プロセス |
| `hooks.md` | フックタイプ・現行フック・自動承認・TodoWrite実践 |
| `multi-agent.md` | 並列実行・反復的取得・サブエージェント・パイプライン |
| `patterns.md` | APIレスポンス形式・カスタムフック・リポジトリパターン・スケルトンプロジェクト |
| `performance.md` | モデル選択（Haiku/Sonnet/Opus）・コンテキスト管理・ultrathink + plan |
| `security.md` | 必須チェック・シークレット管理・セキュリティ対応プロトコル |
| `testing.md` | 最低80%カバレッジ・TDD必須・トラブルシューティング |
| `token-optimization.md` | モデルルーティング・戦略コンパクション・サブエージェント・MCPバジェット |

### フロントエンドルール（1個）

| ファイル | 範囲 |
|----------|------|
| `frontend/react-patterns.md` | コンポーネント設計・フック・状態管理・パフォーマンス・アクセシビリティ・エラーハンドリング |

### バックエンドルール（1個）

| ファイル | 範囲 |
|----------|------|
| `backend/api-guidelines.md` | エンドポイント設計・入力バリデーション・エラーフォーマット・ミドルウェア・DB操作・レスポンス設計 |

### Cognitiveルール（1個）

| ファイル | 範囲 |
|----------|------|
| `cognitive/uncertainty-expression.md` | 信頼度レベル・表現フォーマット |

---

## フック（16個）

ライフサイクルイベント別の JavaScript 自動化。

### SessionStart（1個）

| フック | 目的 |
|--------|------|
| `session-start.js` | セッション状態の初期化 |

### SessionEnd（1個）

| フック | 目的 |
|--------|------|
| `session-end.js` | セッション状態の永続化 |

### Stop（1個）

| フック | 目的 |
|--------|------|
| `session-end.js` (async) | 最終セッション状態の永続化 |

### PreToolUse（4個）

| フック | マッチャー | 目的 |
|--------|-----------|------|
| `pre-tool-guard.js` | Bash | Bashコマンドの安全性検証 |
| `pre-tool-guard.js` | Edit\|Write | ファイル操作の安全性検証 |
| `prettier --write` | Edit | 編集前のファイル自動フォーマット |
| `ssrf-guard.js` | WebFetch | WebリクエストのSSRF保護 |

### PostToolUse（6個）

| フック | マッチャー | 目的 |
|--------|-----------|------|
| `post-tool-verify.js` | Edit\|Write | ファイル操作結果の検証 |
| `architecture-guard.js` | Edit\|Write | アーキテクチャルール強制 |
| `test-runner.js` | Edit\|Write | 関連テストの自動実行 (async) |
| `cost-monitor.js` | — | セッションコストの追跡 (async) |
| `telemetry-collector.js` | — | 使用状況テレメトリの収集 (async) |
| `circuit-breaker.js` | — | カスケード障害の検出 (async) |

### UserPromptSubmit（1個）

| フック | 目的 |
|--------|------|
| `prompt-validator.js` | 処理前のユーザープロンプト検証 |

### PreCompact（1個）

| フック | 目的 |
|--------|------|
| `pre-compact-protector.js` | 圧縮前の機密コンテキスト保護 |

### SubagentStart（1個）

| フック | 目的 |
|--------|------|
| `subagent-monitor.js` (async) | サブエージェントライフサイクルの監視 |

### SubagentStop（1個）

| フック | 目的 |
|--------|------|
| `subagent-monitor.js` (async) | サブエージェント完了の追跡 |

### PostToolUseFailure（2個）

| フック | 目的 |
|--------|------|
| `on-failure-recover.js` | ツール障害時のリカバリー試行 |
| `circuit-breaker.js` | カスケード障害の検出・停止 |

### TeammateIdle（1個）

| フック | 目的 |
|--------|------|
| `quality-gate.js` | チームメイトアイドル時の品質チェック |

### TaskCompleted（1個）

| フック | 目的 |
|--------|------|
| `task-validator.js` | 完了タスク結果の検証 |

---

## ワークフローパターン

スキルとエージェントを組み合わせた標準的なワークフロー。

### 機能開発

```
/plan → planner エージェント → architect エージェント → /tdd → /review-code
```

**用途:** 新機能・大型リファクタリング
**目的:** 詳細計画 → アーキテクチャレビュー → テスト駆動実装 → 品質確保

### バグ修正

```
/build-fix → build-error-resolver エージェント → /tdd → /review-code
```

**用途:** ビルド・型エラー・バグ修正
**目的:** エラー段階修正 → テスト検証 → 品質確保

### テスト駆動開発（TDD）

```
/tdd → tdd-guide エージェント → test-writer エージェント → /review-code
```

**用途:** テスト駆動で機能を実装
**目的:** テストファースト → 段階実装 → カバレッジ達成

### セキュリティ

```
/security-scan → security-reviewer エージェント → /review-code
```

**用途:** セキュリティ脆弱性検出
**目的:** OWASP Top 10監査 → 脆弱性修正 → 検証

### リファクタリング

```
/refactor-clean → refactor-cleaner エージェント → /review-code
```

**用途:** デッドコード削除・最適化
**目的:** 不要コード特定 → 安全な削除 → 機能確保

### マルチエージェント

```
/orchestrate → 複数エージェント並列/順次実行 → /quality-gate
```

**用途:** 複雑な一括処理
**目的:** 並列処理による高速化・分散管理

### 自律改善ループ

```
/loop-start → loop-operator エージェント → /loop-status → /quality-gate
```

**用途:** 自動反復による改善
**目的:** サーキットブレーカー付きの自律ループ

### 継続学習

```
/learn → /instinct-status → /evolve → /promote
```

**用途:** セッションパターンの永続化
**目的:** インスティンクト化 → スキル進化

---

## 環境変数（settings.json）

Claude Code 統合動作を制御する環境変数。

| 変数名 | 値 | 目的 |
|--------|-----|------|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `50` | 自動コンパクションしきい値 |
| `DISABLE_AUTOUPDATER` | `1` | 自動更新を無効化 |
| `DISABLE_MICROCOMPACT` | `1` | マイクロコンパクションを無効化 |
| `DISABLE_ERROR_REPORTING` | `1` | エラーレポートを無効化 |
| `CLAUDE_CODE_AUTO_CONNECT_IDE` | `1` | IDEへの自動接続 |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | `1` | IDE自動インストールをスキップ |
| `CLAUDE_CODE_IDE_SKIP_VALID_CHECK` | `1` | IDE検証チェックをスキップ |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `0` | テレメトリを無効化 |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` | 非必須トラフィックを無効化 |
| `MAX_THINKING_TOKENS` | `31999` | 最大思考トークン数 |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `1` | エージェントチームを有効化 |
| `ENABLE_TOOL_SEARCH` | `auto:8` | ツール検索を有効化（結果8件） |
| `MAX_MCP_OUTPUT_TOKENS` | `50000` | MCP出力の最大トークン数 |
| `CLAUDE_CODE_ENABLE_COST_TRACKING` | `1` | コスト追跡を有効化 |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `haiku` | サブエージェントモデル |
| `ECC_HOOK_PROFILE` | `standard` | フックプロファイルレベル |
| `CLAUDE_CODE_ENABLE_WORKTREE_ISOLATION` | `1` | git worktree分離を有効化 |
| `CLAUDE_CODE_MAX_SUBAGENT_DEPTH` | `3` | サブエージェント最大ネスト深度 |

---

## 権限設定

`settings.json` の `permissions` セクション。操作の許可・禁止・確認。

### 許可リスト（allow）

**パッケージマネージャ:**
```bash
Bash(npm run *)
Bash(npx *)
Bash(yarn *)
Bash(pnpm *)
Bash(bun *)
Bash(make *)
```

**Git操作:**
```bash
Bash(git status)
Bash(git diff *)
Bash(git log *)
Bash(git branch *)
Bash(git add *)
Bash(git commit *)
Bash(git checkout *)
Bash(git stash *)
Bash(git fetch *)
```

**GitHub CLIクエリ:**
```bash
Bash(gh issue *)
Bash(gh pr *)
Bash(gh api *)
Bash(gh run *)
Bash(gh workflow *)
```

**言語ツール:**
```bash
Bash(cargo *)
Bash(go *)
Bash(python3 *)
Bash(pip *)
```

**ファイル読み取り:**
```bash
Read(src/**)
Read(lib/**)
Read(app/**)
Read(tests/**)
Read(test/**)
Read(spec/**)
Read(docs/**)
Read(config/**)
Read(scripts/**)
Read(.github/**)
Read(*.md)
Read(*.json)
Read(*.yaml)
Read(*.yml)
```

**ファイル編集:**
```bash
Edit(src/**)
Edit(lib/**)
Edit(app/**)
Edit(tests/**)
Edit(test/**)
Edit(spec/**)
```

### 禁止リスト（deny）

**危険なコマンド:**
```bash
Bash(curl *)
Bash(wget *)
Bash(rm -rf *)
Bash(rm -r *)
Bash(sudo *)
Bash(chmod 777 *)
Bash(chmod -R 777 *)
Bash(eval *)
Bash(exec *)
Bash(*> /etc/*)
Bash(*| sh)
Bash(*| bash)
Bash(*| zsh)
```

**危険なGit操作:**
```bash
Bash(git push --force *)
Bash(git reset --hard *)
Bash(git clean -fd *)
```

**シークレット保護:**
```bash
Read(.env)
Read(.env.*)
Read(*.env)
Read(secrets/**)
Read(**/*secret*)
Read(**/*credential*)
Read(**/*password*)
Read(**/*.pem)
Read(**/*.key)
Read(**/*.p12)
Read(**/*.pfx)
Read(**/id_rsa*)
Read(**/.aws/**)
Read(**/.ssh/**)
```

**危険なPython:**
```bash
Bash(*pickle.loads*)
Bash(*yaml.load*)
```

### 確認リスト（ask）

**リモート操作（確認必須）:**
```bash
Bash(git push *)
Bash(git push --force-with-lease *)
Bash(gh pr create *)
```

**デプロイ・インストール:**
```bash
Bash(npm publish *)
Bash(docker *)
Bash(pip install *)
Bash(cargo add *)
Bash(go get *)
```

**設定変更:**
```bash
Edit(package.json)
Edit(tsconfig.json)
Edit(*.config.*)
```

**スクリプト・SQL作成:**
```bash
Write(**/*.sql)
Write(**/*.sh)
```

---

## コスト最適化ガイド

### モデル選択表

| タスク | 推奨モデル | 根拠 |
|--------|-----------|------|
| タイポ・リネーム・軽微修正 | haiku | 最小限の複雑度 |
| コード説明・Q&A | haiku/sonnet | 読み込み中心 |
| 機能実装 | sonnet | 能力とコストのバランス |
| アーキテクチャ設計 | opus | 複雑な推論が必要 |
| セキュリティ監査 | opus | 徹底性が必須 |

### トークン節約の DO/DON'T

**DO:**
- `/clear` で主要タスク完了後にコンテキストリセット
- `Glob`/`Grep` を使用（完全なファイル読み込みより効率的）
- 大きなファイルは特定行範囲で読み込み（`offset`/`limit`）
- 自由探索には `Task` ツール使用（コンテキストオフロード）
- 関連質問をバッチ化（複数質問を1つのプロンプト内で）

**DON'T:**
- 念のためコードベース全体を読み込む
- 関連タスク間で古いコンテキストを保持
- 簡単な操作について冗長な説明を求める
- 同じ情報について冗長な検索を実行
- コンテキスト最後の20%で大規模リファクタリング

### コンテキスト管理

```bash
/manage-context          # ウィンドウ使用量監査・最適化
/strategic-compact       # 手動圧縮（論理的な区切りで）
/compact                 # タスク間のマイルストーン圧縮
/clear                   # セッションリセット（新しい無関連タスク用）
```

---

## セキュリティチェックリスト

### コミット前に必須

- [ ] シークレットがハードコードされていない（API鍵・パスワード・トークン）
- [ ] すべてのユーザー入力が検証されている
- [ ] SQL インジェクション対策（パラメータ化クエリ使用）
- [ ] XSS 対策（サニタイズされたHTML）
- [ ] CSRF 保護が有効
- [ ] 認証・認可が検証されている
- [ ] レート制限がすべてのエンドポイントで設定されている
- [ ] エラーメッセージが機密情報を漏らしていない

### シークレット管理

```typescript
// BAD: ハードコード
const apiKey = "sk-proj-xxxxx"

// GOOD: 環境変数
const apiKey = process.env.OPENAI_API_KEY
if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

### セキュリティ対応プロトコル

脆弱性発見時：
1. **直ちに停止**
2. `security-reviewer` エージェントを起動
3. **CRITICAL 脆弱性を修正**してから続行
4. 露出したシークレットをローテーション
5. コードベース全体で同様の問題をレビュー

---

## 継続学習システム

セッション終了時にパターンを自動キャプチャ。インスティンクト化 → スキル進化。

### コマンド

```bash
/learn                   # 現在セッションのパターン抽出
/instinct-status         # 学習済みインスティンクト表示
/instinct-export         # エクスポート
/instinct-import         # インポート
/evolve                  # インスティンクト進化
/promote                 # インスティンクト → スキル昇格
```

### インスティンクト信頼度スコア

| スコア | 段階 | 昇格条件 |
|--------|------|---------|
| 0.0–0.3 | 新規 | — |
| 0.3–0.6 | 開発中 | — |
| 0.6–0.8 | 成熟 | — |
| 0.8+ | 確立 | スキル昇格が可能 |

---

## その他のリソース

- **CLAUDE.md** - メイン指示・詳細なワークフロー・トークン最適化戦略
- **memory/MEMORY.md** - メモリシステムドキュメント
- **rules/** - すべてのポリシー・ガイドラインの詳細
- **agents/** - 各エージェントの完全な指示書
- **skills/** - 各スキルの実装詳細

---

**最終更新:** 2026-03-27
**設定バージョン:** Claude Code統合完全版
**言語:** 日本語
**技術用語:** English
