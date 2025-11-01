#!/bin/bash

echo "🚀 Building WezTerm-Nvim.app..."

# 既存アプリを削除
if [ -d ~/Applications/WezTerm-Nvim.app ]; then
    echo "🗑️ Removing old version..."
    rm -rf ~/Applications/WezTerm-Nvim.app
fi

# AppleScriptアプリケーションをビルド
echo "📦 Building application..."
osacompile -o ~/Applications/WezTerm-Nvim.app WezTerm-Nvim.applescript

PLIST_PATH=~/Applications/WezTerm-Nvim.app/Contents/Info.plist

# 既存のCFBundleDocumentTypesを削除
/usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$PLIST_PATH" 2>/dev/null || true

# Info.plistを編集して、対応する拡張子を追加
echo "⚙️ Configuring file associations..."
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes array" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0 dict" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions array" "$PLIST_PATH"

# ファイル拡張子を追加
EXTENSIONS=("txt" "md" "markdown" "js" "jsx" "ts" "tsx" "py" "lua" "rb" "go" "rs" "c" "cpp" "h" "hpp" "java" "sh" "bash" "yml" "yaml" "json" "toml" "ini" "cfg" "conf" "html" "css" "php" "sql")

for i in "${!EXTENSIONS[@]}"; do
    ext="${EXTENSIONS[$i]}"
    /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:$i string '$ext'" "$PLIST_PATH"
done

# ドキュメントタイプの設定
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string 'Text Files'" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string 'Editor'" "$PLIST_PATH"

# Bundle Identifierを追加
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string 'com.local.wezterm-nvim'" "$PLIST_PATH" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier 'com.local.wezterm-nvim'" "$PLIST_PATH"

# Bundle Nameを追加
/usr/libexec/PlistBuddy -c "Add :CFBundleName string 'WezTerm-Nvim'" "$PLIST_PATH" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :CFBundleName 'WezTerm-Nvim'" "$PLIST_PATH"

# LaunchServicesを更新
echo "🔄 Updating LaunchServices database..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f ~/Applications/WezTerm-Nvim.app

echo "✅ WezTerm-Nvim.app setup complete!"
echo ""
echo "使い方："
echo "1. Finderで任意のファイルを右クリック"
echo "2. 「情報を見る」を選択"
echo "3. 「このアプリケーションで開く」でWezTerm-Nvimを選択"
echo "4. 「すべてを変更」をクリックして、同じ拡張子のファイルすべてに適用"