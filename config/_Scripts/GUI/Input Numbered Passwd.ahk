;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

IF (A_LineFile==A_ScriptFullPath) {
    passwd = %1%
    If(!passwd) {
	InputBox passwd
	If(ErrorLevel)
	    ExitApp
	If(!passwd) {
	    MsgBox Пароль для добавления не указан
	    ExitApp
	}
    }
    WriteAndShowPassword(passwd)
    Exit
}

WriteAndShowPassword(passwd) {
    global passwdNo
    passwdNo := WritePassword(passwd, WrittenActually)

    If (WrittenActually)
	Run "%A_AhkPath%" "%A_LineFile%\..\..\Lib\PostNumberedPassword.ahk" %passwdNo% "%passwd%"

    Gui Add, Button, xm section gCopypasswdNo, Скопировать
    Gui Font, , Consolas
    Gui Add, Edit, ys ReadOnly gSelectAllCopy, %passwdNo%
    Gui Font
    Gui Add, Button, xm section gCopypasswd, Скопировать
    Gui Font, , Consolas
    Gui Add, Edit, ys ReadOnly gSelectAllCopy , %passwd%
    Gui Font
    Gui Add, Button, xm section gReload, Получить ещё один код&.
    Gui Show

    ;Соответствия в https://docs.google.com/a/mobilmir.ru/spreadsheets/d/1lUGVjDWEG3znDUKy-l59Ewt95eFrIgUO-L8dy3lxNWQ
    FileAppend %passwdNo%: %passwd%`n, %A_Temp%\%A_ScriptName%.txt
    Run %A_WinDir%\System32\cipher.exe /E /B "%A_Temp%\%A_ScriptName%.txt",,Min
    ;MsgBox 4, Регистрация пароля BIOS, Пароль: «%passwd%»`nНомер пароля: %passwdNo%`n`nСкопировать пароль в буфер обмена?
    ;IfMsgBox Yes
    ;    Clipboard := passwd
    
    return passwdNo
}

MsgBox Ошибка в %A_ScriptFullPath%! Выполнение скрипта не должно проходить "через" #Include %A_LineFile%. 
ExitApp

GuiEscape:
GuiClose:
ButtonCancel:
    ExitApp

CopypasswdNo:
Copypasswd:
    copyVarName:=SubStr(A_ThisLabel,5)
    clipboard:=%copyVarName%
    return

SelectAllCopy:
    EM_SETSEL := 0x00B1
    ;A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
    Gui +LastFound
    ControlFocus %CtrlHwnd%
    ;https://autohotkey.com/board/topic/39793-how-to-select-the-text-in-an-edit-control/
    SendMessage %EM_SETSEL%, 0, -1, %CtrlHwnd%
;    MsgBox %ERRORLEVEL%
return

Reload:
    Reload

#include %A_LineFile%\..\..\Lib\ParseCommandLine.ahk
#include %A_LineFile%\..\..\Lib\WriteNumberedPassword.ahk
#include %A_LineFile%\..\..\Lib\URIEncodeDecode.ahk
