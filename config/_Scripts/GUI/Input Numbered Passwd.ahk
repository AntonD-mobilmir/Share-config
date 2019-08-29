;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
If (A_LineFile==A_ScriptFullPath) {
    GetSecretURLs(0)
    FileEncoding CP1
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
    FileAppend % (passwordID := WriteAndShowPassword(passwd)) "`n", *
    If (passwordID)
        Exit
    ExitApp
}

WriteAndShowPassword(ByRef passwd, ByRef fileToAppendPassword := -1) {
    global SystemRoot
    If (!SystemRoot)
	EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server
    
    passwordID := RecordPassword(passwd)
    ;Соответствия в https://docs.google.com/a/mobilmir.ru/spreadsheets/d/1lUGVjDWEG3znDUKy-l59Ewt95eFrIgUO-L8dy3lxNWQ
    
    Gui Add, Button, xm section gCopypasswordID, Скопировать (&n)
    Gui Font, , Consolas
    Gui Add, Edit, ys ReadOnly gSelectAllCopy, %passwordID%
    Gui Font
    Gui Add, Button, xm section gCopypasswd, Скопировать (&p)
    Gui Font, , Consolas
    Gui Add, Edit, ys ReadOnly gSelectAllCopy, %passwd%
    Gui Font
    Gui Add, Button, xm section gReload, Получить ещё один код&.
    Gui Show
    
    If (fileToAppendPassword) {
        If (fileToAppendPassword==-1)
            fileToAppendPassword = %A_Temp%\Numbered Passwords.e\%A_ScriptName%.txt
        SplitPath fileToAppendPassword,, outDir
        FileCreateDir %outDir%
        RunWait %SystemRoot%\System32\cipher.exe /E /S "%outDir%",,Min
        FileAppend %passwd%`n, %fileToAppendPassword%
    }
    
    return passwordID

    CopypasswordID:
    Copypasswd:
        copyVarName:=SubStr(A_ThisLabel,5)
        Clipboard:=%copyVarName%
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
}

GuiEscape:
GuiClose:
ButtonCancel:
    ExitApp

Reload:
    Reload

GetPswDbLocation() {
    ;"\\Srv0.office0.mobilmir\Ограниченный доступ\4. Организационно-управленческий департамент\Служба ИТ\Отдел информационных технологий\Группа системного администрирования\генерируемые идентификаторы.txt"
    return "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\Ограниченный доступ\4. Организационно-управленческий департамент\Служба ИТ\Отдел информационных технологий\Группа системного администрирования\генерируемые идентификаторы.txt"
}

GetSecretURLs(which) {
    static urls := ""
    If (!urls) {
        urls := {}
        ; , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        SplitPath A_LineFile, , , , OutNameNoExt
        Loop Read, %A_LineFile%\..\..\pseudo-secrets\%OutNameNoExt%.txt
            If (A_Index)
                urls[A_Index] := A_LoopReadLine
    }
    return urls[which]
}

GenPasswordUID() {
    ;base62: 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
    ;Z85: 0...9, a...z, A...Z, ., -, :, +, =, ^, !, /, *, ?, &, <, >, (, ), [, ], {, }, @, %, $, #
    static alphabet := "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"
    , charCount := StrLen(alphabet)
    
    passwordUID := ""
    Loop 2
    {
        Random rnd, 1, %charCount%
        passwordUID .= SubStr(alphabet, rnd, 1)
    }
    
    daysSince := ""
    EnvSub daysSince, 20190722, Hours
    Loop 3 ; 85 ^ 3 = 25588 days ~= 70 years
        newDaysSince := daysSince // charCount
        , rem := daysSince - newDaysSince * charCount
        , passwordUID .= SubStr(alphabet, rem+1, 1)
        , daysSince := newDaysSince
    return passwordUID
}

RecordPassword(passwd) {
    ErrorLevel := -1
    Try return FindPassword(passwd, 1)
    
    Loop
    {
        found := 0, passwordID := GenPasswordUID()
        ; проверка дубликатов
        Loop Parse, % GetURL(GetSecretURLs(1)), `n`r
        {
            If (A_LoopField) {
                Loop Parse, A_LoopField, CSV ; timestamp, passwordID
                {
                    If (A_Index==1) {
                        lasttimestamp := A_LoopField
                    } Else If (A_Index==2) {
                        found := passwordID == A_LoopField
                        break ; only need 2nd column
                    }
                }
                If (found)
                    break
            }
        }
    } Until !found
    
    While !HTTPReq("POST", GetSecretURLs(3), "ID=" UriEncode("'" passwordID) "&pwd=" UriEncode("'" passwd), response := "", {"Content-Type": "application/x-www-form-urlencoded"}) {
        MsgBox 53, Запись пароля с ID %postID% в таблицу, При отправке пароля произошла ошибка.`n`n[Попытка %A_Index%`, автоповтор – 5 минут]`n`n%response%, 300
        IfMsgBox Cancel
            Throw Exception("Отправка пароля отменена")
    }
    
    While !IsObject(file := FileOpen(GetPswDbLocation(), "a-w")) {
        MsgBox 5, %A_ScriptName%, Не удалось открыть файл с паролями для записи.`n(автоповтор через минуту`, попытка %A_Index%), 60
        IfMsgBox Cancel
            break
    }
    
    If (IsObject(file)) {
        written := file.Write("`r`n" passwordID A_Tab passwd)
        file.Close()
        If (written  < (StrLen(passwd) + 2) )
            Throw Exception("Файл с паролями открылся`, но пароль не записался",, "(записалось " . written . " байт).")
        Else
            ErrorLevel := 0
    }
    
    return passwordID
    ;Try return FindPassword(passwd, 1)
}

FindPassword(passwd, last=0) {
    pswDBfile := GetPswDbLocation()
    
    If (last) {
	passwordID := 0
	Loop Read, %pswDBfile%
	    If (A_LoopReadLine==passwd)
		passwordID := A_Index
            Else If (newpasswordID := CheckPasswordFileLine(A_LoopReadLine, passwd))
                passwordID := newpasswordID
	If (!passwordID)
	    Throw Exception("Пароль не найден")
	return passwordID
    } Else {
	Loop Read, %pswDBfile%
	    If (A_LoopReadLine==passwd)
		return A_Index
            Else If (newpasswordID := CheckPasswordFileLine(A_LoopReadLine, passwd))
                return newpasswordID
	return 0
    }
}

CheckPasswordFileLine(ByRef line, ByRef passwd) {
    sep := InStr(line, A_Tab)
    If (sep!=6)
        return 0
    return SubStr(line, sep+1) == passwd ? SubStr(line, 1, sep-1) : 0
}

#include %A_LineFile%\..\..\Lib\URIEncodeDecode.ahk
#include %A_LineFile%\..\..\Lib\HTTPReq.ahk
#include %A_LineFile%\..\..\Lib\GetURL.ahk
