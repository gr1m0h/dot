#!/bin/bash

# sipsコマンドのラッパースクリプト
# 画像ファイルをpngまたはjpegに変換してDesktopに出力

set -e

# 使用方法を表示
show_usage() {
    cat << EOF
使用方法: $(basename "$0") <入力ファイル> <出力形式>

引数:
  入力ファイル  変換したい画像ファイルのパス
  出力形式      png または jpeg

例:
  $(basename "$0") ~/Downloads/image.png jpeg
  $(basename "$0") ~/Pictures/photo.jpg png

出力先:
  ~/Desktop/<ファイル名>.<出力形式>

EOF
    exit 1
}

# 引数チェック
if [ $# -ne 2 ]; then
    echo "エラー: 引数が不足しています"
    show_usage
fi

INPUT_FILE="$1"
OUTPUT_FORMAT="$2"

# 入力ファイルの存在確認
if [ ! -f "$INPUT_FILE" ]; then
    echo "エラー: 入力ファイルが見つかりません: $INPUT_FILE"
    exit 1
fi

# 出力形式のバリデーション
if [ "$OUTPUT_FORMAT" != "png" ] && [ "$OUTPUT_FORMAT" != "jpeg" ]; then
    echo "エラー: 出力形式は 'png' または 'jpeg' を指定してください"
    exit 1
fi

# ファイル名と拡張子を取得
BASENAME=$(basename "$INPUT_FILE")
FILENAME="${BASENAME%.*}"

# 出力先を設定（Desktop固定）
OUTPUT_DIR="$HOME/Desktop"
OUTPUT_FILE="${OUTPUT_DIR}/${FILENAME}.${OUTPUT_FORMAT}"

# 既存ファイルの確認
if [ -f "$OUTPUT_FILE" ]; then
    read -p "警告: $OUTPUT_FILE は既に存在します。上書きしますか? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "処理をキャンセルしました"
        exit 0
    fi
fi

# 変換実行
echo "変換中: $INPUT_FILE -> $OUTPUT_FILE"

if [ "$OUTPUT_FORMAT" = "png" ]; then
    sips -s format png "$INPUT_FILE" --out "$OUTPUT_FILE" > /dev/null
elif [ "$OUTPUT_FORMAT" = "jpeg" ]; then
    # JPEGの場合は品質を指定可能（デフォルト: 90）
    JPEG_QUALITY="${JPEG_QUALITY:-90}"
    sips -s format jpeg -s formatOptions "$JPEG_QUALITY" "$INPUT_FILE" --out "$OUTPUT_FILE" > /dev/null
fi

# 結果確認
if [ $? -eq 0 ]; then
    echo "✓ 変換完了: $OUTPUT_FILE"

    # ファイルサイズを表示
    ORIGINAL_SIZE=$(du -h "$INPUT_FILE" | cut -f1)
    OUTPUT_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "  元のサイズ: $ORIGINAL_SIZE"
    echo "  変換後のサイズ: $OUTPUT_SIZE"
else
    echo "✗ 変換に失敗しました"
    exit 1
fi
