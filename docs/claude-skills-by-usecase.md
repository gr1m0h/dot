# Claude Skills — 状況別逆引きチートシート

明示的に呼んで速くする。`home/dot_claude/skills`（38 skills）+ plugins を「いつ・何を・どう呼ぶか」で整理。

最終更新: 2026-08-06 · 凡例: **[標準]** Claude Code 同梱 / **[自作]** ~/.claude/skills / **[plugin]** 名前空間つき

## 0. 使い方の原則

- **明示起動 > 自動起動。** skill の自動起動は description マッチ頼みで確実ではない。「この状況ならこれ」が分かっているなら `/名前` で呼ぶ — 起動の 1 秒が、意図しないアプローチで進む 30 分を防ぐ。
- **コンボで覚える。** 単発の skill より「並び」が価値。各節のフローがそのまま打つ順番。
- **締めは必ず report。** 顧客タスクはどのフローでも終点が `/sreaas:task report`。忘れても unreported 検知が拾うが、その場で締めるのが最安。
- **迷ったら「放置で回せないか」を先に考える**（§5）。対話で潰すのは、対話でしか進まないタスクだけ。
- **メインセッション = 司令塔。** 仕様・レビュー・意思決定だけを手元に残し、実行は background subagent / worktree にファンアウトする。スループットはタイピング速度でなくレビュー帯域から生まれる。

## 1. 朝・昼・夕ルーチン

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| 朝イチ、今日やることを流す | `/batch` [自作] | inbox.md のタスクを background subagent へ並列発注（15分）。各 worker は branch + diff + 検証 + 推奨まで用意して待つ（publish はしない）。空なら何もしない — 前日/金曜に仕込んでおく |
| タスクを思いついた（今やらない） | `/batch add case: タスク` [自作] | inbox に追記だけ。成果物・完了条件は dispatch 時に補完される |
| 昼・夕の回収 | `/batch status` [自作] | done（成果物パス）/ running / failed を要約。レビュー→採用なら `/batch publish <task>`（採否判断は人間） |
| タスクが一段落した | `/sreaas:task report` [plugin] | 現セッションの成果物を topotal/SRE_* Issue に記録し close/carry over 判定。**タスク完了の直後に打つ** |
| ターミナルの ⚠ が点いている | `/sreaas:task report <issue>` | unreported.md に溜まった未報告セッションの消化。放置すると成果が消える |

```
朝: statusline 確認（📥 queued / ⚠ unreported）→ /batch → 日中は判断業務
昼: /batch status → 軌道修正
夕: /batch status → レビュー → /batch publish（採用分）→ /sreaas:task report
```

**batch タスクのライフサイクル**（inbox の行の状態遷移）:

1. `[ ]` queued — `/batch add` 直後。行に積まれただけで何も走らない
2. `[~]` dispatched — `/batch` で background subagent へ発注。agent は調査・ブランチ準備・機械検証まで行い `~/.claude/batch/out/` に 6 セクション契約のレポートを書く。**外部への書き込み（push/PR/コメント/apply）は一切しない**
3. `[x]` done — `/batch status` で回収、行は当日 log へ。ここで人間がレポートを読み「判断が要る点」に答える
4. 公開・記録 — 採用したものだけ外に出す。コード系は `/batch publish`（**PR は本文なし・タイトルのみ** — レポート由来の機微情報が PR description に混入する事故の防止。本文は人間が書く）、調査系は Issue/Notion へ人間が記入 + `/sreaas:task report` で社内記録
5. 掃除 — 反映済みレポートは out/ から削除（repo に残す価値があれば案件 repo の `reports/` へ移動）。**不変条件: out/ が空 = やり残しゼロ**。残数は session-start hook が `BATCH_REVIEW` として毎セッション表示するので消し忘れは検知される

> **自動投入される行がある:** inbox に `personal: retro-learn` が勝手に積まれていることがある — session-start hook が7日周期で自動追加する学習ループの収穫タスク（§11）。手で書き足す必要はなく、普通に dispatch に含めればよい。

## 2. 調査・レポート（SREaaS の主戦場）

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| 顧客「〜について調べてほしい」 | `/investigation-report` [自作] | 成果物形式+完了条件を**先に**固定 → subagent がスキャン（離れてよい）→ 全主張の出典検証 → Issue-ready 報告書 |
| repo/インフラでなく Web の調べ物 | `/deep-research` [標準] | 多源泉検索+敵対的検証つきレポート。質問が曖昧なら先に絞り込みの質問が来る |
| 急ぎでない調査依頼 | `/batch add` → 翌朝発注 | その場で対話に付き合わず inbox へ。契約フィールドは dispatch 時に確認される |
| Claude API・モデル・料金の事実確認 | `/claude-api` [標準] | 一次情報リファレンス。LLM 関連は記憶で答えさせず必ずこれを読ませる |
| 過去に同じことを調べた気がする | `/search-memory` [自作] | 認知メモリから過去の学び・決定・パターンを検索してから着手 |

```
調査依頼 → /investigation-report（契約固定 ← 顧客とのズレをここで潰す）
        → 委任スキャン → 出典検証 → 報告書 → /sreaas:task report
```

## 3. インシデント・障害

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| 障害調査・ポストモーテム | `/incident-analysis` [自作] | AWS CLI + Datadog + repo 横断でエビデンス収集 → タイムライン・根本原因・恒久対応つき報告書 |
| セキュリティ起因の疑い | security-reviewer agent | Error Handling 規約: **停止 → security-reviewer → 修正 → 続行**。続行を優先しない |
| 復旧後のデプロイ監視 | `/loop 5m <確認プロンプト>` [標準] | 定期ポーリングに。単発確認には使わない |
| 実行時の挙動がおかしい（Claude Code 自体） | `/debug` [標準] | デバッグログを有効化して調査 |

```
/incident-analysis → ポストモーテム文書化 → /sreaas:task report
（案件として大きければ後日: case-reflect → /company-blog で資産化 §12）
```

## 4. 実装・修正

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| 要件がまだ曖昧 | `brainstorming` [plugin] | 対話で意図・要件・設計を探索してから作る |
| 提案の穴を先に潰したい | `proposal-review` [plugin] | 懸念点・弱点の多角的洗い出し。**顧客提案の前に必ず** |
| 新機能・アーキテクチャ変更 | `/plan` [自作] | 段階的計画+リスク評価、**承認まで待つ**。client repo では必須（spec-first） |
| 高リスクな技術選定 | `/ensemble-vote` [自作] | 複数推論パスの多数決。アーキテクチャ選定・不可逆な判断に |
| 実装本体 | `/tdd-workflow` [自作] | テスト先行を強制。80%+ カバレッジ。lint/型/テストは hooks（post-tool-verify / test-runner）が編集のたびに自動実行される |
| 命名・型・エラー処理の規約を効かせたい | `/coding-standards` [自作] | TS/JS/React/Node の規約コンテキストを注入。新規コードを書き始める前に |
| typo・rename・軽微修正 | そのまま依頼（skill 不要） | Working Style 規約で単純変更は即実行。旧 /quick-fix は廃止（2026-07 統廃合） |
| ビルドが壊れた | build-error-resolver agent | 最小 diff でビルド/型エラーのみ修復。旧 /build-fix は廃止、agent に一本化 |
| GitHub Issue 起点の修正 | `/fix-issue` [自作] | 根本原因分析つきで Issue を潰す。実装修正系 skill はこれに集約 |
| 死コード掃除 | `/refactor-clean` [自作] | knip/depcheck/ts-prune で検出 → テスト検証つき削除 |
| 動くことを目で確認したい | `/verify` / `/run` [標準] | アプリを実際に起動して挙動観察。「テストが通る」で止めない。起動が特殊な repo は一度 `/run-skill-generator` でレシピを skill 化 |

```
顧客 repo のゴールデンパス:
brainstorming（曖昧なら）→ /plan（承認待ち）→ /tdd-workflow
→ /code-review → /security-review（入力/認証を触ったら）
→ /verify → /create-pr → ship check（3文説明）→ /sreaas:task report
```

> **検証は機械チェックで:** Opus 5+/Fable 5 は自己検証するため「別 subagent で検証」ステップは足さない（2026-07 公式ガイド）。lint/型/テスト/CI の機械チェックで十分。

## 5. 放置で回す — goal / batch / loop / background

「どの装置で手離れさせるか」の使い分けが生産性の核心。**直列の粘りは /goal、並列の発注は /batch、定期の見張りは /loop**。

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| 1つの重いタスクを完了まで押し切りたい | `/goal <完了条件>` [標準] | 別モデル（haiku）が transcript を評価し、**条件を満たすまでターンを跨いで働き続ける**。条件は短く測定可能に: `/goal 全テスト green かつ lint clean。20 turn で打ち切り`。`/goal show` で状態、`/goal clear` で解除。1セッション1ゴール・trust mode 必須 |
| 複数タスクを一斉に捌きたい | `/batch` [自作] | inbox 起点で background subagent へ並列発注（上限6）。機械検証必須・GitHub 書き込み禁止が織り込み済み |
| 定期的に様子を見たい | `/loop 5m /foo` [標準] | プロンプト/skill を一定間隔で再実行（デフォルト10m）。デプロイ監視・CI 見張りに |
| 調査を裏で走らせて別作業したい | Agent tool（`run_in_background`） | 「バックグラウンドで調べておいて」と言えばよい。完了時に通知が来る |
| 大規模監査・移行・網羅レビュー | Workflow（要 "ultracode" / 「workflow で」） | 数十 agent のオーケストレーション（find → 敵対的 verify → 合成）。明示オプトインが必要。通常は Agent 並列で足りる |
| ターミナル外で完結させたい | `claude -p "/goal …"` [標準] | 非対話でゴールループを完走させる。cron や scheduled-task から叩ける |

> **注意 — /batch の名前衝突:** Claude Code 同梱の bundled `/batch`（大規模並列コード変更）は、自作 `/batch`（朝バッチ発注）に上書きされていて呼べない。大規模並列変更がしたい時は Workflow か Agent 並列を使う。

## 6. PR・レビュー

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| PR を作る | `/create-pr` [自作] | 変更分析 → 要約+リスク評価+テスト計画つき PR を gh CLI で作成。事前に `gh pr list --search` で既存スコープ確認 |
| コミット前に自分の diff を見てもらう | `/code-review` [標準] | 正当性バグ+品質の指摘。`--fix` で working tree に適用。effort 指定可（low〜max） |
| 動くけど汚い気がする | `/simplify` [標準] | 再利用・簡素化・効率のクリーンアップを適用。バグ探しはしない（それは /code-review） |
| 他人の PR をレビューする | `/review` / `/pr-summary` | 標準 /review はレビュー実施、自作 /pr-summary は要約+リスク+レビュー観点。全指摘は出典検証、裏取り不能なら「unverified hypothesis」明記 |
| 自分の PR に指摘が来た | `/pr-review-respond` [自作] | 指摘を確信度つきで評価 → working tree に修正適用 → **返信ドラフトを画面に出す（投稿は人間）** |
| リリースする | `/release` [自作] | semver 判定 + changelog 生成 + リリース作成。事前に `/audit-supply-chain`（§8、license 込み） |

> **通信境界（最重要）:** PR/Issue へのコメント投稿はどの skill 経由でも自動でしない（permissions.deny で機械的に禁止済み）。`/code-review --comment` も使わない。ドラフトを受け取って人間が投稿する。

## 7. テスト品質

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| カバレッジが足りているか知りたい | `/test-coverage` [自作] | 80% 閾値未満のファイルを検出し、不足テストを生成 |
| テストが「強い」か疑わしい | `/mutation-test` [自作] | コードに変異を入れてテストが検出できるか測定（mutation score）。カバレッジ高いのに不安な時 |
| 境界値・例外系を網羅したい | `/property-test` [自作] | ランダム入力に対する不変条件テスト。example-based が見逃すエッジを拾う |
| 入力処理をストレステスト | `/fuzz` [自作] | クラッシュ・脆弱性をランダムデータで発見 |
| ユーザーフローを通しで確認 | `/e2e` [自作] | Playwright で E2E 生成・実行。screenshot/video/trace 保存、flaky 検出 |
| eval 駆動で進めたい | `/eval define\|check\|report` [自作] | 成功基準を先に定義し pass@k を追跡（生成と評価の分離） |

## 8. セキュリティ・依存

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| ブランチの変更を出す前に | `/security-review` [標準] | pending changes のセキュリティレビュー。入力・認証・API を触ったら必須 |
| コードベース全体の棚卸し | `/security-scan` [自作] | OWASP 2025 Top 10 準拠の全体スキャン（差分でなく全体） |
| 設計段階の脅威分析 | `/security-scan threat-model` [自作] | STRIDE + DREAD スコアリングで体系的に。旧 /threat-model を統合したモード |
| 依存を追加する前・OSS 公開前 | `/audit-supply-chain` [自作] | typosquat・AI ハルシネーションパッケージ・既知脆弱性 + ライセンス互換性（旧 /audit-license 統合済み、`--licenses-only` / `--strict` あり）。Critical/High は BLOCK |

> **日常の防御は hooks が常時担当:** pre-tool-guard（危険コマンド遮断）/ ssrf-guard（内部ネットワーク遮断）/ secrets 読み取り deny。skill を呼ぶのは「監査を能動的にかける」場面だけでよい。

> **2026-07 統廃合:** /threat-model → /security-scan に、/audit-license → /audit-supply-chain に統合。ドメイン外の /firmware-audit・/protocol-check・/reverse-analyze は退避（`~/.claude/backups/pruned-20260714/`、mv で復活可）。

## 9. DB・インフラ

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| MySQL / PostgreSQL / ClickHouse を触る | `mysql` / `postgres` / `clickhouse-io` [自作] | スキーマ設計・インデックス・クエリ最適化のベストプラクティスが注入される。DB ファイルを触れば自動起動するが、設計相談は明示起動が確実 |
| スキーマ・マイグレーションのレビュー | database-reviewer agent | skill でなく agent（§15）。migration を書いたら通す |

## 10. SREaaS 定例・月次

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| タスク完了直後（毎回） | `/sreaas:task report` [plugin] | 現セッション限定の軽量モード。成果物リンクつきレポートを Issue に残し close/co 判定 |
| 金曜・イテレーション締め | `/sreaas:task report all` | 前金曜 0:00 以降の全案件横断。木曜夜ルーチンが draft-only で先回りしている → ドラフト確認から始める |
| 特定 Issue だけ処理 | `/sreaas:task report #NN` | 短縮形 OK（`案件#NN` / `owner/repo#NN`、SRE_ プレフィックス省略可） |
| 月初の Monthly コメント | `/sreaas:monthly` → 確認 → `apply` | default はドラフトのみ。`deep` で当月 transcripts も走査。第1木曜夜に自動ドラフトあり |
| 案件・プロジェクトの節目 | `case-reflect` [plugin] | 対話で課題認識・打ち手・決め手・学びを引き出し、物語形式 Markdown に保存 |

```
週次: 木曜夜（自動 draft + kpi.md 追記）→ 金曜昼: ドラフト確認 → apply（5分）→ kpi.md を1分眺める
月次: 第1木曜夜（自動 draft）→ /sreaas:monthly apply → 月末に kpi.md 振り返り
```

## 11. 学習・振り返り・ナレッジ

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| 学習時間に入る（個人 repo / ~/learn） | `/mode learning` [自作] | セッションの構えを切替 — 答えを書かず地図を渡す。基準は「時間と場所」（仕事 = Speed、学習時間 = learning）、タスク種別ではない。「Speed」で復帰 |
| 学習ループの現在地を知りたい | `/learn` [自作] | 引数なし = status。backlog 未着手/演習中、retro 鮮度、レビュー待ちを要約し次の一手を推奨 |
| 学びたいことを思いついた（今すぐ） | `/learn add <topic>` [自作] | backlog に1行追記するだけの都度の口。週次 retro を待たない。dispatch も learn-map も走らない |
| retro-learn のレポートが届いた | `/learn review` [自作] | 題材候補を番号提示 → **選ぶだけ**。BACKLOG.md 追記 + `last-retro:` 更新 + レポート削除まで全部セッションがやる |
| 学習時間に入る | `/learn start [topic]` [自作] | backlog から番号選択（指定も可）→ learn-map を起動して演習環境を生成。learn-map/learn-coach は独立 skill のまま（教材生成・コーチング規約が大きいため） |
| 演習で詰まった | `/learn-coach` [自作] | 段階ヒント（L1 言語化 → L4 答え、1ターン1レベル）。ギブアップ宣言か30分格闘まで L4 は開かない |
| 演習が終わった | `/learn done` [自作] | STRUGGLE_LOG から弱点を要約（繰り返す弱点は add 候補に）→ backlog を `[x]` に。パターンが出たら /reflect へハンドオフ |
| いいパターンを再利用したい | `/reflect` [自作] | **旧 /learn を統合（2026-08）**: 非自明な問題を解いた直後に呼ぶと Reflexion 振り返り + 再利用パターンを skills/learned/ に skill 化。打ち忘れても週次 retro-learn が transcript から拾う（安全網） |
| 大きめの仕事を終えた | `/reflect` [自作] | Reflexion 框組の構造化振り返り。永続化すべき学びを抽出 |
| 過去の知見を探す | `/search-memory` [自作] | 認知メモリから検索。着手前に一度 |
| 覚えさせたい | `/update-memory` [自作] or 「覚えて」 | 自作認知メモリへ保存。ネイティブ auto-memory と二重管理なのは既知の課題 |
| 構造変更後のアーキテクチャ文書更新 | `/update-codemaps` [自作] | コードベース構造を解析して docs/CODEMAPS/* を diff 追跡つきで再生成 |
| README/CONTRIB が古い気がする | `/update-docs` [自作] | package.json 等の source-of-truth から同期。90 日以上更新なしの陳腐化ドキュメントを検出 |

**学習ループのライフサイクル**（2026-08 機械化 — 覚えておくことはゼロ）:

1. 捕捉 — 業務中（Speed）の learning flag は transcript に堆積するだけ。ログ不要。**今すぐ残したいものは `/learn add <topic>`**（都度の口）
2. 収穫 — `~/learn/BACKLOG.md` の `last-retro:` から7日経過すると session-start hook が `personal: retro-learn` を batch inbox に**自動投入** → いつもの `/batch` で走る（§1。batch にとってはただのタスクの1つ）
3. 選別 — `/learn review` で題材候補から番号選択 → BACKLOG.md 追記 + `last-retro:` 更新 + レポート削除まで自動。**完了するまで hook が「レビュー待ち」を出し続ける**
4. 変換・実践 — 学習時間に `/learn start`（backlog から番号選択 → learn-map が演習環境を生成）→ `/mode learning` + `/learn-coach`。入口は hook の `LEARN_BACKLOG` 表示
5. 定着 — `/learn done` で STRUGGLE_LOG の弱点を回収（繰り返す弱点は次の題材候補へ）+ backlog を `[x]`。パターンが出たら `/reflect` が skills/learned/ に skill 化 → 次の業務セッションで発火し、業務が次の flag を生んで 1 に還流

学びのドメイン（BACKLOG.md・last-retro・レビュー手順）の**所有者は learn skill で、verb がそのままライフサイクル**（add 捕捉 / review 選別 / start 変換 / done 定着、引数なし = status）。batch は実行基盤、hook は表示と自動投入のみ、learn-map は backlog の消費者、パターンの skill 化は `/reflect`（旧 /learn の抽出動作を統合）。

役割分担: `/learn` = 人間の学習ライフサイクルの関節（add/review/start/done）/ `/mode learning` = セッションの構え / `/learn-map` = 教材生成（before）/ `/learn-coach` = 演習中の専門コーチ（during、ヒント段階制が優先）/ `/reflect` = ハーネスの記憶（セッション振り返り + パターン skill 化、旧 /learn 統合）。case-reflect は別軸（案件の節目駆動、対象は仕事の判断とストーリー）。仕事中に協働スタイルにしたいときはモードでなく「骨格は自分で書く」等のその場指示で。

## 12. コンテンツ制作

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| 登壇資料を作る・直す | `/slide-deck` [自作] | 段階対話（context → message → 構成 → 外部リサーチ → 生成）→ TDS 準拠 HTML/PDF + 台本 + プレゼンターモード |
| 個人ブログ・登壇報告 | `/write-article` [自作] | 「ぐりもお」文体・構成ルール準拠の Markdown |
| 案件を会社ブログに資産化 | `case-reflect` → `/company-blog` | 振り返り → 機密除去+一般化した会社テックブログ案。学習サイクルの最終段 |
| グラフ・ダッシュボードのデザイン | `/dataviz` [標準] | 色覚対応パレット等、可視化のデザイン指針 |

## 13. ハーネス保守

| 状況 | 呼ぶ | 起きること・コツ |
|---|---|---|
| 月次の全体監査 | `/harness-audit` [自作] | settings/hooks/rules/skills/agents をスコアリング。CLAUDE.md/rules のトークン効率化パスを含む（旧 prompt-optimize 統合済み） |
| 使い方の癖を数字で見る | `/insights` [標準] → `/insights-apply` [自作] | セッション分析レポート → 日本語 HTML 化 + 推奨を1件ずつ apply/skip |
| settings.json・hooks を変えたい | `/update-config` [標準] | 「毎回 X して」系の自動化は hook でしか実現できない — 必ずこれ経由。**変更後は dot repo（chezmoi）へ反映まで** |
| permission プロンプトが多い | `/fewer-permission-prompts` [標準] | transcript を走査して読み取り専用 allowlist を提案 |
| セッションが重い・遅い | `/manage-context` [自作] | コンテキスト健全性の監査、/clear タイミングの提案 |
| コスト・使用量を見たい | `/dashboard` [自作] | テレメトリ+コスト統計（旧 cost-report 統合済み）。期間指定可: `/dashboard week` |
| 環境がおかしい気がする | `/doctor` [標準] | セットアップ診断（未使用設定・遅い hook の検出） |
| キーバインド変更 | `/keybindings-help` [標準] | keybindings.json の編集を案内 |

## 14. セッション操作早見（built-in コマンド）

| コマンド | いつ |
|---|---|
| `/compact` | マイルストーン到達時に文脈圧縮（続きは同じ流れで） |
| `/clear` | 無関係なタスクに移る前にリセット（1タスク1セッション） |
| `/rewind` | 失敗したアプローチを巻き戻してやり直す |
| `/btw` | 脇道の質問をコンテキスト汚染なしで聞く |
| `/goal show` / `/goal clear` | ゴールループの状態確認 / 解除（§5） |
| `/model` / `/fast` | モデル切替 / Opus 高速出力モードのトグル |
| `! <command>` | 対話ログに乗せたいコマンドを自分で実行（インタラクティブな認証等） |

## 15. skill でなく agent を呼ぶ場面

skill は「手順」、agent は「新鮮なコンテキストを持つ委任先」。探索・レビューは agent が正解のことが多い。「〜を agent でやって」と言えば足りる。ただし**自分の作業の検証は委任しない**（自己検証で足りる）。

| 状況 | agent | コツ |
|---|---|---|
| 広く探して結論だけ欲しい | `Explore` | 読み取り専用の広域検索。自分でも同じ検索をしない（二重コスト） |
| 実装が終わった（commit 前） | —（機械チェック） | Fable 5/Opus 5+ は自己検証するため evaluator の常用は廃止（2026-07）。lint/テスト/CI で担保し、agent 検証は明示要求時のみ |
| コードを変更した | `code-reviewer` | 変更後は毎回。skill の /code-review（diff 対象）と使い分け |
| 入力・認証・API を触った | `security-reviewer` | 疑いがあれば停止してでも先に通す |
| スキーマ・マイグレーション | `database-reviewer` | DB skill（§9）は書く時、これは見る時 |
| 独立タスクの並列実行 | 複数 agent 同時起動 | 1メッセージで同時に投げる。同じ working tree を触るものは worktree 分離か逐次 |

---

**このチートシートの育て方:** 「skill を呼び忘れて遠回りした」場面に気づいたら、その状況を行として足す。月次の `/harness-audit` で使われていない行（= 使われていない skill）を間引く。逆引きの鮮度がそのまま日々の速度になる。

Source: `gr1m0h/dot` — `home/dot_claude/`（インベントリ詳細は README.md）
