#NoEnv
FileEncoding UTF-8

global run1s := ""
AddBasesDir = %A_ScriptDir%\Дополнительные базы

If (A_ComputerName="Srv1S") {
    run1s := "d:\Meta1s\BIN\run_with_substituted_temp.ahk"
} Else If (A_ComputerName="Srv1S-B") {
    run1s := "d:\1S\BIN\run_with_substituted_temp.ahk"
} Else {
    Loop 4
	If (StartsWith(A_IPAddress%A_Index%, "192.168.2."))
	    run1s := "\\Srv1S.office0.mobilmir\1S\BIN\run_with_substituted_temp.ahk"
    If (!run1s)
	run1s := "\\Srv1S-B.office0.mobilmir\1S-BIN\run_with_substituted_temp.ahk"
}
global Description := "Активация существующей или запуск первой 1С с выбором загружаемой базы (конфигурации). Запуск новой без проверки существующей – Shift."

FileCopyDir %A_ScriptDir%\AppData, %A_AppData%, 1
configfile = %A_AppData%\1C\1CEStart\ibases.v8i

addAll := CheckUsernameListFiles(AddBasesDir)

Loop Files, %AddBasesDir%\*, D
{
    If (addAll || CheckUsernameListFiles(A_LoopFileFullPath)) {
	FileRead bases, %A_LoopFileFullPath%\ibases.v8i
	dataToAppend .= "`r`n" bases
	bases=
    }
}
If (dataToAppend)
    FileAppend %dataToAppend%,*%configfile%

VarSetCapacity(LocalAppData,1025 << A_IsUnicode) ; if A_IsUnicode, shift left = multiply by 2
r:=DllCall("Shell32\SHGetFolderPath", "int", 0 , "uint", 28 , "int", 0 , "uint", 0 , "str" , LocalAppData)
If (r or ErrorLevel)
    LocalAppData=%A_AppData%\..\Local

FileCreateDir %LocalAppData%\1C
FileCopy %A_ScriptDir%\1C.ico, %LocalAppData%\1C
global icon1s := LocalAppData "\1C\1C.ico"

Loop Files, %run1s%
{
    run1s:=A_LoopFileLongPath
    run1sDir:=A_LoopFileDir
    break
}

; modes:
; 1 = read title
mode:=1
Loop Read, %configfile%
{
    If (mode=1) { ; Поиск заголовка
	ReadLine:=Trim(A_LoopReadLine)
	If (SubStr(ReadLine,1,1)=="[" && SubStr(ReadLine,0,1)=="]") {
	    Title:=SubStr(ReadLine,2,StrLen(ReadLine)-2)
	    mode++
	}
    } Else If (mode=2) { ; Заголовок прочитан, теперь параметры подключения
	ConnectStr:=IniReadUnicode(configfile, Title, "Connect")
	Create1SDBShortcut(Title, ConnectStr)
	mode=1
    }
    
}

Create1SShortcut("(список конфигураций)", "")

;IF A_ComputerName in Srv1S,Srv1S-old
IF A_ComputerName not contains Srv
    FileCreateShortcut \\Srv1S.office0.mobilmir\1s\Дистрибутив\Srv1S.rdp, %A_Desktop%\Сервер 1С 8 в офисе Цифроград.lnk,,, Подключение к серверу 1С в терминальном режиме. Пожалуйста`, не забывайте завершать сеанс работы для освобождения ресурсов сервера.
Run "%A_ScriptDir%\run1s_protocol_association.ahk" "%run1s%",, Min

MsgBox Заменён список баз 1С`, и на рабочий стол скопированы ярлыки для запуска баз 1С напрямую. Неиспользуемые можно удалить.

Create1SDBShortcut(Title, ConnectStr) {
    ;what we get: Srvr="Srv1S.office0.mobilmir:1541";Ref="HRM";
    ;what we need: /SSrv1S.office0.mobilmir:1541\HRM
    
    ;what we get: File="\\ComDept-Head\База данных";
    ;what we need: /F"\\ComDept-Head\База данных"
    
    Loop Parse, ConnectStr, `;
    {
	SplitPos:=InStr(A_LoopField, "=")
	ConnVarName:=SubStr(A_LoopField,1,SplitPos-1)
	If (ConnVarName) {
	    If ConnVarName in Srvr,Ref,File
	    {
		ConnVar%ConnVarName% := Trim(SubStr(A_LoopField, SplitPos+1), """ `t")
	    } Else {
		MsgBox Ошибка при создании ярлыка, При создании ярлыка для базы %Title% произошло исключение: тип подключения к базе указан как %ConnVarName%`, и для этого типа не опеределён обработчик.`n`nПожалуйста`, зарегистрируйте заявку для службы ИТ с текстом из данного окна (Ctrl+C`, выделять не надо).
	    }
	}
    }
    
    If (ConnVarSrvr) {
	Create1SShortcut(Title, "/S" . ConnVarSrvr . "\" . ConnVarRef)
    } Else If (ConnVarFile) {
	Create1SShortcut(Title, "/F""" . ConnVarFile . """")
    }
}

Create1SShortcut(Title, Args) {
    global run1s,Description,icon1s
    FileCreateShortcut %run1s%, %A_Desktop%\1С 8 %Title%.lnk, %run1sDir%, ENTERPRISE %Args%, %Description%, %icon1s%
}

CheckUsernameListFiles(ByRef dir) {
    static FullUserName := 0
    
    If (FullUserName==0)
	FullUserName := WMIGetUserFullName()
    nameLists := { "users.txt": A_UserName
		 , "пользователи.txt": FullUserName }
    
    For file, username in nameLists {
    } Until found := FileContainsLine(dir "\" file, username)
    return found
}

FileContainsLine(ByRef path, ByRef line) {
    Loop Read, %path%
	If (A_LoopReadLine = line)
	    return 1
}

StartsWith(ByRef long, ByRef short) {
    return SubStr(long, 1, StrLen(short)) = short
}

#include <IniFilesUnicode>
#include <WMIGetUserFullName>
