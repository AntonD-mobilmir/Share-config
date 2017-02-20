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

exe7z:=find7zGUIorAny()
pathRarusScripts7z=%A_ScriptDir%\Rarus_Scripts.7z
FileGetTime dateRarusScripts7z, %pathRarusScripts7z%
runString = "%exe7z%" x -aoa -o"%A_AppDataCommon%\mobilmir.ru" -- "%pathRarusScripts7z%"
If (unpackError := RunCheckError(runString))
    dateRarusScripts7z .= " | Unpack error: " . unpackError
If (scheduleError := RunCheckError(ComSpec . " /C """ . A_ScriptDir . "\_shedule_backup1Sbase.cmd"""))
    dateRarusScripts7z .= " | Schedule error: " . scheduleError

PostGoogleForm("https://docs.google.com/a/mobilmir.ru/forms/d/e/1FAIpQLSf5-px897966MD2bv05DELVFk8_HiDanM6higcUNboT_4QSlQ/formResponse"
		,{"entry.1837477723":	GetMailUserId()
		 ,"entry.456008757":	A_ComputerName
		 ,"entry.1402897460":	dateRarusScripts7z})

Exit

RunCheckError(cmdline) {
    RunWait %cmdline%,%A_Temp%,Min UseErrorLevel
    If (ErrorLevel)
	MsgBox "%cmdline%"`nerror: %ErrorLevel%
    return ErrorLevel
}

#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\find7zexe.ahk
#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\PostGoogleForm.ahk
#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\GetMailUserId.ahk
