on open theFiles
    repeat with aFile in theFiles
        set filePath to POSIX path of aFile
        set quotedPath to quoted form of filePath
        
        -- WeztermでNvimを起動
        try
            do shell script "/opt/homebrew/bin/wezterm start --cwd " & quoted form of (do shell script "dirname " & quotedPath) & " -- nvim " & quotedPath
        on error
            try
                do shell script "/usr/local/bin/wezterm start --cwd " & quoted form of (do shell script "dirname " & quotedPath) & " -- nvim " & quotedPath
            end try
        end try
    end repeat
end open

-- ドラッグ&ドロップ以外でアプリが起動された場合
on run
    try
        do shell script "/opt/homebrew/bin/wezterm start -- nvim"
    on error
        try
            do shell script "/usr/local/bin/wezterm start -- nvim"
        end try
    end try
end run