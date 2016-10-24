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

;If var ; If var's contents are blank or 0, it is considered false. Otherwise, it is true.
If %0%
{
    Loop %0%  ; For each parameter:
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
	    opt_%option%=%optvalue%
	} else {
	    note .= %A_Index%
	    If 0 > %A_Index%
		note .= A_Space
	}
    }
}

If ( !%0% Or opt_InputNote ) {
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
