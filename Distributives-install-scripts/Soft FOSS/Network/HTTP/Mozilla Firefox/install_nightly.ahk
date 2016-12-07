#NoEnv
#SingleInstance off

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

distpath=%A_ScriptDir%\latest-mozilla-central
distpath=%A_ScriptDir%\temp\ftp.mozilla.org\pub\mozilla.org\firefox\nightly\latest-mozilla-central

Loop %distpath%\*.win32*.exe,,1
    If A_LoopFileTimeModified > %LatestTime%
    {
	LatestTime := A_LoopFileTimeModified
	LatestDist := A_LoopFileFullPath
    }

;MsgBox %LatestDist% (%LatestTime%)
Run "%LatestDist%" /INI="%A_ScriptDir%\install_nightly.ini",,,InstallerPID

Process Wait, %InstallerPID%, 3

If ErrorLevel
    Loop
    {
	Process WaitClose, %InstallerPID%, 0.5
	If ErrorLevel
	{
	    IfWinExist Extraction Failed ahk_class #32770 ahk_pid %InstallerPID%
	    {
		WinClose
		Process Close, %InstallerPID%
		Exit 1
	    }
	} Else {
	    Break
	}
    }
