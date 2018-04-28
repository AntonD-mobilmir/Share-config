;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

syncWinTitle = Синхронизация данных ahk_class #32770 ahk_exe ICLTransportSystem.exe
syncErrMsg = Код ошибки: 
;ОК
;Процесс синхронизации завершился с ошибкой.
;Код ошибки: 0x3a.
;Описание ошибки: Указанный сервер не может выполнить требуемую операцию.
;Контактная информация службы поддержки: Ф-л Банка ГПБ (АО) в г.Ставрополе тел: +7(8652)56-67-85

syncWinErrTxt := "		!!! Ошибка !!!"
;Progress1
;		!!! Ошибка !!!
;	Произошла ошибка синхронизации.
;	Обратитесь к администратору.
;Контактная информация службы поддержки: Ф-л Банка ГПБ (АО) в г.Ставрополе тел: +7(8652)56-67-85
;Copyright © 2015 ОАО "ICL-КПО ВС"
;Закрыть
;Скрыть...
;List1


Loop
{
    If (!WinExist(syncWinTitle)) {
        ControlClick x340 y65, ahk_class TExecDialog ahk_exe cbmain.ex
        ;ДБО BS-Client v.3  Ф-л ГПБ (ОАО) в г.Ставрополе ahk_class TExecDialog ahk_exe cbmain.ex
        WinWait %syncWinTitle%
    }
    
    While WinExist(syncWinTitle) {
        Sleep 5000
        If (WinExist(syncWinTitle, syncWinErrTxt))
            WinClose
        Else If (WinExist(syncWinTitle, syncErrMsg))
            ControlClick Button1
        Sleep 3000
    }
}
