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
        
        -- WezTerm CLIを使用してNvimを起動
        set nvimPath to ""
        set weztermPath to ""
        
        -- nvimパスを動的に検索
        try
            -- まずPATHから検索
            set nvimPath to do shell script "which nvim"
        on error
            try
                -- Homebrewの標準的な場所を検索
                set nvimPath to "/opt/homebrew/bin/nvim"
                do shell script "test -f " & nvimPath
            on error
                try
                    set nvimPath to "/usr/local/bin/nvim"
                    do shell script "test -f " & nvimPath
                on error
                    try
                        -- miseでインストールされたnvimを動的検索
                        set homeDir to do shell script "echo $HOME"
                        set nvimPath to do shell script "find " & quoted form of (homeDir & "/.local/share/mise/installs/neovim") & " -name nvim -type f 2>/dev/null | head -1"
                        if nvimPath is "" then error "nvim not found in mise"
                    on error
                        set nvimPath to "nvim" -- fallback to PATH
                    end try
                end try
            end try
        end try
        
        -- weztermパスを動的に検索
        try
            set weztermPath to do shell script "which wezterm"
        on error
            try
                set weztermPath to "/opt/homebrew/bin/wezterm"
                do shell script "test -f " & weztermPath
            on error
                try
                    set weztermPath to "/usr/local/bin/wezterm"
                    do shell script "test -f " & weztermPath
                on error
                    set weztermPath to "wezterm" -- fallback
                end try
            end try
        end try
        
        try
            set cmd to weztermPath & " cli spawn --cwd " & quoted form of fileDir & " -- " & nvimPath & " " & quotedPath
            set cmdResult to do shell script cmd
        on error errorMessage
            -- 環境変数を確認
            set pathEnv to do shell script "echo $PATH"
            set homeEnv to do shell script "echo $HOME"
            display dialog "Error details:" & return & "PATH: " & pathEnv & return & "HOME: " & homeEnv & return & "nvimPath: " & nvimPath & return & "weztermPath: " & weztermPath & return & "cmd: " & cmd & return & "Error: " & errorMessage
        end try
    end repeat
end open

-- ドラッグ&ドロップ以外でアプリが起動された場合
on run
    tell application "WezTerm"
        activate
    end tell
    
    set nvimPath to ""
    set weztermPath to ""
    
    -- nvimパスを動的に検索
    try
        -- まずPATHから検索
        set nvimPath to do shell script "which nvim"
    on error
        try
            -- Homebrewの標準的な場所を検索
            set nvimPath to "/opt/homebrew/bin/nvim"
            do shell script "test -f " & nvimPath
        on error
            try
                set nvimPath to "/usr/local/bin/nvim"
                do shell script "test -f " & nvimPath
            on error
                try
                    -- miseでインストールされたnvimを動的検索
                    set homeDir to do shell script "echo $HOME"
                    set nvimPath to do shell script "find " & quoted form of (homeDir & "/.local/share/mise/installs/neovim") & " -name nvim -type f 2>/dev/null | head -1"
                    if nvimPath is "" then error "nvim not found in mise"
                on error
                    set nvimPath to "nvim" -- fallback to PATH
                end try
            end try
        end try
    end try
    
    -- weztermパスを動的に検索
    try
        set weztermPath to do shell script "which wezterm"
    on error
        try
            set weztermPath to "/opt/homebrew/bin/wezterm"
            do shell script "test -f " & weztermPath
        on error
            try
                set weztermPath to "/usr/local/bin/wezterm"
                do shell script "test -f " & weztermPath
            on error
                set weztermPath to "wezterm" -- fallback
            end try
        end try
    end try
    
    try
        do shell script weztermPath & " cli spawn -- " & nvimPath
    on error errorMessage
        set pathEnv to do shell script "echo $PATH"
        set homeEnv to do shell script "echo $HOME"
        display dialog "Error details:" & return & "PATH: " & pathEnv & return & "HOME: " & homeEnv & return & "nvimPath: " & nvimPath & return & "weztermPath: " & weztermPath & return & "Error: " & errorMessage
    end try
end run