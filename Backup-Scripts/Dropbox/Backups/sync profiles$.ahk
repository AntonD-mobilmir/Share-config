#NoEnv
#SingleInstance ignore
EnvGet USERPROFILE,USERPROFILE

logFile=%A_Temp%\%A_ScriptName%.%A_Now%.log
srcCopyInventoryScripts=%USERPROFILE%\Dropbox\Backups\profiles$\Share\Inventory
destCopyInventoryScripts=%USERPROFILE%\Git\Share-config\Inventory
destUnpack=%USERPROFILE%\Git\Share-config\config_unpacked

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

SetStatus(RunString)
RunWait %RunString% %1%,,%runMode%
If (ErrorLevel)
    Run %RunString%
SetStatus()

FileRemoveDir %destCopyInventoryScripts%, 1
Loop Files, %srcCopyInventoryScripts%\*, D
{
    curDst := destCopyInventoryScripts "\" A_LoopFileName
    If (!FileExist(curDst))
	FileCreateDir %curDst%
    FileCopy %A_LoopFileFullPath%\*.ahk, %curDst%
    FileCopy %A_LoopFileFullPath%\*.cmd, %curDst%
    FileCopy %A_LoopFileFullPath%\*.lnk, %curDst%
}

Try
    exe7z:=find7zexe()
Catch
    exe7z:=find7zaexe()

backupWorkingDir := A_WorkingDir
SetWorkingDir %A_ScriptDir%\profiles$\Share\config

FileRemoveDir %destUnpack%, 1
skipArchives := {"schtasks.7z":1,"staged.7z":1,"staged-crash201504.7z":1,"staged-not-retail.7z":1,"staged-retail.7z":1,"DOL2.template.7z":1}
Loop Files, *.7z, R
    If (!skipArchives.HasKey(Format("{:L}", A_LoopFileName))) {
	outDir := SubStr(A_LoopFileName, 1, -3)
	SetStatus("Extracting """ . A_LoopFileFullPath . """")
	RunWait %exe7z% x -aoa -o"%destUnpack%\%A_LoopFileDir%\*" -- "%A_LoopFileFullPath%",, Min
    }
SetStatus()

SetWorkingDir %backupWorkingDir%
ExitApp

#include %A_ScriptDir%\profiles$\Share\config\_Scripts\Lib\find7zexe.ahk

SetStatus(status:="", title:="", traytipOpt:="") {
    If (status)
	TrayTip %title%, %status%,, %traytipOpt%
    Else
	TrayTip
    Menu Tray, Tip, %status%
}