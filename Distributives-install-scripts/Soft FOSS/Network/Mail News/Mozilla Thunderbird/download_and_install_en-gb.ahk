#NoEnv
#SingleInstance force

;url=download.cdn.mozilla.net/pub/mozilla.org/thunderbird/releases/latest/win32/en-GB/
url=https://download.mozilla.org/?product=thunderbird-latest&os=win&lang=en-GB

FileCreateDir %A_ScriptDir%\temp
RunWait C:\SysUtils\wget.exe -m -np -nd -e robots=off -A.exe`,.asc`,.html %url% -o"%A_ScriptName%.log" -DHreleases.mozilla.org`,download.cdn.mozilla.net, %A_ScriptDir%\temp
Loop Files, %A_ScriptDir%\temp\*.exe
    If ( A_LoopFileTimeCreated > LastestDistributiveTime ) {
	LastestDistributiveTime := A_LoopFileTimeCreated
	DistPath := A_LoopFileFullPath
    }

RunWait "%DistPath%"
; /INI="%A_ScriptDir%\install.ini"
