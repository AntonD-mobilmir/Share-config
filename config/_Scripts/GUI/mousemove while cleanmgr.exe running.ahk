;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

SendMode Input

Process Wait, cleanmgr.exe
Loop
{
    Sleep 3000
    Process Exist, cleanmgr.exe
    If (!ErrorLevel)
        ExitApp
    MouseMove 0, 0, 0, R
    ;MouseMove 1, 0, 0, R
    ;MouseMove -1, 0, 0, R
}
