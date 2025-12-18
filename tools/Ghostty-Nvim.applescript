on open theFiles
    repeat with aFile in theFiles
        set filePath to POSIX path of aFile
        set quotedPath to quoted form of filePath

        -- Get the directory of the file
        set fileDir to do shell script "dirname " & quotedPath

        -- GhosttyでNvimを起動
        tell application "Ghostty"
            activate
        end tell

        -- GhosttyでNvimを起動
        try
            launchGhostty(filePath, fileDir)
        on error errorMessage
            -- エラー時の詳細表示
            display dialog "Error opening file in Ghostty:" & return & return & ¬
                "File: " & filePath & return & ¬
                "Error: " & errorMessage buttons {"OK"} default button 1 with icon stop
        end try
    end repeat
end open

-- ドラッグ&ドロップ以外でアプリが起動された場合
on run
    tell application "Ghostty"
        activate
    end tell

    try
        launchGhostty("", "")
    on error errorMessage
        display dialog "Error opening Ghostty:" & return & return & ¬
            "Error: " & errorMessage buttons {"OK"} default button 1 with icon stop
    end try
end run

-- Ghosttyを起動する関数
on launchGhostty(filePath, fileDir)
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

    -- コマンドを構築
    if filePath is not "" and fileDir is not "" then
        -- ファイルを開く場合
        set cmd to "open -na Ghostty.app --args --working-directory=" & quoted form of fileDir & " -e " & quoted form of (nvimPath & " " & filePath)
    else
        -- ファイルなしで起動する場合
        set cmd to "open -na Ghostty.app --args -e " & quoted form of nvimPath
    end if

    -- バックグラウンドで実行
    do shell script cmd & " > /dev/null 2>&1 &"
end launchGhostty
