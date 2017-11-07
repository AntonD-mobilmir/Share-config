;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance off

If (A_WorkingDir==A_ScriptDir) {
    FileSelectFolder dest,,3
    If ErrorLevel
	Exit
}

argc=%0%
opt := {}

;If var ; If var's contents are blank or 0, it is considered false. Otherwise, it is true.
Loop %argc%  ; For each parameter:
{
    If ( SubStr(%A_Index%, 1, 1) == "/" ) {
	StringTrimLeft option, %A_Index%, 1
	SplitPos := InStr(option, "=")
	If SplitPos
	{
	    StringMid optvalue, option, % SplitPos+1
	    StringLeft option, option, % SplitPos-1
	} Else
	    optvalue=1
	opt[option]:=optvalue
    } Else If (A_Index==1 && InStr(%A_Index%, "\")) {
	dest := %A_Index%
    } Else {
	note .= " " %A_Index%
    }
}

If ( !argc || opt.InputNote ) {
    InputBox note, Комментарий, Комментарий к создаваемой папке.`n%opt_Prompt%
    If ErrorLevel
	ExitApp
}

If (opt.YearSubdir)
    FormatTime Today, , yyyy\yyyy-MM-dd
Else
    FormatTime Today, , yyyy-MM-dd

If (!dest)
    dest := A_WorkingDir

folderName := dest . (SubStr(dest, 0,1) == "\" ? "" : "\") . Today " " StripNonfilenameChars(Trim(note))

If (opt["Clipboard"])
    Clipboard = %folderName%

FileCreateDir %folderName%
If (ErrorLevel)
    MsgBox Ошибка %A_LastError% при попытке создания папки "%folderName%"
If (opt.ShowInFolder)
    Run explorer.exe /select`,"%Today% %note%"

StripNonfilenameChars(ByRef c) {
    n=
    ;https://stackoverflow.com/a/31976060
    Loop Parse, c,,<>:"/\|?*
    {
	If (Asc(A_LoopField) > 31)
	    n .= A_LoopField
	Else
	    n .= "_"
    }
    return n
}
