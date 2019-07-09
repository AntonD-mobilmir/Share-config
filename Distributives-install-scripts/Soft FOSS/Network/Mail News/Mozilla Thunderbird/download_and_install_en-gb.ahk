#NoEnv
#SingleInstance force

;url=download.cdn.mozilla.net/pub/mozilla.org/thunderbird/releases/latest/win32/en-GB/
suffix64 := A_Is64bitOS ? "64" : ""
distDir := A_ScriptDir "\" (A_Is64bitOS ? "64" : "32") "-bit"
url=https://download.mozilla.org/?product=thunderbird-latest&os=win%suffix64%&lang=en-GB

Loop Files, %distDir%\*.exe
    If ( A_LoopFileTimeCreated > LastestDistributiveTime ) {
	lastestDistributiveTime := A_LoopFileTimeCreated
	lastestDistPath := A_LoopFileFullPath
    }

If (lastestDistPath)
    timeCond = -z "%lastestDistPath%"

FileCreateDir %distDir%\temp
;RunWait wget.exe -m -np -nd -e robots=off -A.exe`,.asc`,.html %url% -o"%A_ScriptName%.log" -DHreleases.mozilla.org`,download.cdn.mozilla.net, %distDir%\temp
RunWait %comspec% /K "CURL -RJO %timeCond% "%url%"", %distDir%\temp
Loop Files, %distDir%\temp\*.exe
{
    FileMove %A_LoopFileFullPath%, %distDir%\%A_LoopFileName%, 1
    distPath = %distDir%\%A_LoopFileName%
}
FileRemoveDir %distDir%\temp

RunWait "%distPath%"
; /INI="%A_ScriptDir%\install.ini"
