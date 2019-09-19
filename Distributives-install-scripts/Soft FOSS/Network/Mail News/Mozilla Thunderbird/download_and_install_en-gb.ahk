#NoEnv
#SingleInstance force

;url=download.cdn.mozilla.net/pub/mozilla.org/thunderbird/releases/latest/win32/en-GB/
suffix64 := A_Is64bitOS ? "64" : ""
distDir := A_ScriptDir "\" (A_Is64bitOS ? "64" : "32") "-bit"
lang=en-GB
url=https://download.mozilla.org/?product=thunderbird-latest&os=win%suffix64%&lang=%lang%

nameHeader := "Location: "

Loop Files, %distDir%\*.exe
    If ( A_LoopFileTimeCreated > LastestDistributiveTime ) {
	lastestDistributiveTime := A_LoopFileTimeCreated
	lastestDistPath := A_LoopFileFullPath
    }

If (lastestDistPath)
    timeCond = -z "%lastestDistPath%"

FileCreateDir %distDir%\temp
;RunWait wget.exe -m -np -nd -e robots=off -A.exe`,.asc`,.html %url% -o"%A_ScriptName%.log" -DHreleases.mozilla.org`,download.cdn.mozilla.net, %distDir%\temp
RunWait CURL -LR %timeCond% -D "%distDir%\temp\header.txt" -o "%distDir%\temp\Thunderbird Setup downloaded.exe" "%url%", %distDir%\temp

If (IsFunc("UriDecode")) {
    Loop Read, %distDir%\temp\header.txt
        If (nameHeader = SubStr(A_LoopReadLine, 1, StrLen(nameHeader)))
            lastURL := SubStr(A_LoopReadLine, StrLen(nameHeader)+1)
    Loop Parse, lastURL, /
        encodedName := A_LoopField
    renameTo := Func("UriDecode").Call(encodedName) A_Space lang
} Else {
    renameTo = Thunderbird Setup _ %lang%.exe
}
Loop Files, %distDir%\temp\*.exe
{
    distPath = %distDir%\%renameTo%
    FileMove %A_LoopFileFullPath%, %distPath%, 1
}

If (distPath) {
    FileDelete %distDir%\temp\header.txt
    FileRemoveDir %distDir%\temp
    RunWait "%distPath%"
    ; /INI="%A_ScriptDir%\install.ini"
}

ExitApp

StartsWith(ByRef long, ByRef short) {
    return short = SubStr(long, 1, StrLen(short))
}

#include *i <URIEncodeDecode>
