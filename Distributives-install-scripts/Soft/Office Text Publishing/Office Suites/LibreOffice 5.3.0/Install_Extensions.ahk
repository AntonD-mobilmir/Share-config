#NoEnv
#SingleInstance ignore

EnvGet LogPath,log
If Not LogPath
    LogPath=%A_TEMP%\LibreOffice_Install_Extensions.log

ComspecLogSuffix=>"%LogPath%"

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

Process Exist, soffice.bin
If ErrorLevel
{
    FileAppend soffice.bin runnning`, will not try to install shared extensions!, *
    If RunInteractiveInstalls!=0
	MsgBox 48, LibreOffice Extensions Installing error, soffice.bin runnning`, will not try to install shared extensions!, 30
    ExitApp
}

EnvGet ProgramFiles_x86,ProgramFiles(x86)
If ProgramFiles_x86
    LibreOfficePath=%ProgramFiles_x86%\LibreOffice *
Else
    LibreOfficePath=%ProgramFiles%\LibreOffice *

Loop %LibreOfficePath%, 2 ; Only folders
{
    unopkgexe=%A_LoopFileFullPath%\program\unopkg.com
    LibreOfficePath:=A_LoopFileFullPath
    IfExist %unopkgexe%
	break
}

Loop ..\LibreOffice\AddOns\*.oxt
{
    RunWait %comspec% /C "ECHO y|"%unopkgexe%" add --shared -v -f -s "%A_LoopFileLongPath%" %ComspecLogSuffix%",,Hide UseErrorLevel
    If ErrorLevel
	Result=Failure`, Error Level=%ErrorLevel%
    Else
	Result=Success
    FileAppend Installing extension %A_LoopFileName% %Result%`n, *
    FileAppend Installing extension %A_LoopFileName% %Result%`n, %LogPath%
}
