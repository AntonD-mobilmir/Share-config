#NoEnv

If A_ComputerName contains SRV
    ExitApp
SplitPath A_ScriptName, , , , ScriptNameNoExt
;NewLibreOfficeVer is from 1st space til second space
NewLibreOfficeVer := SubStr(ScriptNameNoExt,InStr(ScriptNameNoExt," ")+1)
NewLibreOfficeVer := SubStr(NewLibreOfficeVer, 1, InStr(NewLibreOfficeVer," ")-1)
reinstall := SubStr(ScriptNameNoExt, -1) = "re"

EnvGet ProgramFilesx86, ProgramFiles(x86)
If (!ProgramFilesx86)
    EnvGet ProgramFilesx86,ProgramFiles
FileGetVersion CurrLibreOfficeVersion, %ProgramFilesx86%\LibreOffice 4\program\soffice.bin
If ( CurrLibreOfficeVersion == "4.1.6.2" ) {
    FileAppend Version %CurrLibreOfficeVersion% installed`, this is stable one and it's excluded from updates. Aboring.`n,*,CP866
    Exit 0
}

EnvGet LocalAppData,LOCALAPPDATA
If (!LocalAppData)
    LocalAppData:=A_TEMP

lockFileName=%LocalAppData%\%A_ScriptName%-running.lock
distVerDiff := FileVersionsDiff(NewLibreOfficeVer, CurrLibreOfficeVersion)
If ( !reinstall && !FileExist(lockFileName) && distVerDiff <= 0 ) {
    FileAppend Version %CurrLibreOfficeVersion% already installed`, it's now newer than distributive version %NewLibreOfficeVer%. Aboring.`n,*,CP866
    Exit 0
}

If (!IsObject( lockFile:=FileOpen(lockFileName,"w-") )) {
    FileAppend Cannot open lock file "%lockFileName%"`, aborting.`n,*,CP866
    Exit 2
}

EnvGet Distributives,Distributives
LOPath=%Distributives%\Soft\Office Text Publishing\Office Suites\LibreOffice

;FileAppend Uninstalling OpenOffice.org 3.3 Pro [I-Rs]...,*
;RunWait MsiExec.exe /X{4218E1CD-CDB6-448C-8036-2871403BDE57} /q
;FileAppend Exit Error Level: %ErrorLevel%`n,*

;FileAppend Uninstalling OpenOffice.org 3.3 (ru)...,*
;RunWait MsiExec.exe /X{CCEC9577-A072-4757-A0A3-BF565FE0B8F6} /q
;FileAppend Exit Error Level: %ErrorLevel%`n,*

EnvGet logmsi,logmsi
If Not logmsi
{
    EnvGet SUScriptsStatus,SUScriptsStatus
    If Not SUScriptsStatus
	SUScriptsStatus:=A_Temp
    EnvSet logmsi,%SUScriptsStatus%\%A_ScriptName%-msiexec.log
    FileAppend SUScriptsStatus=%SUScriptsStatus%`nlogmsi=%logmsi%`n,*,CP866
}

LOLocalInstallPath=%A_Temp%\%ScriptNameNoExt%
FileAppend Copying "%LOPath%" to "%LOLocalInstallPath%"`n,*,CP866
FileCopyDir %LOPath%, %LOLocalInstallPath%, 1
If ErrorLevel
{
    FileAppend Failed copying "%LOPath%" to "%LOLocalInstallPath%"`n,*,CP866
    LOLocalInstallPath=%LOPath%
}

logfile=%A_Temp%\%A_ScriptName%.log
FileAppend Local log file: %logfile%`n,*,CP866

If (reinstall || distVerDiff < 0) { ; Downgrade?
    FileAppend Starting "%LOLocalInstallPath%\reinstall.ahk"`n,*,CP866
    RunWait %comspec% /C ""%A_AhkPath%" /ErrorStdOut "%LOLocalInstallPath%\reinstall.ahk" >>"%logfile%"",%LOLocalInstallPath%
} Else {
    FileAppend Starting "%LOLocalInstallPath%\install.ahk"`n,*,CP866
    EnvSet logfile,%logfile%
    RunWait %comspec% /C ""%A_AhkPath%" /ErrorStdOut "%LOLocalInstallPath%\install.ahk" >>"`%logfile`%" 2>&1",%LOLocalInstallPath%
}
FinalError=%ErrorLevel%
FileRead FullLog, %logfile%
FileAppend %FullLog%`n,*,CP866
FileAppend Installer Error Level: %FinalError%`n,*,CP866
If Not FinalError
    FileDelete %logfile%

lockFile.Close()
FileAppend Removing lock file…`n,*,CP866
FileDelete %lockFileName%

FileAppend `nCleanup…`n,*,CP866
FileRemoveDir %A_AppData%\LibreOffice\4\user\extensions, 1
FileRemoveDir %A_AppData%\LibreOffice\4\user\uno_packages, 1
FileRemoveDir %LOLocalInstallPath%, 1

Exit %FinalError%

FileVersionsDiff(ver1, ver2) {
    StringSplit ver1a, ver1, .
    StringSplit ver2a, ver2, .
    
    Loop %ver1a0%
    {
	ver1pt := ver1a%A_Index%
	ver2pt := ver2a%A_Index%
	If Not ver1pt
	    ver1pt=0
	If Not ver2pt
	    ver2pt=0
	If (ver1pt == ver2pt)
	    continue
	return (ver1pt-ver2pt) << (8 * (4-A_Index))
    }
    
    return ver1pt-ver2pt
}
