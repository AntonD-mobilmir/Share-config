;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if ErrorLevel = ERROR
	MsgBox Без прав администратора ничего не выйдет.
    ExitApp
}

Try
    exe7z:=find7zexe()
Catch
    exe7z:=find7zaexe()

runString = "%exe7z%" x -aoa -o"%A_AppDataCommon%\mobilmir.ru" -- "%A_ScriptDir%\Rarus_Scripts.7z"
RunCheckError(runString)

RunCheckError(ComSpec . " /C """ . A_ScriptDir . "\_shedule_backup1Sbase.cmd""")

Exit

RunCheckError(cmdline) {
    RunWait %cmdline%,,UseErrorLevel
    If (ErrorLevel)
	MsgBox "%cmdline%"`nerror: %ErrorLevel%
    return ErrorLevel
}

#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\find7zexe.ahk
