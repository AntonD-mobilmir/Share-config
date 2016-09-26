#NoEnv
#SingleInstance ignore
Menu Tray, Tip, Uninstalling Microsoft Security Essentials

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

GroupAdd MSSEUninstaller, Microsoft Security Essentials ahk_class MorroSetupWindow

SetRegView 64
RegRead NativeProgramFiles, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion, ProgramFilesDir
IfExist %NativeProgramFiles%\Microsoft Security Client\Setup.exe
{
    RunWait "%NativeProgramFiles%\Microsoft Security Client\Setup.exe" /x
    WinWait ahk_group MSSEUninstaller,,30
    If (ErrorLevel!=1) { ; ErrorLevel is set to 1 if the command timed out or 0 otherwise
	ControlClick Button1 ; Удалить
	WinWait ahk_group MSSEUninstaller, Готово, 300
;	ControlClick Готово
	ControlClick Button1 ; Готово
	WinWaitClose,,,600 ; Waiting for that window to close
    }
} Else {
    ; Less correct way, keeps Uninstall entry untouched, it must be removed before MSSE can be reinstalled
    RunWait MsiExec.exe /X{23F2C78C-E131-4CA0-8F84-3473FB7728BA} /QN
}

Process WaitClose, MsMpEng.exe
Process WaitClose, msseces.exe

FileRemoveDir %A_AppDataCommon%\Microsoft\Microsoft Security Client\Support, 1
