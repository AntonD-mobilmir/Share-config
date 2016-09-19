;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

GetPswDbLocation() {
    return "\\Srv0.office0.mobilmir\Ограниченный доступ\4. Организационно-управленческий департамент\Служба ИТ\Отдел информационных технологий\Группа системного администрирования\генерируемые идентификаторы.txt"
}

WritePassword(passwd, ByRef WrittenActually:=0) {
    pswDBfile := GetPswDbLocation()
    
    WrittenActually := 0
    Try return FindPassword(passwd, 1)
    
    Loop
    {
	file := FileOpen(pswDBfile, "a-w")
	If (!file) {
	    MsgBox 5, %A_ScriptName%, Не удалось открыть файл с паролями для записи.`n(автоповтор через минуту`, попытка %A_Index%), 60
	    IfMsgBox TIMEOUT
		continue
	    IfMsgBox Retry
		continue
	}
	break
    }

    fPos := file.Tell() ; backup for the case we don't have read access
    written := file.Write("`r`n" . passwd)
    file.Close()
    If (written  < (StrLen(passwd) + 2) ) {
	Throw "Файл с паролями открылся`, но пароль не записался (записалось " . written . " байт)."
    }
    WrittenActually := 1
    
    Try return FindPassword(passwd, 1)

    return -fPos
}

FindPassword(passwd, last=0) {
    pswDBfile := GetPswDbLocation()
    
    If (last) {
	lineLastFound := 0
	Loop Read, %pswDBfile%
	    If (A_LoopReadLine==passwd)
		lineLastFound := A_Index
	If (!lineLastFound)
	    Throw "Password not found"
	return lineLastFound
    } Else {
	Loop Read, %pswDBfile%
	    If (A_LoopReadLine==passwd)
		return A_Index
	return 0
    }
}
