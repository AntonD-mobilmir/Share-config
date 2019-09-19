;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

GroupAdd tvpanel, Панель TeamViewer ahk_class TV_ServerControl ahk_exe TeamViewer.exe
If (WinExist("ahk_group tvpanel")) {
    WinWaitClose ahk_group tvpanel
    Run %SystemRoot%\System32\tsdiscon.exe
} Else {
    MsgBox TeamViewer не подключен
}
