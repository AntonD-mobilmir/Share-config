;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

global childPID
OnExit("KillChild")

FileGetTime origOcxDate, d:\dealer.beeline.ru\bin\criacx.ocx
criacxinbin := !ErrorLevel

FileDelete d:\Local_Scripts\beeline DOL2.cmd
FileDelete d:\dealer.beeline.ru\criacx.cab

If (A_IsAdmin) {
    MsgBox Используйте Check_Retail_Dept.ahk!
} Else {
    ; Запущено из под пользователя без прав администратора
    ; config обновить не получится
    ; Минимальный вариант с распаковкой ocx с сервера и заменой в bin
    comment := "Без прав администратора"
    exe7z := find7zGUIorAny()
    If (!exe7z)
	Throw Exception("Не найден 7-Zip.")
    RunWait "%exe7z%" x -aoa -o"D:\" -- "%A_ScriptDir%\D.7z" dealer.beeline.ru
    FileCopyDir %A_ScriptDir%\D\dealer.beeline.ru, D:\dealer.beeline.ru, 1
    
    If (!criacxinbin) {
	Run http://l.mobilmir.ru/newtaskdept
	MsgBox На Вашем компьютере criacx.ocx не был установлен скриптом`, поэтому обновить его скриптом не получится. Делайте заявку для отдела ИТ <http://l.mobilmir.ru/newtaskdept>.
	ExitApp
    }
}

If (criacxinbin) {
    ; Обновление criacx.ocx
    RunWait %comspec% /C ""d:\dealer.beeline.ru\update_dealer_beeline_activex.cmd" /Unpack", d:\dealer.beeline.ru, Min UseErrorLevel, childPID
    If (ErrorLevel)
	comment .= ", ErrorLevel:" . errFinal
    FileGetTime newOcxDate, d:\dealer.beeline.ru\bin\criacx.ocx
    FileGetTime newdol2ahkDate, d:\dealer.beeline.ru\beeline DOL2.ahk
    
    diffOcxTime := newOcxDate
    diffOcxTime -= origOcxDate, Days
    
    If (diffOcxTime)
	comment .= ", timeDiff: " . diffOcxTime
    
    PostGoogleForm("https://docs.google.com/a/mobilmir.ru/forms/d/e/1FAIpQLSeRvIBRHnVjhnUS09Dh7lNEoXtTRjkY9210stwJhftwqQ8tgg/formResponse"
		    , {   "entry.1266830572": GetDeptID()
			, "entry.298209335": A_ComputerName
			, "entry.411109659": A_UserName
			, "entry.831594180": newOcxDate
			, "entry.357875961": newdol2ahkDate
			, "entry.352111625": Trim(comment, ",`t ")})

    Exit diffOcxTime!=0
} Else {
    Exit -1
}


KillChild() {
    If (childPID)
	Run %A_Windir%\System32\TASKKILL.exe /PID %childPID% /T /F
    return
}

#include %A_LineFile%\..\..\..\_Scripts\Lib\getDefaultConfig.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\find7zexe.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\PostGoogleForm.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\GetDeptID.ahk
