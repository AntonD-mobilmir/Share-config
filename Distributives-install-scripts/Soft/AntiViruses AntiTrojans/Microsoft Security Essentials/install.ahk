#NoEnv
#SingleInstance off
Menu Tray, Tip, Installing Microsoft Security Essentials

if not A_IsAdmin
{
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

If A_OSVersion in WIN_7,WIN_VISTA
{
    If (A_Is64bitOS) {
	MSSEInstVer=64bit
	mpamfeVer=x64-glb\mpam-fex64.exe
    } Else {
	MSSEInstVer=32bit
	mpamfeVer=x86-glb\mpam-fe.exe
    }
} Else {
    Exit
}

RunWait "%A_ScriptDir%\%MSSEInstVer%\mseinstall.exe" /s /runwgacheck /o
;IfExist "%A_ScriptDir%\%MSSEInstVer%\mpam-fe.exe"
;    Run "%A_ScriptDir%\%MSSEInstVer%\mpam-fe.exe" /s, %A_ScriptDir%\%MSSEInstVer%
IfExist %A_ScriptDir%\..\..\..\Updates\Windows\wsusoffline\msse\%mpamfeVer%
    Run "%A_ScriptDir%\..\..\..\Updates\Windows\wsusoffline\msse\%mpamfeVer%" /s
