;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#Persistent
#SingleInstance force

SetKeyDelay 0
SetControlDelay 0

OnClipboardChange("ClipChanged")

Loop
{
    WinWait Save As ahk_class #32770 ahk_exe 1cv8.exe
    FileCreateDir %destDir%
    Sleep 300
    ControlSetText Edit1, %destDir%\%newName%
    ControlFocus ComboBox2
    ControlSend ComboBox2, Л
    WinWaitClose
    destDir=
    newName=
}
return

ClipChanged(type) {
    global newName,destDir
    If (!(type==1))
	return
    ClipWait 0
    c:=Clipboard
    ;ШМ000010514
    ;ЗМ^0000768
    If (RegexMatch(c, "^(?P<Num>..(^\d{7}|\d{9}))\s+", d)) {
	c := SubStr(c, StrLen(dNum)+1)
    }

    c := Trim(c, "`t `n`r")
    ;11.07.2017 9:20:34 ИБП 3Cott Micropower 1000VA/600W 2 линейно-интерактивный → касса на Доваторцев (Zoho #1775)
    If (RegExMatch(c, "^(?P<DD>\d\d)\.(?P<MM>\d\d)\.(?P<YYYY>\d{4})\s\d{1,2}:\d\d:\d\d\s(?P<text>.+)$", m)) {
	newSubdir := mYYYY "-" mMM "-" mDD " " StripNonfilenameChars(mtext)
	destDir=%A_ScriptDir%\%mYYYY%\%newSubdir%
	Clipboard := dNum ? dNum : newSubdir
    } Else {
	newName := StripNonfilenameChars(c)
    }
}

StripNonfilenameChars(ByRef c) {
    n=
    ;https://stackoverflow.com/a/31976060
    Loop Parse, c,,<>:"/\|?*
    {
	If (Asc(A_LoopField) > 31)
	    n .= A_LoopField
    }
    return n
}
