#!/bin/bash

# AppleScriptアプリケーションをビルド
osacompile -o ~/Applications/WezTerm-Nvim.app WezTerm-Nvim.applescript

# Info.plistを編集して、対応する拡張子を追加
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes array" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0 dict" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions array" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:0 string 'txt'" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:1 string 'md'" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:2 string 'js'" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:3 string 'ts'" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:4 string 'py'" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:5 string 'lua'" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string 'Text Files'" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string 'Editor'" ~/Applications/WezTerm-Nvim.app/Contents/Info.plist

echo "アプリケーションが作成されました: ~/Applications/WezTerm-Nvim.app"
echo ""
echo "使い方："
echo "1. Finderで任意のファイルを右クリック"
echo "2. 「情報を見る」を選択"
echo "3. 「このアプリケーションで開く」でWezTerm-Nvimを選択"
echo "4. 「すべてを変更」をクリックして、同じ拡張子のファイルすべてに適用"