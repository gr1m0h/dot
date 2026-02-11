#!/bin/bash

# Claude Code Insights HTMLを日本語に変換するスクリプト
#
# 使用方法:
#   translate-insights-ja.sh              # sed で構造要素を翻訳（高速・無コスト）
#   translate-insights-ja.sh --full       # claude -p で全文翻訳（完全・API使用）
#   translate-insights-ja.sh --file PATH  # 対象ファイルを指定
#   translate-insights-ja.sh --in-place   # 元ファイルを直接上書き
#
# 注意:
#   --full モードは claude CLI が必要です
#   デフォルトモードではナラティブ（分析テキスト）は英語のまま残ります
#   デフォルトでは report_ja.html として出力し、元ファイルは変更しない

set -euo pipefail

REPORT="${HOME}/.claude/usage-data/report.html"
MODE="quick"

show_usage() {
    cat << EOF
使用方法: $(basename "$0") [オプション]

オプション:
  --full        claude -p で全テキストを翻訳（API使用）
  --file PATH   対象HTMLファイルを指定（デフォルト: ~/.claude/usage-data/report.html）
  --in-place    元ファイルを直接上書き（デフォルト: _ja.html として別ファイル出力）
  --dry-run     変更内容をプレビュー（ファイル変更なし）
  --help        このヘルプを表示

例:
  $(basename "$0")              # report_ja.html として出力（高速）
  $(basename "$0") --full       # report_ja.html として全文翻訳
  $(basename "$0") --in-place   # report.html を直接上書き
EOF
    exit 0
}

# 引数解析
DRY_RUN=false
IN_PLACE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --full)     MODE="full"; shift ;;
        --file)     REPORT="$2"; shift 2 ;;
        --in-place) IN_PLACE=true; shift ;;
        --dry-run)  DRY_RUN=true; shift ;;
        --help)     show_usage ;;
        *)          echo "エラー: 不明なオプション: $1"; show_usage ;;
    esac
done

# ファイル存在確認
if [[ ! -f "$REPORT" ]]; then
    echo "エラー: ファイルが見つかりません: $REPORT"
    echo "先に 'claude insights' を実行してください"
    exit 1
fi

# 出力先の決定
if [[ "$IN_PLACE" == true ]]; then
    OUTPUT="$REPORT"
else
    OUTPUT="${REPORT%.html}_ja.html"
fi

# === Full モード: claude -p による完全翻訳 ===
if [[ "$MODE" == "full" ]]; then
    if ! command -v claude &> /dev/null; then
        echo "エラー: claude CLI が見つかりません"
        echo "--full モードには claude CLI が必要です"
        exit 1
    fi

    echo "全文翻訳中（claude -p）..."

    PROMPT='以下のHTMLファイルの全テキストコンテンツを日本語に翻訳してください。
ルール:
1. HTML構造、CSSスタイル、JavaScriptの機能は一切変更しない
2. 表示されるテキストのみを翻訳する
3. 技術ツール名（Bash, Read, Edit, Glob, Grep, WebSearch, Write, WebFetch等）は英語のまま
4. プログラミング言語名（JavaScript, Ruby, Go, Python等）は英語のまま
5. <html lang="en"> を <html lang="ja"> に変更
6. HTMLコードのみを出力し、説明やコードフェンスは付けない
7. 日付区切りの – は 〜 に変更
8. コロンは全角：を使用
9. 以下のコピー可能な要素は英語原文のまま一切翻訳しない:
   - <code class="cmd-code"> 内のテキスト（CLAUDE.md追記用の指示文）
   - <code class="example-code"> 内のテキスト（設定・コードスニペット）
   - <code class="copyable-prompt"> 内のテキスト（Claude Codeに貼り付けるプロンプト）
   - input要素の data-text 属性値（チェックボックスのコピー用テキスト）'

    if [[ "$DRY_RUN" == true ]]; then
        echo "[dry-run] claude -p で翻訳を実行します"
        echo "[dry-run] 入力: $REPORT → $OUTPUT"
        exit 0
    fi

    TMPFILE=$(mktemp /tmp/claude/insights-ja-XXXXXX.html)
    if claude -p "$PROMPT" < "$REPORT" > "$TMPFILE" 2>/dev/null; then
        # 出力がHTMLかどうか簡易チェック
        if head -5 "$TMPFILE" | grep -q '<!DOCTYPE\|<html'; then
            mv "$TMPFILE" "$OUTPUT"
            echo "翻訳完了: $OUTPUT"
        else
            echo "エラー: claude の出力がHTMLではありません"
            echo "出力を確認: $TMPFILE"
            exit 1
        fi
    else
        echo "エラー: claude -p の実行に失敗しました"
        rm -f "$TMPFILE"
        exit 1
    fi
    exit 0
fi

# === Quick モード: sed による構造要素翻訳 ===
# 注: sed パターンは >TEXT< 形式で特定の要素のみ対象にするため、
#     コピー可能な要素（cmd-code, example-code, copyable-prompt, data-text）には影響しない
echo "構造要素を翻訳中（sed）..."

if [[ "$DRY_RUN" == true ]]; then
    TARGET=$(mktemp /tmp/claude/insights-preview-XXXXXX.html)
    cp "$REPORT" "$TARGET"
else
    cp "$REPORT" "$OUTPUT"
    TARGET="$OUTPUT"
fi

# macOS sed では -i '' が必要、Linux では -i のみ
if [[ "$(uname)" == "Darwin" ]]; then
    SED_I=(sed -i '')
else
    SED_I=(sed -i)
fi

# --- HTML lang属性 ---
"${SED_I[@]}" 's/<html lang="en">/<html lang="ja">/' "$TARGET"
"${SED_I[@]}" 's/<html>/<html lang="ja">/' "$TARGET"

# --- タイトル & H1 ---
"${SED_I[@]}" 's/>Claude Code Insights</>Claude Code インサイト</' "$TARGET"
"${SED_I[@]}" 's/<title>Claude Code Insights<\/title>/<title>Claude Code インサイト<\/title>/' "$TARGET"

# --- 概要セクション (At a Glance) ---
"${SED_I[@]}" "s/>At a Glance</>概要</" "$TARGET"
"${SED_I[@]}" "s/What's working:/うまくいっていること：/g" "$TARGET"
"${SED_I[@]}" "s/What's getting in the way:/妨げになっていること：/g" "$TARGET"
"${SED_I[@]}" "s/Quick improvement to try:/すぐに試せる改善：/g" "$TARGET"
"${SED_I[@]}" "s/Ambitious workflow:/野心的なワークフロー：/g" "$TARGET"

# --- セクションヘッダー (H2) ---
"${SED_I[@]}" 's/>What You Work On</>作業内容</' "$TARGET"
"${SED_I[@]}" 's/>How You Use Claude Code</>Claude Codeの使い方</' "$TARGET"
"${SED_I[@]}" 's/>Impressive Things You Did</>印象的な成果</' "$TARGET"
"${SED_I[@]}" 's/>Where Things Go Wrong</>問題が発生する箇所</' "$TARGET"
"${SED_I[@]}" 's/>Existing CC Features to Try</>試すべきCC既存機能</' "$TARGET"
"${SED_I[@]}" 's/>New Ways to Use Claude Code</>Claude Codeの新しい使い方</' "$TARGET"
"${SED_I[@]}" 's/>On the Horizon</>今後の展望</' "$TARGET"

# --- ナビゲーション (nav-toc 短縮形) ---
"${SED_I[@]}" 's/>How You Use CC</>CCの使い方</' "$TARGET"
"${SED_I[@]}" 's/>Impressive Things</>印象的な成果</' "$TARGET"
"${SED_I[@]}" 's/>Where Things Stall</>問題が発生する箇所</' "$TARGET"
"${SED_I[@]}" 's/>CC Features to Try</>試すべき機能</' "$TARGET"
"${SED_I[@]}" 's/>New Patterns</>新しい使い方</' "$TARGET"
"${SED_I[@]}" 's/>Team Feedback</>チームフィードバック</' "$TARGET"

# --- 統計ラベル (stat-label) ---
"${SED_I[@]}" 's/class="stat-label">Messages</class="stat-label">メッセージ</' "$TARGET"
"${SED_I[@]}" 's/class="stat-label">Lines</class="stat-label">行数</' "$TARGET"
"${SED_I[@]}" 's/class="stat-label">Files</class="stat-label">ファイル</' "$TARGET"
"${SED_I[@]}" 's/class="stat-label">Days</class="stat-label">日数</' "$TARGET"
"${SED_I[@]}" 's/class="stat-label">msgs\/day</class="stat-label">メッセージ\/日</' "$TARGET"

# --- サブタイトル (sessions/messages) ---
"${SED_I[@]}" 's/ sessions (of /セッション（全/g' "$TARGET"
"${SED_I[@]}" 's/ total) with /セッション中）で/g' "$TARGET"
"${SED_I[@]}" 's/ messages | /メッセージ | /g' "$TARGET"

# --- エリアカウント (~N sessions → 約Nセッション) ---
"${SED_I[@]}" 's/~\([0-9]*\) sessions/約\1セッション/g' "$TARGET"

# --- チャートタイトル ---
"${SED_I[@]}" 's/>What you wanted to do</>やりたかったこと</' "$TARGET"
"${SED_I[@]}" 's/>Top tools</>よく使うツール</' "$TARGET"
"${SED_I[@]}" 's/>Languages</>言語</' "$TARGET"
"${SED_I[@]}" 's/>Session types</>セッションタイプ</' "$TARGET"
"${SED_I[@]}" 's/>User response time distribution</>ユーザー応答時間分布</' "$TARGET"
"${SED_I[@]}" 's/>User messages by time of day</>時間帯別ユーザーメッセージ</' "$TARGET"
"${SED_I[@]}" 's/>Tool errors encountered</>発生したツールエラー</' "$TARGET"
"${SED_I[@]}" 's/>What helped most</>最も役立ったこと</' "$TARGET"
"${SED_I[@]}" 's/>Outcomes</>成果</' "$TARGET"
"${SED_I[@]}" 's/>Top friction types</>主な摩擦タイプ</' "$TARGET"
"${SED_I[@]}" 's/>Estimated satisfaction</>推定満足度</' "$TARGET"
"${SED_I[@]}" 's/>Activity by time of day</>時間帯別アクティビティ</' "$TARGET"

# --- マルチクローディング ---
"${SED_I[@]}" 's/>Multi-Clauding</>マルチクローディング</' "$TARGET"
"${SED_I[@]}" 's/(parallel sessions)/(並列セッション)/g' "$TARGET"
"${SED_I[@]}" 's/>OVERLAP EVENTS</>重複イベント</I' "$TARGET"
"${SED_I[@]}" 's/>INVOLVED SESSIONS</>関連セッション</I' "$TARGET"
"${SED_I[@]}" 's/>OF MESSAGES</>メッセージ割合</I' "$TARGET"
"${SED_I[@]}" 's/overlap events/重複イベント/g' "$TARGET"
"${SED_I[@]}" 's/involved sessions/関連セッション/g' "$TARGET"
"${SED_I[@]}" 's/of messages/メッセージ割合/g' "$TARGET"

# --- インテントラベル ---
"${SED_I[@]}" 's/>Information retrieval</>情報検索</' "$TARGET"
"${SED_I[@]}" 's/>Configuration optimization</>設定最適化</' "$TARGET"
"${SED_I[@]}" 's/>Debugging</>デバッグ</' "$TARGET"
"${SED_I[@]}" 's/>Content creation</>コンテンツ作成</' "$TARGET"
"${SED_I[@]}" 's/>Technical explanation</>技術解説</' "$TARGET"
"${SED_I[@]}" 's/>Code review</>コードレビュー</' "$TARGET"
"${SED_I[@]}" 's/>Feature implementation</>機能実装</' "$TARGET"
"${SED_I[@]}" 's/>Refactoring</>リファクタリング</' "$TARGET"
"${SED_I[@]}" 's/>Bug fix</>バグ修正</' "$TARGET"
"${SED_I[@]}" 's/>Research</>リサーチ</' "$TARGET"

# --- セッションタイプラベル ---
"${SED_I[@]}" 's/>Single-task</>単一タスク</' "$TARGET"
"${SED_I[@]}" 's/>Iterative refinement</>反復改善</' "$TARGET"
"${SED_I[@]}" 's/>Quick question</>簡単な質問</' "$TARGET"
"${SED_I[@]}" 's/>Multi-task</>複数タスク</' "$TARGET"
"${SED_I[@]}" 's/>Exploration</>探索</' "$TARGET"

# --- 応答時間ラベル ---
"${SED_I[@]}" 's/>2-10s</>2-10秒</' "$TARGET"
"${SED_I[@]}" 's/>10-30s</>10-30秒</' "$TARGET"
"${SED_I[@]}" 's/>30s-1m</>30秒-1分</' "$TARGET"
"${SED_I[@]}" 's/>1-2m</>1-2分</' "$TARGET"
"${SED_I[@]}" 's/>2-5m</>2-5分</' "$TARGET"
"${SED_I[@]}" 's/>5-15m</>5-15分</' "$TARGET"
"${SED_I[@]}" 's/>&gt;15m</>\&gt;15分</' "$TARGET"
"${SED_I[@]}" 's/Median: /中央値: /g' "$TARGET"
"${SED_I[@]}" 's/Mean: /平均: /g' "$TARGET"

# --- ツールエラーラベル ---
"${SED_I[@]}" 's/>Command failed</>コマンド失敗</' "$TARGET"
"${SED_I[@]}" 's/>User rejected</>ユーザー拒否</' "$TARGET"
"${SED_I[@]}" 's/>File not found</>ファイル未検出</' "$TARGET"
"${SED_I[@]}" 's/>File too large</>ファイル過大</' "$TARGET"
"${SED_I[@]}" 's/>Edit failed</>編集失敗</' "$TARGET"
"${SED_I[@]}" 's/>Permission denied</>権限拒否</' "$TARGET"
"${SED_I[@]}" 's/>Timeout</>タイムアウト</' "$TARGET"

# --- 成果ラベル (What helped most) ---
"${SED_I[@]}" 's/>Accurate explanation</>的確な解説</' "$TARGET"
"${SED_I[@]}" 's/>Multi-file changes</>複数ファイル変更</' "$TARGET"
"${SED_I[@]}" 's/>Correct debugging</>的確なデバッグ</' "$TARGET"
"${SED_I[@]}" 's/>Precise code edits</>正確なコード編集</' "$TARGET"
"${SED_I[@]}" 's/>Proactive help</>先回りサポート</' "$TARGET"
"${SED_I[@]}" "s/>Fast \& correct search</>高速・正確な検索</" "$TARGET"
"${SED_I[@]}" 's/>Fast &amp; correct search</>高速・正確な検索</' "$TARGET"

# --- アウトカムラベル ---
"${SED_I[@]}" 's/>Not achieved</>未達成</' "$TARGET"
"${SED_I[@]}" 's/>Partially achieved</>部分達成</' "$TARGET"
"${SED_I[@]}" 's/>Mostly achieved</>ほぼ達成</' "$TARGET"
"${SED_I[@]}" 's/>Fully achieved</>完全達成</' "$TARGET"

# --- 摩擦タイプラベル ---
"${SED_I[@]}" 's/>Wrong approach</>間違ったアプローチ</' "$TARGET"
"${SED_I[@]}" 's/>Refused to act</>操作拒否</' "$TARGET"
"${SED_I[@]}" 's/>Excessive changes</>過度な変更</' "$TARGET"
"${SED_I[@]}" 's/>Misunderstood request</>リクエスト誤解</' "$TARGET"
"${SED_I[@]}" 's/>Buggy code</>バグのあるコード</' "$TARGET"
"${SED_I[@]}" 's/>Over-planned</>過度な計画</' "$TARGET"

# --- 満足度ラベル ---
"${SED_I[@]}" 's/>Dissatisfied</>不満</' "$TARGET"
"${SED_I[@]}" 's/>Somewhat dissatisfied</>やや不満</' "$TARGET"
"${SED_I[@]}" 's/>Probably satisfied</>おそらく満足</' "$TARGET"
"${SED_I[@]}" 's/>Satisfied</>満足</' "$TARGET"
"${SED_I[@]}" 's/(model-estimated)/(モデル推定)/g' "$TARGET"

# --- ボタンテキスト ---
"${SED_I[@]}" "s/>Copy All Checked</>チェック済みを全てコピー</" "$TARGET"
"${SED_I[@]}" "s/Copy All Checked/チェック済みを全てコピー/g" "$TARGET"

# --- プロンプト・機能ラベル ---
"${SED_I[@]}" 's/>Paste into Claude Code:</>Claude Codeに貼り付け：</' "$TARGET"
"${SED_I[@]}" 's/Paste into Claude Code:/Claude Codeに貼り付け：/g' "$TARGET"
"${SED_I[@]}" 's/>Recommended CLAUDE.md additions</>推奨CLAUDE.md追記事項</' "$TARGET"
"${SED_I[@]}" "s/Why this is for you:/あなたへの推奨理由：/g" "$TARGET"
"${SED_I[@]}" 's/>Key insight:</>重要なポイント：</' "$TARGET"
"${SED_I[@]}" 's/>Key pattern:</>主要パターン：</' "$TARGET"
"${SED_I[@]}" "s/<strong>Getting started:</<strong>始め方：/g" "$TARGET"

# --- JavaScript内の文字列 ---
# Copy/Copiedボタン
"${SED_I[@]}" "s/btn.textContent = 'Copied!'/btn.textContent = 'コピー済み!'/g" "$TARGET"
"${SED_I[@]}" "s/btn.textContent = 'Copy'/btn.textContent = 'コピー'/g" "$TARGET"
"${SED_I[@]}" "s/textContent = 'Copied!'/textContent = 'コピー済み!'/g" "$TARGET"
"${SED_I[@]}" "s/textContent = 'Copy'/textContent = 'コピー'/g" "$TARGET"
# CopyAllChecked
"${SED_I[@]}" "s/texts.length + ' items copied!'/texts.length + '件コピー済み!'/g" "$TARGET"
"${SED_I[@]}" "s/'Copy All Checked'/'チェック済みを全てコピー'/g" "$TARGET"

# 時間帯ラベル (JS内)
"${SED_I[@]}" 's/"Morning (6-12)"/"朝 (6-12)"/g' "$TARGET"
"${SED_I[@]}" 's/"Afternoon (12-18)"/"午後 (12-18)"/g' "$TARGET"
"${SED_I[@]}" 's/"Evening (18-24)"/"夕方 (18-24)"/g' "$TARGET"
"${SED_I[@]}" 's/"Night (0-6)"/"深夜 (0-6)"/g' "$TARGET"

# --- タイムゾーンセレクター ---
"${SED_I[@]}" 's/>Tokyo (UTC+9)</>東京 (UTC+9)</' "$TARGET"
"${SED_I[@]}" 's/>Custom offset\.\.\.</>カスタムオフセット...</' "$TARGET"
"${SED_I[@]}" 's/placeholder="UTC offset"/placeholder="UTCオフセット"/' "$TARGET"

# --- HTML内のCopyボタン (最後に実行: 他の置換と競合しないよう) ---
"${SED_I[@]}" 's/>Copy<\/button>/>コピー<\/button>/g' "$TARGET"

# --- 日付区切り ---
"${SED_I[@]}" 's/ – / 〜 /g' "$TARGET"

if [[ "$DRY_RUN" == true ]]; then
    echo "=== プレビュー（差分） ==="
    diff "$REPORT" "$TARGET" || true
    rm -f "$TARGET"
else
    echo "翻訳完了: $OUTPUT"
    echo "注意: 分析テキスト（ナラティブ）は英語のままです"
    echo "全文翻訳するには --full オプションを使用してください"
fi
