;Script to automatically confirm GUI uninstall queries
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#Include <Expand>
EnvGet RunInteractiveInstalls,RunInteractiveInstalls

If (RunInteractiveInstalls!="0" && !A_IsAdmin) {
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if ErrorLevel = ERROR
	MsgBox Без прав администратора ничего не выйдет.
    ExitApp
}

RegRead Path,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,Path
newPath := removed := ""
Loop Parse, Path,;
{
    If (FileExist(Expand(A_LoopField)))
	newPath .= ";" . A_LoopField
    Else
	removed .= ";" . A_LoopField
}
newPath := SubStr(newPath,2)

If (RunInteractiveInstalls) {
    removed := SubStr(removed,2)

    MsgBox 4, Cleaning up system Path var, Keeping: %newPath%`nRemoving: %removed%`n`nProceed?
    IfMsgBox No
	ExitApp
}

RegWrite REG_EXPAND_SZ,HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment,Path,%newPath%
