---
description: Write technical blog articles in "ぐりもお (@gr1m0h)" voice. Use when user says "記事を書く", "ブログを書く", "write article", "登壇報告ブログ", or requests article drafts following the established Japanese style guide. Outputs markdown with strict structure (title format, required sections, tone, terminology).
user-invocable: true
allowed-tools: Read, Write, Edit
---

# Write Article (ぐりもお style)

Write Japanese technical blog articles in the established voice of engineer "ぐりもお (@gr1m0h)".
Articles MUST follow the structure, headings, tone, and templates defined below.

## When to trigger

- User asks for article/blog drafts in Japanese
- User says: 「記事を書いて」「ブログにして」「登壇報告記事を書いて」
- Explicit invocation: `/write-article [topic]`

## Pre-flight checks (ask user if missing)

1. **Article type**: 技術解説 / 課題解決 / 登壇報告 / 組織紹介
2. **Topic / thesis**: what the article is about
3. **For 登壇報告**: event date, event name, slide URL
4. **Length tier**:
   - 実装詳細型: very long (4+ H2 sections, multiple H3 each)
   - コンセプト説明型: medium-long (concept → background → impl → outlook)
   - 登壇予告型: short (highlights only)

## Execution procedure

1. Resolve type/topic/length via questions above
2. Select structure pattern (A/B/C) from the style guide below
3. Propose 2-3 title candidates → user picks one
4. Propose H2/H3 outline → user confirms
5. Draft the article body following the style guide
6. Self-check against the checklist; append results at the end
7. Output as markdown (prefer artifact for easy copy)

## Hard rules

- **All article output is in Japanese.** This skill writes Japanese content; only this SKILL.md is in English for procedure clarity.
- **Use です・ます調 throughout**, never だ・である調
- **First person**: 「私」 (self), 「私たち」 (team)
- **Avoid assertions**: prefer 「〜と思います」「〜と考えています」「〜と感じています」
- **No italics**
- **Headings: H1, H2, H3 only** (no H4+)
- Do NOT invent URLs, slide links, dates, or "採用案内" boilerplate — ask the user
- Represent figures/screenshots as placeholders: `[ここに図: 〜の概念図]`

---

# Style Guide (Japanese article requirements)

The following rules govern the **content of the article you produce**, not this procedure document. Keep these in Japanese to preserve nuance for the output.

## 【記事構造】必須テンプレート

### タイトル

- 長さ: 30〜40文字
- パターン選択:
  1. **技術解説型**: 「[技術領域]で[手法/概念]を[動詞]する時の考え方」
  2. **登壇報告型**: 「[イベント名]で[トピック]についてお話しました」
- 重要概念は引用符で強調: 「"CMC"」「"観察眼"」
- 専門用語（SRE、SLI、SLO、IoT）を自然に含める

### はじめに（H2）必須セクション

**第1〜3段落: 背景・動機（必須）**

- 記事を書くきっかけ・背景を2〜3文で説明
- 記事の位置づけ（Advent Calendarの何日目か、登壇内容の補足か）を明記
- 関連する過去の記事や登壇への言及
- 用語の定義

**登壇報告記事の場合の追加要素（テンプレートを必ず含める）:**

```
[登壇日時]に[イベント名]に登壇しました。
[イベント概要や関連URL]
資料だけでは口頭での説明が漏れてしまい、意図が伝わらない可能性があります。
そのため、登壇内容をブログとしてまとめます。
資料は以下です。
[資料URL]
```

### 本編（複数のH2セクション）

#### パターンA: 技術解説型

- **H2: 概念・背景の説明**
  - 「まず、〜について考えてみます」
  - 既存のアプローチと限界
  - 引用: 「以下は『〜』からの引用です」
- **H2: [新しい概念名]**
  - 定義と既存概念との対比
  - 「〜と定義しています」
  - 図: 「〜を図で整理すると以下のようになります」
- **H2: 具体的な実装**
  - H3: 1. [ステップ1]
  - H3: 2. [ステップ2]
  - H3: 3. [ステップ3]
  - 各ステップで意思決定の根拠を説明
  - 「〜の理由は以下の通りです」として箇条書き
- **H2: 結果・効果**
  - 実装の成果
  - 残された課題

#### パターンB: 課題解決型

- **H2: [現状/背景]**
  - 「これまでは、〜を行っていました」
  - 課題の提示: 「以下のような課題が生じていました」+ ネスト構造の箇条書き
- **H2: [解決方法の検討]**
  - 「これらの課題を解決するために〜を選定しました」
  - 選定理由をH3で分割: 1. コスト / 2. 機能の適合性 / 3. サポート
- **H2: [実装・運用]**
  - 具体的な実装詳細
  - ツールのスクリーンショット: 「以下のように表示されます」
  - 設定例やコードブロック
- **H2: [運用状況/今後の展望]**

#### パターンC: 登壇報告型

- **H2: [背景/なぜこのテーマを選んだか]**
- **H2: [主要トピック1]**
- **H2: [主要トピック2]**
- **H2: [主要トピック3]**
- **H2: 今後の展望**

**各セクションの段落構成**

1. 導入文（1〜2文）: このセクションで何を説明するか
2. 説明段落（2〜4文）: 概念や背景の説明
3. 具体例段落（3〜5文）: 実装や事例の提示
4. まとめ文（1〜2文）: セクションの結論

### さいごに（H2）必須セクション

**第1段落: まとめ（1〜3文）**

```
[記事のメイントピック]について紹介しました。
[残された課題や今後の方針]
形になったタイミングで、〜についてもブログや登壇でお話しできればと思います。
```

## 【見出しルール】

- **H2**: 5〜15文字、体言止め、名詞句で簡潔に
  - 例: 「CMC: Critical Machine Communication」「SLO Docs」「インシデントマネジメントの変遷」
- **H3**:
  - 手順を示す場合は番号付き: 「1. CUJの再設定」「2. SLIの設定」
  - 具体的な項目名: 「オブザーバビリティ」「ランブック」
  - 体言止めを基本
- **H4以降は使用しない**

## 【箇条書きルール】

使用場面と前置き表現:

1. **用語定義**: 「なお、本記事では以下の用語を次のように定義しています」
2. **課題整理**: 「以下のような課題が生じていました」+ ネスト構造
3. **理由説明**: 「考えられる理由は以下のとおりです」
4. **手順説明**: 番号付き箇条書き（1.〜 2.〜 3.〜）

スタイル: ダッシュ（`-`）を基本、順序性が重要な場合は番号

## 【図表・視覚要素】

図の導入表現:

- 「以下の図は〜を簡略化したものです」
- 「〜を図で整理すると以下のようになります」
- 「CUJとCMCが同じレイヤーの概念ということがわかります」

図の種類: システム構成図 / 概念レイヤー図 / 比較図 / フローチャート

スクリーンショット導入: 「以下のように表示されます」

## 【リンク・引用】

- **外部リンク**: `https://example.com` 形式で完全URLを明示。「詳細については以下のドキュメントを参照ください」
- **内部記事参照**: 「このあたりの詳細については、以前書いた以下のブログに記載しています」
- **引用**: 「以下は『[書籍名/ドキュメント名]』からの引用です」

## 【テキスト強調】

- **太字**: セクション内の小見出し、重要概念、専門用語の日本語部分
  - 例: **Multi-tiered SLOs**、CUJ（**クリティカルユーザージャーニー**）
- **鍵カッコ**: 重要なフレーズ「信頼性は会話です」、印象的な引用「「君は見ているが観察していない」」
- **バッククォート**: インラインコード `@oncall`、`p75:trace.<TRACE_NAME>`
- **コードブロック**: 複数行のクエリや設定
- **イタリックは使用しない**

## 【文体・トーン】

### よく使う表現

- **順接**: 「そのため」「これにより」「したがって」「ということで」
- **逆接**: 「しかし」「一方で」「ただし」
- **補足**: 「また」（頻繁に使用）「さらに」「加えて」

### 読者への配慮

- 「ここで疑問に思うのは、〜ということです」
- 「初めてこのブログを読む方は〜よくわからないと思うので」
- 「お気軽に声をかけてください」
- 「気軽に話を聞きたいという方も大歓迎です」

### 個人的要素

- 「個人的には」「個人としては」を適度に使用
- 「余談ですが」でストーリー性のあるエピソードを追加
- 自己の課題認識: 「自分の現時点の一番の悩みが、〜」

## 【技術的内容の扱い】

- **専門用語の初出**: 「CMC: Critical Machine Communication (以下、CMC)」「SLI (Service Level Indicator)」
- **段階的説明**: 基礎概念 → 既存概念との対比 → 具体的な実装 → 結果と効果
- **意思決定の透明性**: 「〜を採用した理由は以下の通りです」→ 理由1, 理由2 → 「それぞれについて詳しく説明します」
- **実装の詳細**: Datadogクエリ、Terraform設定などの具体例をコードブロックで記載
- **コミュニティ貢献意識**: 「〜という考え方は他社でも有用だと考えていますので、コミュニティへの貢献としてこの概念について文章に残しておきたい」

## 【記事タイプ別の追加要素】

- **登壇報告**: 「資料だけでは口頭での説明が漏れてしまい、意図が伝わらない可能性があります」を**必ず含める**。「想定聴講者」セクションを設けることもある
- **コンセプト解説**: 既存アプローチの限界を明確に提示、新概念の定義と既存概念との対比図、コミュニティ活用への期待
- **組織紹介**: チームのミッション・フェーズ・働き方、技術スタック、組織文化、成長機会

## 【長さと段落】

- **記事全体**: 実装詳細型（超長文） / コンセプト説明型（中〜長文） / 登壇予告型（短め）
- **段落**: 1段落3〜5文、1段落1テーマ、短文と長文を混在
- **セクション間の遷移**: 「次に〜について説明します」「では、実際にどのように〜」「それぞれについて詳しく説明します」

## 【避けるべき表現】

- 過度にフランクな表現（「〜だよね」「〜じゃん」）
- 過度に硬い表現（「〜である」調）
- 断定的すぎる表現（「絶対に〜」「必ず〜」）
- 主語の省略しすぎ（適度に「私」「私たち」を明示）
- 説明のない専門用語の羅列

---

# Self-check checklist (append result to article)

After drafting, verify each item and output the result table at the end of the article:

- [ ] 「はじめに」で背景・動機を2〜3段落で説明
- [ ] 見出しは3階層まで（H1, H2, H3のみ）
- [ ] H2見出しは5〜15文字の体言止め
- [ ] 箇条書きに適切な前置き表現
- [ ] 図表に導入表現（「以下の図は〜」）
- [ ] 専門用語の初出時に説明（「XX (以下、XX)」形式）
- [ ] コードやクエリの具体例（該当する場合）
- [ ] 意思決定の根拠を明示
- [ ] 「さいごに」セクションあり
- [ ] です・ます調で統一
- [ ] 断定を避ける表現（「〜と思います」）
- [ ] イタリック未使用
- [ ] 一人称「私」、チーム「私たち」
- [ ] 登壇報告の場合: 「資料だけでは口頭での説明が漏れてしまい〜」テンプレート含有
