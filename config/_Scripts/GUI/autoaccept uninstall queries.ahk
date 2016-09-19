;Script to automatically confirm GUI uninstall queries
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance Force
SetTitleMatchMode RegEx

FileGetTime scriptInitDate, %A_ScriptFullPath%

Global Log
Log=%A_Desktop%\%A_ScriptName% ClickLog.log

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if ErrorLevel = ERROR
	MsgBox Без прав администратора ничего не выйдет.
    ExitApp
}

Loop {
    FileGetTime scriptCurDate, %A_ScriptFullPath%
    If (scriptCurDate != scriptInitDate)
	Reload
    Sleep 500
    Tooltip
    
    IfWinExist ahk_class #32770, Click Yes to restart
	cclick("No")
    Else IfWinExist ahk_class #32770, You must restart system
	cclick("No")
    Else IfWinExist Удаление ahk_class #32770, Приложение .+ удалено\.
	cclick("ОК")
    Else IfWinExist Удаление ahk_class #32770, Удалить приложение
	cclick("&Да")
    Else IfWinExist Question ahk_class #32770, Would you like to keep
    {
	cclick("&Нет")
	cclick("&No")
    } Else IfWinExist ASUS ahk_class #32770, Do you want keep settings
	cclick("&No")
    Else IfWinExist ahk_class #32770, ^Do &not close applications. \(A Reboot may be required.\)
    {
	cclick("Do &not close applications. \(A Reboot may be required.\)")
	cclick("OK")
    } Else IfWinExist Удаление, Завершение работы мастера удаления
	cclick("&Готово")
    Else IfWinExist,, Программа InstallShield Wizard завершила удаление
    {
	cclick("Нет")
	cclick("Готово")
    } Else IfWinExist ^Acer Backup Manager$ ahk_class #32770, Вы хотите удалить файлы задания?
	cclick("&Да")
;    Else IfWinExist ^Беспроводной адапте\?Atheros 802.11a/b/g$, Файл\?драйвера\, которы\?нужн\?удалит\? не буду\?удален\? та\?ка\? соответствующая плат\?не вставлен\?
    Else IfWinExist ^Беспроводной адапте, ^Файл
	cclick("ОК")
    Else IfWinExist ^Atheros Client Installation Program$, ^Программ
	cclick("Готово")
    Else IfWinExist ^Мастер удаления драйвера устройства$, &ОК
	cclick("&ОК")
    Else IfWinExist ^Основные компоненты Windows Live 2011$ ahk_class LiveDialog, П&ерезапустить позже
	cclick("П&ерезапустить позже")
    Else IfWinExist ^Основные компоненты Windows Live 2011$ ahk_class LiveDialog, Удалить одну или несколько программ Windows Live
	cclick("Удалить одну или несколько программ Windows Live")
    Else IfWinExist ^Основные компоненты Windows Live 2011$ ahk_class LiveDialog, Выбор программ для удаления
    {
	ControlClick X38 Y215, ,,,, Pos
	ControlClick X38 Y256, ,,,, Pos
	ControlClick X38 Y295, ,,,, Pos
	ControlClick X326 Y215,,,,, Pos
	ControlClick X326 Y256,,,,, Pos
	ControlClick X326 Y295,,,,, Pos
	cclick("&Удалить")
    }
    Else IfWinExist ^Удаление Adobe Shockwave Player ahk_class #32770, Закрыть
	cclick("Закрыть")
    Else IfWinExist ^Удаление Adobe Flash Player ahk_class AdobeFlashPlayerInstaller, УСТАНОВКА
	cclick("УСТАНОВКА")
    Else IfWinExist ^Установка Adobe AIR$ ahk_class ApolloRuntimeContentWindow
	cclick("X159 Y177")
    Else IfWinExist InstallShield Wizard$ ahk_class #32770, YES: All data and settings will be removed with application.
    {
	cclick("YES: All data and settings will be removed with application.")
	cclick("Next >")
    }
    Else IfWinExist InstallShield Wizard$ ahk_class #32770, No`, I will restart my computer later.
    {
	cclick("No, I will restart my computer later.")
	cclick("Finish")
    }
    Else IfWinExist InstallShield Wizard$ ahk_class #32770, Finish
	cclick("Finish")
    Else IfWinExist Windows Live ahk_class LiveDialog, Выбор программ для удаления
    {
	ControlClick X58 Y173, ,,,, Pos
	ControlClick X58 Y197, ,,,, Pos
	ControlClick X58 Y224, ,,,, Pos
	ControlClick X58 Y249, ,,,, Pos
	ControlClick X58 Y272, ,,,, Pos
	cclick("&Продолжить")
    }
    Else IfWinExist Windows Live ahk_class LiveDialog, &Продолжить
    {
	cclick("&Удалить")
	cclick("&Продолжить")
    }
    Else IfWinExist Windows Live ahk_class LiveDialog, Готово
	cclick("&Закрыть")
    Else IfWinExist ,, Do you want to completely remove
    {
	cclick("Remove")
	cclick("&Да")
    }
    Else IfWinExist ,, Removal completed successfully.
	cclick("Finish")
    Else IfWinExist Question ahk_class #32770, This will remove 
	cclick("&Да")
    Else IfWinExist Вопрос ahk_class #32770, Эта процедура удалит
	cclick("&Да")
    Else IfWinExist Uninstall Program for ahk_class #32770, Next
	cclick("Button2")
    Else IfWinExist Установщик Windows ahk_class #32770, Д&а
	cclick("Д&а")
    Else IfWinExist Удаление программ на вашем компьютере ahk_class #32770,, OK
	cclick("OK")
    Else IfWinExist Подтвердите удаление файла ahk_class #32770,, &Да
	cclick("&Да")
    Else IfWinExist Подтверждение удаления файла, Удалить выбранное приложение и все его компоненты?
	cclick("ОК")
    Else IfWinExist ,, Удалить выбранное приложение и все его компоненты?
	cclick("&Да")
    Else IfWinExist Удаление ahk_class #32770, &Далее >
	cclick("&Далее >")
    Else IfWinExist Удаление ahk_class obj_Form, Удалить
	cclick("obj_BUTTON2")
    Else IfWinExist Удаление ahk_class #32770, Уд&алить
	cclick("Уд&алить")
    Else IfWinExist Деинсталляция ahk_class #32770, ОК
	cclick("ОК")
    Else IfWinExist Деинсталляция ahk_class #32770, &Да
	cclick("&Да")
    Else IfWinExist Uninstall ahk_class #32770, &Uninstall
	cclick("&Uninstall")
    Else IfWinExist Uninstall ahk_class #32770, Да
	cclick("Да")
    Else IfWinExist Uninstall ahk_class #32770, Finish
	cclick("Finish")
    Else IfWinExist Uninstall ahk_class #32770, ОК
	cclick("ОК") ; Russian letters
    Else IfWinExist Uninstall ahk_class #32770, OK
	cclick("OK") ; English letters
    Else IfWinExist Uninstall ahk_class #32770, Close
	cclick("Close")
    Else IfWinExist Удаление ahk_class #32770, Закрыть
	cclick("Закрыть")
    
}

ExitApp

cclick(label) {
    static prevLabel

    WinGetTitle Title
    FileAppend %A_Now% in "%Title%" clicked %label%`n,%Log%
    ControlClick %label%
    ToolTip Clicked %label%
    
    If (prevLabel=label)
	Sleep 10000
    Else
	prevLabel=label
    return
}

#Esc::	ExitApp
#!SC52:: ;R = SC52 #!R
    TrayTip Reloading, Reloading due to Win+Alt+R
    Sleep 1000
    Reload
    return
Pause::	Pause
