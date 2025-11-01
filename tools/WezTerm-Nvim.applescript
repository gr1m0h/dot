on open theFiles
    repeat with aFile in theFiles
        set filePath to POSIX path of aFile
        set quotedPath to quoted form of filePath
        
        -- WeztermでNvimを起動
        tell application "WezTerm"
            activate
            do shell script "/usr/local/bin/wezterm cli spawn --cwd " & quoted form of (do shell script "dirname " & quotedPath) & " -- nvim " & quotedPath
        end tell
    end repeat
end open

-- ドラッグ&ドロップ以外でアプリが起動された場合
on run
    tell application "WezTerm"
        activate
        do shell script "/usr/local/bin/wezterm cli spawn -- nvim"
    end tell
end run