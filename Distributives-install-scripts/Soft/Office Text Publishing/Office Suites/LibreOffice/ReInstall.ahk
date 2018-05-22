#NoEnv

if not A_IsAdmin
{
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

scriptpid := DllCall("GetCurrentProcessId")
SplashTextOn,,,Переустановка LibreOffice, Этап 1 из 2.`nУдаление.
IfWinExist ahk_pid %scriptpid% ;last window found now = splashtext
    WinSet AlwaysOnTop, Off
RunWait "%A_AhkPath%" "%A_ScriptDir%\Uninstall and Cleanup.ahk" /q, %A_ScriptDir%, UseErrorLevel
ControlSetText Static1, Этап 2 из 2.`nПовторная установка.
RunWait "%A_AhkPath%" "%A_ScriptDir%\install.ahk", %A_ScriptDir%, UseErrorLevel
Exit ErrorLevel
