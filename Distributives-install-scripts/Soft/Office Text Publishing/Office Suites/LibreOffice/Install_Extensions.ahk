;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore

EnvGet LogPath,log
If Not LogPath
    LogPath=%A_TEMP%\LibreOffice_Install_Extensions.log

path_LO_bin := Find_LO_program_dir()
unopkgexe=%path_LO_bin%\unopkg.com

If (A_IsAdmin) {
    shared=--shared
    Process Exist, soffice.bin
    If (ErrorLevel) {
	FileAppend soffice.bin runnning`, will not try to install shared extensions!, *
	If RunInteractiveInstalls!=0
	    MsgBox 48, LibreOffice Extensions Installing error, soffice.bin runnning`, will not try to install shared extensions!, 30
	ExitApp
    }
}

For i, extDir in [ A_ScriptDir "\AddOns"
	         , A_ScriptDir "\..\LibreOffice\AddOns"
	         , A_ScriptDir "\..\..\..\..\Soft FOSS\Office Text Publishing\Office Suites\LibreOffice\AddOns" ]
    Loop Files, %extDir%\*.oxt
    {
	FileAppend Installing extension %A_LoopFileName%%A_Tab%, *, CP1
	SetTimer ShowCmdPIDWindow, -30000
	RunWait %comspec% /C "ECHO y|"%unopkgexe%" add %shared% -v -f -s "%A_LoopFileLongPath%" >"%LogPath%" 2>&1", %path_LO_bin%, Hide UseErrorLevel, cmdPID
	unopkgexeErrLevel := ErrorLevel
	SetTimer ShowCmdPIDWindow, Off
	If (unopkgexeErrLevel)
	    Result=Failure`, Error Level=%unopkgexeErrLevel%
	Else
	    Result=Success
	FileAppend %Result%`n, *, CP1
	FileAppend Installing extension %A_LoopFileName% %Result%`n, %LogPath%
    }

ShowCmdPIDWindow() {
    global cmdPID
    WinShow ahk_pid %cmdPID%
}

#include %A_LineFile%\..\Find_LO_program_dir.ahk
