;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance off

If (A_WorkingDir==A_ScriptDir) {
    FileSelectFolder dest,,3
    If ErrorLevel
	Exit
    SetWorkingDir %dest%
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
    } Else If (A_Index==1 && FileExist(%A_Index%)) {
	SetWorkingDir % %A_Index%
    } Else {
	note .= %A_Index%
	If 0 > %A_Index%
	    note .= A_Space
    }
}

If ( !argc || opt.InputNote ) {
    InputBox note, Комментарий, Комментарий к создаваемой папке.`n%opt_Prompt%
    If ErrorLevel
	ExitApp
}

If opt_YearSubdir
    FormatTime Today, , yyyy\yyyy-MM-dd
Else
    FormatTime Today, , yyyy-MM-dd
FileCreateDir %Today% %note%
If opt_Clipboard
    Clipboard = %A_WorkingDir%\%Today% %note%\

If opt_ShowInFolder
    Run explorer.exe /select`,"%Today% %note%"
