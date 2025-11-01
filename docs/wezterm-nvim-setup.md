# WezTerm-Nvim ファイル関連付け設定

このセットアップにより、特定の拡張子のファイルをFinderからダブルクリックするだけでWezTermでNvimが開くようになります。

## セットアップ方法

### chezmoiでの自動セットアップ

```bash
# chezmoiで設定を適用
chezmoi apply

# 初回実行時、以下の質問に答えてください：
# - Path to wezterm binary: /opt/homebrew/bin/wezterm (M1/M2 Mac)
# - Path to nvim binary: /opt/homebrew/bin/nvim (Homebrew経由インストール)
```

セットアップスクリプトは自動的に以下を実行します：
- AppleScriptアプリケーション「WezTerm-Nvim.app」を作成
- `~/Applications/`にインストール
- ファイル拡張子の関連付けを設定

### ファイルの関連付け設定

1. Finderで任意のテキストファイル（例：`.txt`、`.md`）を右クリック
2. 「情報を見る」を選択
3. 「このアプリケーションで開く」セクションで「WezTerm-Nvim」を選択
4. 「すべてを変更...」をクリックして、同じ拡張子のファイルすべてに適用

### 対応している拡張子

デフォルトで以下の拡張子に対応しています：

- **テキスト**: txt, md, markdown, rst
- **プログラミング言語**: lua, js, ts, py, rb, go, rs, c, cpp, java, sh
- **設定ファイル**: yml, yaml, json, toml, ini, env, gitignore
- **Web**: html, css, scss, php
- その他多数


## カスタマイズ

### 拡張子の追加

`.chezmoi.toml`の`extra_extensions`配列に拡張子を追加できます：

```toml
[data]
    extra_extensions = ["log", "conf", "cfg"]
```

### パスの変更

Intel Macやカスタムインストール先の場合は、`.chezmoi.toml`を編集：

```toml
[data]
    wezterm_path = "/usr/local/bin/wezterm"  # Intel Mac
    nvim_path = "/usr/local/bin/nvim"
```

## トラブルシューティング

### アプリが開かない場合

1. セキュリティ設定を確認：
   - システム環境設定 > セキュリティとプライバシー > 一般
   - 「WezTerm-Nvim」を許可

2. LaunchServicesデータベースをリセット：
   ```bash
   /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
   ```

### パスが見つからない場合

```bash
# weztermとnvimのパスを確認
which wezterm
which nvim
```

確認したパスを`.chezmoi.toml`に設定してください。

## 再インストール

設定を変更した場合や問題が発生した場合：

```bash
# アプリを再ビルド
chezmoi apply --force-refresh-externals
```