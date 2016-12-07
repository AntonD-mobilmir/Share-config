#NoEnv
#SingleInstance force

rdistpath=download.cdn.mozilla.net/pub/mozilla.org/thunderbird/releases/latest/win32/en-GB/

RunWait C:\SysUtils\wget.exe -m -np -e robots=off -A.exe`,.asc`,.html http://%rdistpath% -o"%A_ScriptName%.log" -DHreleases.mozilla.org`,download.cdn.mozilla.net, %A_ScriptDir%\temp
Loop %A_ScriptDir%\temp\%rdistpath%\*.exe
    If ( A_LoopFileTimeCreated > LastestDistributiveTime ) {
	LastestDistributiveTime := A_LoopFileTimeCreated
	DistPath := A_LoopFileFullPath
    }

RunWait "%DistPath%" /INI="%A_ScriptDir%\install.ini"
