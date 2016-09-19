;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

If (A_UserName="Продавец") {
    Run %A_WinDir%\System32\REG.exe IMPORT "D:\1S\Rarus\Title.reg"
    FileCopy %A_DesktopCommon%\1С - Рарус - Продавец.lnk, %A_Startup%
}
FileDelete %A_ScriptFullPath%
