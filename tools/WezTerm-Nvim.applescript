on open theFiles
    repeat with aFile in theFiles
        set filePath to POSIX path of aFile
        set quotedPath to quoted form of filePath

        -- Get the directory of the file
        set fileDir to do shell script "dirname " & quotedPath

        -- WezTermでNvimを起動
        tell application "WezTerm"
            activate
        end tell

        -- WezTermでNvimを起動
        try
            launchWezterm(filePath, fileDir)
        on error errorMessage
            -- エラー時の詳細表示
            display dialog "Error opening file in WezTerm:" & return & return & ¬
                "File: " & filePath & return & ¬
                "Error: " & errorMessage buttons {"OK"} default button 1 with icon stop
        end try
    end repeat
end open

-- ドラッグ&ドロップ以外でアプリが起動された場合
on run
    tell application "WezTerm"
        activate
    end tell

    try
        launchWezterm("", "")
    on error errorMessage
        display dialog "Error opening WezTerm:" & return & return & ¬
            "Error: " & errorMessage buttons {"OK"} default button 1 with icon stop
    end try
end run

-- WezTermを起動する関数
on launchWezterm(filePath, fileDir)
    set homeDir to do shell script "echo $HOME"

    -- nvimのフルパスを検索
    set nvimPath to ""
    try
        -- .zshrcを読み込んでからnvimを検索
        set nvimPath to do shell script "source " & quoted form of (homeDir & "/.zshrc") & " 2>/dev/null && which nvim"
    on error
        -- フォールバック：一般的な場所を検索
        try
            set nvimPath to do shell script "test -f /opt/homebrew/bin/nvim && echo /opt/homebrew/bin/nvim || echo ''"
            if nvimPath is "" then
                set nvimPath to do shell script "test -f /usr/local/bin/nvim && echo /usr/local/bin/nvim || echo ''"
            end if
            if nvimPath is "" then
                -- miseのnvimを検索
                set nvimPath to do shell script "find " & quoted form of (homeDir & "/.local/share/mise/installs/neovim") & " -name nvim -type f 2>/dev/null | head -1"
            end if
        end try
    end try

    if nvimPath is "" then
        error "Neovim not found. Please install neovim."
    end if

    -- weztermのフルパスを検索
    set weztermPath to ""
    try
        set weztermPath to do shell script "which wezterm"
    on error
        try
            set weztermPath to do shell script "test -f /opt/homebrew/bin/wezterm && echo /opt/homebrew/bin/wezterm || echo ''"
            if weztermPath is "" then
                set weztermPath to do shell script "test -f /usr/local/bin/wezterm && echo /usr/local/bin/wezterm || echo ''"
            end if
        end try
    end try

    if weztermPath is "" then
        error "WezTerm not found. Please install wezterm."
    end if

    -- コマンドを構築（シェルを明示的に起動して環境変数を読み込む）
    if filePath is not "" and fileDir is not "" then
        -- ファイルを開く場合
        -- エスケープを簡単にするため、ダブルクォートを使用
        set innerCmd to "exec " & nvimPath & " " & quoted form of filePath
        set cmd to weztermPath & " start --cwd " & quoted form of fileDir & " -- /bin/zsh -l -c " & quoted form of innerCmd
    else
        -- ファイルなしで起動する場合
        set innerCmd to "exec " & nvimPath
        set cmd to weztermPath & " start -- /bin/zsh -l -c " & quoted form of innerCmd
    end if

    -- バックグラウンドで実行
    do shell script cmd & " > /dev/null 2>&1 &"
end launchWezterm
