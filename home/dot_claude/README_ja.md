# Claude Code 設定

開発ワークフロー、セキュリティ強制、AI支援コーディングのための個人用 Claude Code 設定。

## ディレクトリ構成

```
.claude/
├── CLAUDE.md              # メイン指示 & インタラクションモード
├── agents/                # 34個の専門エージェント定義
├── skills/                # 52個のスラッシュコマンドスキル
├── rules/                 # 14個のポリシー・ガイドライン
├── hooks/                 # 16個のJavaScript自動化フック
├── memory/                # 永続的な知識 & セッション状態
└── settings.json          # Claude Code設定
```

## インタラクションモード

`CLAUDE.md` で設定。モード名を入力して切り替え。

| モード | トリガー | 動作 |
|--------|----------|------|
| **Learning**（デフォルト） | — | ヒントと参考資料を先に提示、コードは最後 |
| **Guided** | `guided` | 選択肢を提示、ユーザーがスケルトンを書き、Claudeが詳細を埋める |
| **Speed** | `speed` | 制約なし、最大速度で実装 |

## エージェント

34個のエージェント定義をドメイン別に整理。`Task` ツールの `subagent_type` で起動。

### コア（トップレベル）

| エージェント | 用途 |
|-------------|------|
| `planner` | 複雑な機能の実装計画 |
| `architect` | システム設計・アーキテクチャ判断 |
| `tdd-guide` | テスト駆動開発の強制 |
| `code-reviewer` | 多次元コードレビュー |
| `security-reviewer` | セキュリティ脆弱性分析 |
| `build-error-resolver` | ビルド/型エラーの修正 |
| `e2e-runner` | Playwright E2Eテスト |
| `refactor-cleaner` | 不要コードの削除 |
| `doc-updater` | ドキュメント更新 |

### 専門（サブディレクトリ）

| カテゴリ | エージェント |
|----------|-------------|
| **cognitive/** | confidence-calibrator, context-optimizer, ensemble-reasoner, memory-consolidator |
| **iot/** | edge-security, firmware-dev, protocol-analyzer |
| **leader/** | orchestrator, task-planner |
| **oss/** | license-auditor, oss-contributor, supply-chain-auditor |
| **planning/** | tot-planner |
| **qa/** | code-reviewer, debugger, fuzzer, mutation-tester, property-tester, security-auditor |
| **resilience/** | fallback-handler |
| **routing/** | model-selector, tool-router |
| **security/** | reverse-engineer, threat-modeler |
| **worker/** | coder, test-writer |

## スキル

52個のスラッシュコマンド。`/スキル名` で呼び出し。各スキルは `skills/<名前>/SKILL.md` に格納。

### 開発・品質

| スキル | 説明 |
|--------|------|
| `/plan` | 実装計画の作成 |
| `/tdd` | ミューテーションテスト付きTDDワークフロー |
| `/tdd-workflow` | テスト駆動開発の強制 |
| `/build-fix` | TypeScript/ビルドエラーの段階的修正 |
| `/quick-fix` | haikuモデルによる軽量修正 |
| `/review-code` | 包括的コードレビュー |
| `/code-review` | コミットをブロックするセキュリティ重視レビュー |
| `/refactor-clean` | 不要コードの削除 |
| `/test-coverage` | カバレッジ分析・不足テスト生成 |
| `/verify` | コードベース検証（quick/full/pre-commit/pre-pr） |
| `/e2e` | Playwright E2Eテスト |

### セキュリティ・コンプライアンス

| スキル | 説明 |
|--------|------|
| `/security-scan` | OWASP 2025 Top 10 監査 |
| `/security-review` | 認証・入力・シークレットのチェックリスト |
| `/threat-model` | STRIDE脅威モデリング |
| `/audit-license` | ライセンスコンプライアンス監査 |
| `/audit-supply-chain` | サプライチェーンリスク分析 |
| `/firmware-audit` | ファームウェアセキュリティ監査 |

### 分析・テスト

| スキル | 説明 |
|--------|------|
| `/fuzz` | ファズテストのセットアップ |
| `/mutation-test` | テスト品質のミューテーションテスト |
| `/property-test` | プロパティベーステスト設計 |
| `/protocol-check` | プロトコル実装の分析 |
| `/reverse-analyze` | リバースエンジニアリング分析 |
| `/tot` | Tree of Thoughts による探索 |
| `/ensemble-vote` | アンサンブル投票による意思決定 |

### データベース

| スキル | 説明 |
|--------|------|
| `/postgres` | PostgreSQLベストプラクティス |
| `/mysql` | MySQLベストプラクティス |
| `/clickhouse-io` | ClickHouse分析パターン |

### ワークフロー・自動化

| スキル | 説明 |
|--------|------|
| `/create-pr` | PRの生成と作成 |
| `/pr-summary` | リスク評価付きPRサマリー |
| `/fix-issue` | GitHub Issueの調査と修正 |
| `/release` | セマンティックバージョニング・変更履歴 |
| `/orchestrate` | マルチエージェント順次ワークフロー |
| `/parallel` | スキルの並列実行 |
| `/chain` | スキルの順次実行 |
| `/checkpoint` | Gitベースのワークフローチェックポイント |
| `/eval` | 評価駆動開発 |

### 知識・コンテキスト

| スキル | 説明 |
|--------|------|
| `/update-memory` | メモリシステムへの知識保存 |
| `/search-memory` | メモリシステムからの検索 |
| `/update-docs` | ドキュメント同期 |
| `/update-codemaps` | アーキテクチャドキュメント |
| `/manage-context` | コンテキストウィンドウの最適化 |
| `/learn` | 再利用可能なパターンの抽出 |
| `/continuous-learning` | セッションパターンの自動抽出 |
| `/reflect` | 完了作業の構造化された振り返り |
| `/strategic-compact` | 手動コンテキスト圧縮 |

### リファレンス

| スキル | 説明 |
|--------|------|
| `/coding-standards` | ユニバーサルコーディング標準 |
| `/frontend-patterns` | React/Next.jsパターン |
| `/backend-patterns` | API/サーバーパターン |
| `/cost-report` | トークン使用量・コスト見積もり |
| `/dashboard` | テレメトリダッシュボード |

## ルール

全セッションで適用される14のポリシー文書。

| ファイル | 範囲 |
|----------|------|
| `global/security.md` | シークレット、入力検証、認証、禁止パターン |
| `global/coding-standards.md` | 命名、関数、インポート、型 |
| `global/cost-optimization.md` | モデル選択、トークン節約 |
| `global/supply-chain-security.md` | 依存関係の監査、ロックファイル保護 |
| `git-workflow.md` | Conventional Commits、PRワークフロー |
| `coding-style.md` | イミュータビリティ、ファイル構成、エラーハンドリング |
| `patterns.md` | APIレスポンス形式、フック、リポジトリパターン |
| `performance.md` | モデル選択戦略、コンテキスト管理 |
| `testing.md` | 最低カバレッジ80%、TDD必須 |
| `agents.md` | エージェントオーケストレーション・並列実行 |
| `hooks.md` | フックの種類・自動承認パーミッション |
| `security.md` | コミット前チェックリスト、シークレット管理 |
| `frontend/react-patterns.md` | コンポーネント、フック、状態管理、アクセシビリティ |
| `backend/api-guidelines.md` | RESTful設計、バリデーション、ミドルウェア |
| `cognitive/uncertainty-expression.md` | 確信度に基づく表現レベル |

## フック

16個のJavaScriptフックによる自動化。

### ツール実行前ガード

| フック | 目的 |
|--------|------|
| `pre-tool-guard.js` | Bash/Edit/Writeでのシークレット漏洩防止 |
| `ssrf-guard.js` | WebFetchのSSRF保護 |
| `architecture-guard.js` | Edit/Writeでのアーキテクチャルール強制 |
| `pre-compact-protector.js` | 圧縮前の重要コンテキスト保護 |
| `prompt-validator.js` | プロンプトの検証 |

### ツール実行後アクション

| フック | 目的 |
|--------|------|
| `post-tool-verify.js` | ツール実行後の検証 |
| `test-runner.js` | コード変更後のテスト実行 |

### システム監視

| フック | 目的 |
|--------|------|
| `circuit-breaker.js` | 失敗する操作のサーキットブレーカー |
| `cost-monitor.js` | コスト閾値の追跡・警告 |
| `quality-gate.js` | 品質ゲートの強制 |
| `task-validator.js` | タスク定義の検証 |
| `subagent-monitor.js` | 起動済みエージェントの監視 |
| `telemetry-collector.js` | 使用状況テレメトリの収集 |

### セッションライフサイクル

| フック | 目的 |
|--------|------|
| `session-start.js` | セッション初期化 |
| `session-end.js` | セッションクリーンアップ |
| `on-failure-recover.js` | 失敗時のリカバリ |

## ワークフローパターン

スキルとエージェントを組み合わせた標準ワークフロー：

```
機能開発:    /plan -> planner -> architect -> /tdd -> /review-code
バグ修正:    /build-fix -> build-error-resolver -> /tdd -> /review-code
TDD:        /tdd -> tdd-guide -> test-writer -> /review-code
セキュリティ: /security-scan -> security-reviewer -> /review-code
リファクタ:  /refactor-clean -> refactor-cleaner -> /review-code
```

## コスト最適化

- 軽微な変更にはHaikuモデル（`/quick-fix`）
- 通常の開発にはSonnet
- アーキテクチャ・セキュリティ監査にはOpus
- 主要タスク間で `/clear`
- 完全なファイル読み込みより `Glob`/`Grep` を優先
- 自由探索には `Task(Explore)` を使用
