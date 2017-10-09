;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

dbBaseDir := "D:\dealer.beeline.ru"
dbBinDir  := dbBaseDir . "\bin"
ocxFName  := "criacx.ocx"

dbocx     := dbBinDir . "\" . ocxFName
sidAuthenticatedUsers:="*S-1-5-11"

EnvGet SystemRoot,SystemRoot
System3232bit := A_WinDir . "\SysWOW64"
If (!FileExist(regsvr32exe . ""))
    System3232bit := A_WinDir . "\System32"

regsvr32exe = %System3232bit%\regsvr32.exe

If (!FileExist(dbocx) && !FileExist(System3232bit . "\" . ocxFName) && !FileExist(dbBaseDir . "\" . criacx.cab))
    ExitApp 1

FileDelete %dbBaseDir%\criacx.cab

FileGetTime cabDate, %dbBaseDir%\bin\criacx.cab
Echo("Modify date of " . dbBaseDir . "\bin\criacx.cab = " . cabDate)

If (FileExist(System3232bit . "\" . ocxFName)) {
    FileGetTime ocxDate, %System3232bit%\%ocxFName%
    Echo("Modify date of """ . System3232bit . "\" . ocxFName . """ = " . ocxDate . " – unregistering and removing")

    If(FileExist(System3232bit . "\" . ocxFName)) {
	Echo(ConRun(regsvr32exe . " /u /s """ . System3232bit . "\" . ocxFName . """") . "`nregsvr32 unregister ExitCode: " . ProgramExitCode)
	FileDelete %System3232bit%\criacx.hlp
	FileDelete %System3232bit%\criacx.inf
	FileDelete %System3232bit%\%ocxFName%
    }	
}

If (FileExist(dbocx)) {
    FileGetTime ocxDate, %dbocx%
    Echo("Modify date of """ . dbocx . """ = " . ocxDate)
}

Echo(ConRun("""" SystemRoot "\System32\schtasks.exe"" /Delete /TN ""mobilmir.ru\update dealer.beeline.ru criacx.ocx"") . "`nschtasks ExitCode: " . ProgramExitCode)
Echo(ConRun("""" SystemRoot "\System32\icacls.exe"" """ . dbocx . """ /grant """ . sidAuthenticatedUsers . ":RX""", dbBinDir) . "`nicacls.exe ExitCode: " . ProgramExitCode)
Echo(ConRun(regsvr32exe . " /u /s """ . dbocx . """") . "`nregsvr32 ExitCode: " . ProgramExitCode)

FileDelete %dbocx%
Echo((Errorlevel ? "Error deleting" : "Deleted") " " dbocx)

EnvGet configDir, configDir
Run "%A_AhkPath%" /ErrorStdOut "%configDir%\_Scripts\cleanup\Apps\clean dealer.beeline.ru dir.ahk",, UseErrorLevel

ExitApp

Echo(text) {
    global logfile
    FileAppend %text%`n,*
    If logfile
        FileAppend %text%`n,%logfile%
}

ConRun(command,workdir="") {
    global ProgramExitCode, log
    Random rand, 00000, 99999
    tmpfilename := A_Temp . "\con" . SubStr("00000" . rand, -4) . ".tmp"
    cmdLine=%comspec% /C "%command% >"%tmpfilename%" 2>&1"
    RunWait %cmdLine%,%workdir%,UseErrorLevel
;    MsgBox tmpfilename: %tmpfilename%`nErrorLevel: %ErrorLevel%
    If (ErrorLevel=="ERROR")
	Throw Exception(A_LastError, "ConRun → RunWait", cmdLine)
    ProgramExitCode:=ErrorLevel
    FileRead output, *P866 %tmpfilename%
    FileDelete %tmpfilename%
    return % output
}
