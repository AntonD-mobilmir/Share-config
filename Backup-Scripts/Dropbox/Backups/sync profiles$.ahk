#NoEnv
#SingleInstance ignore
logFile=%A_Temp%\%A_ScriptName%.%A_Now%.log
arg1=%1%
If (arg1="-batch") {
    runMode=Hide
    unisonExecType=unisontext
} Else {
    unisonExecType=unisongui
}

EnvGet unisonexe, %unisonExecType%
If (!unisonexe)
    unisonexe := Expand(ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_unison_get_command.cmd", unisonExecType))

RunString=%unisonexe% profiles$ -root "%A_ScriptDir%\profiles$"

RunWait %RunString% %1%,,%runMode%
If ErrorLevel
    Run %RunString%

Try
    exe7z:=find7zexe()
Catch
    exe7z:=find7zaexe()

EnvGet USERPROFILE,USERPROFILE

backupWorkingDir := A_WorkingDir
SetWorkingDir %A_ScriptDir%\profiles$\Share\config

Loop Files, *.7z, R
{
;    If A_LoopFileDir not in thunderbird\default_profile_template\extensions
    If A_LoopFileName not in schtasks.7z,staged.7z,staged-crash201504.7z,staged-not-retail.7z,staged-retail.7z
    {
	outDir := SubStr(A_LoopFileName, 1, -3)
	RunWait %exe7z% x -aoa -o"%USERPROFILE%\Git\Share-config\config_unpacked\%A_LoopFileDir%\*" -- "%A_LoopFileFullPath%",, Min
    }
}

SetWorkingDir %backupWorkingDir%
ExitApp

#include %A_ScriptDir%\profiles$\Share\config\_Scripts\Lib\find7zexe.ahk
