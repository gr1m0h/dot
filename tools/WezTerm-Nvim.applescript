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
        try
            do shell script "/opt/homebrew/bin/wezterm cli spawn --cwd " & quoted form of fileDir & " -- /Users/d4rj3311n6/.local/share/mise/installs/neovim/0.11.4/bin/nvim " & quotedPath
        on error
            try
                do shell script "/usr/local/bin/wezterm cli spawn --cwd " & quoted form of fileDir & " -- /Users/d4rj3311n6/.local/share/mise/installs/neovim/0.11.4/bin/nvim " & quotedPath
            on error
                try
                    -- whichコマンドでnvimパスを取得
                    set nvimPath to do shell script "which nvim"
                    do shell script "/opt/homebrew/bin/wezterm cli spawn --cwd " & quoted form of fileDir & " -- " & nvimPath & " " & quotedPath
                on error
                    try
                        set nvimPath to do shell script "which nvim"
                        do shell script "/usr/local/bin/wezterm cli spawn --cwd " & quoted form of fileDir & " -- " & nvimPath & " " & quotedPath
                    end try
                end try
            end try
        end try
    end repeat
end open

-- ドラッグ&ドロップ以外でアプリが起動された場合
on run
    tell application "WezTerm"
        activate
    end tell
    
    try
        do shell script "/opt/homebrew/bin/wezterm cli spawn -- /Users/d4rj3311n6/.local/share/mise/installs/neovim/0.11.4/bin/nvim"
    on error
        try
            do shell script "/usr/local/bin/wezterm cli spawn -- /Users/d4rj3311n6/.local/share/mise/installs/neovim/0.11.4/bin/nvim"
        on error
            try
                -- whichコマンドでnvimパスを取得
                set nvimPath to do shell script "which nvim"
                do shell script "/opt/homebrew/bin/wezterm cli spawn -- " & nvimPath
            on error
                try
                    set nvimPath to do shell script "which nvim"
                    do shell script "/usr/local/bin/wezterm cli spawn -- " & nvimPath
                end try
            end try
        end try
    end try
end run