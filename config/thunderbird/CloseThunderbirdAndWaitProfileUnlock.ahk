;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

GroupAdd Thunderbird, ahk_exe thunderbird.exe
CloseThunderbirdAndWaitProfileUnlock(MTProfilePath="") {
    If Not MTProfilePath
	MTProfilePath:=FindThunderbirdProfile()
    TrayTip Закрытие Thunderbird, Закрытие окон Thunderbird
    WinClose ahk_group Thunderbird,,20
    TrayTip

    TrayTip Закрытие Thunderbird, Отправка сигнала завершения оставшимся процессам
    Loop {
	Process Close, thunderbird.exe
    } Until !ErrorLevel
    TrayTip
    
    TrayTip Закрытие Thunderbird, Ожидание завершения оставшихся процессов
    Process WaitClose, thunderbird.exe, 10
    If ErrorLevel ; if process not exist, ErrorLevel is 0
	MsgBox Не получается закрыть Thunderbird.`nЗакройте его пожалуйста сами`, чтобы профиль не был занят`, прежде чем нажать ok.

    FileDelete %MTProfilePath%\parent.lock
    IfExist %MTProfilePath%\parent.lock
    {
	MsgBox Профиль всё ещё занят`, нельзя продолжать.`nСкрипт завершает работу`, так ничего и не сделав.
	Exit
    }
    
    Sleep 3000
}
