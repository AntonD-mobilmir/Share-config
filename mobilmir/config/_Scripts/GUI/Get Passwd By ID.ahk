;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

TargetFile := "\\Srv0.office0.mobilmir\Ограниченный доступ\4. Организационно-управленческий департамент\Служба ИТ\Отдел информационных технологий\Группа системного администрирования\генерируемые идентификаторы.txt"
SEEK_CUR=1

InputBox passID, ID
If ErrorLevel
    Exit
file := FileOpen(TargetFile, "r")
If (file && passID < 0) {
    Loop
    {
	If (A_Index > 100)
	    Throw "Смещение не указывает на начало строки, и начало стройки не найдено на расстоянии 100 символов"
	Else If (A_Index > 1)
	    seeksuccess := file.Seek(-2, SEEK_CUR)
	Else
	    seeksuccess := file.Seek(-passID-1)
	If (!seeksuccess)
	    Throw "Ошибка при перемещении указателя в файле."
	if(file.ReadChar() == 10)
	    break
    }
    If(file.Tell() != -passID) {
	MsgBox Смещение указывает не на начало строки.
    }
} Else {
    Loop % passID - 1
    {
	file.ReadLine()
	If (file.AtEOF) {
	    MsgBox Такой строки в файле нет!
	    Exit 2
	}
    }
}
passwd := file.ReadLine()
file.Close()

If (passwd) {
    MsgBox 4, Пароль найден, Пароль: %passwd%`nСкопировать пароль в буфер обмена?
    IfMsgBox Yes
	Clipboard := Trim(passwd,"`r`n")
} Else {
    MsgBox Пароль не прочитался
    Exit 2
}
