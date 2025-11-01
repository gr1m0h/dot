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
        set cmd to ""
        try
            -- nvimパスを複数の場所から検索
            try
                set nvimPath to "/opt/homebrew/bin/nvim"
                do shell script "test -f " & nvimPath
            on error
                try
                    set nvimPath to "/usr/local/bin/nvim"
                    do shell script "test -f " & nvimPath
                on error
                    try
                        set nvimPath to "/Users/d4rj3311n6/.local/share/mise/installs/neovim/0.11.4/bin/nvim"
                        do shell script "test -f " & nvimPath
                    on error
                        set nvimPath to "nvim" -- fallback
                    end try
                end try
            end try
            
            set cmd to "/opt/homebrew/bin/wezterm cli spawn --cwd " & quoted form of fileDir & " -- " & nvimPath & " " & quotedPath
            set cmdResult to do shell script cmd
        on error errorMessage
            try
                set cmd to "/usr/local/bin/wezterm cli spawn --cwd " & quoted form of fileDir & " -- " & nvimPath & " " & quotedPath
                set cmdResult to do shell script cmd
            on error errorMessage2
                -- 環境変数を確認
                set pathEnv to do shell script "echo $PATH"
                set homeEnv to do shell script "echo $HOME"
                display dialog "Error details:" & return & "PATH: " & pathEnv & return & "HOME: " & homeEnv & return & "nvimPath: " & nvimPath & return & "cmd: " & cmd & return & "Error1: " & errorMessage & return & "Error2: " & errorMessage2
            end try
        end try
    end repeat
end open

-- ドラッグ&ドロップ以外でアプリが起動された場合
on run
    tell application "WezTerm"
        activate
    end tell
    
    set nvimPath to ""
    try
        -- nvimパスを複数の場所から検索
        try
            set nvimPath to "/opt/homebrew/bin/nvim"
            do shell script "test -f " & nvimPath
        on error
            try
                set nvimPath to "/usr/local/bin/nvim"
                do shell script "test -f " & nvimPath
            on error
                try
                    set nvimPath to "/Users/d4rj3311n6/.local/share/mise/installs/neovim/0.11.4/bin/nvim"
                    do shell script "test -f " & nvimPath
                on error
                    set nvimPath to "nvim" -- fallback
                end try
            end try
        end try
        
        do shell script "/opt/homebrew/bin/wezterm cli spawn -- " & nvimPath
    on error errorMessage
        try
            do shell script "/usr/local/bin/wezterm cli spawn -- " & nvimPath
        on error errorMessage2
            set pathEnv to do shell script "echo $PATH"
            set homeEnv to do shell script "echo $HOME"
            display dialog "Error details:" & return & "PATH: " & pathEnv & return & "HOME: " & homeEnv & return & "nvimPath: " & nvimPath & return & "Error1: " & errorMessage & return & "Error2: " & errorMessage2
        end try
    end try
end run