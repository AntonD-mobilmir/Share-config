;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

global System32,SystemDrive,LocalAppData
EnvGet SystemDrive, SystemDrive
EnvGet LocalAppData, LOCALAPPDATA
EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server
SetFormat IntegerFast, D
FreeSpaceLowMarginMB := 5120 ; обновление KB4038782 отказывалось устанавливаться, когда на системном диске было свободно меньше 4 гигабайт
CBSlogMaxSizeMB := 512

;to get extensions:
;1. regex replace "^([^\.]+)$" → ""
;2. regex replace ".+\.([^\.]+)$" → "\1"

For i, System32 in [ SystemRoot "\SysNative", SystemRoot "\System32" ]
    If (InStr(FileExist(System32), "D"))
	break

; Отметить текущий запуск, чтобы скрипт не перезапускался при каждой загрузке, если место освободить не удаётся
flagFName := A_AppDataCommon "\mobilmir.ru\" A_ScriptName ".flag"
Loop Files, %flagFName%
{
    age := ""
    age -= A_LoopFileTimeModified, Days
    If (age < 3) {
        FileAppend %A_Now% Previous run only %age% days ago`, terminating.`n, *, CP1
        ExitApp
    }
}
FileOpen(flagFName, 2).Close()

If (GetAndLogFreeSpace(SystemRoot) < FreeSpaceLowMarginMB) {
    ; not in win below 7   RunWait dism /online /cleanup-image /spsuperseded
    ; requires confirmation    RunWait vssadmin Delete Shadows /All
    Loop Files, %SystemRoot%\Logs\CBS\*.*, D
	FileRemoveDir %A_LoopFileFullPath%, 1
    FileDelete %SystemRoot%\Logs\CBS\*.*
    CallCompact(SystemRoot . "\Logs\CBS")
    Loop Files, %SystemRoot%\Temp\*.*, D
	FileRemoveDir %A_LoopFileFullPath%, 1
    FileDelete %SystemRoot%\Temp\*.*
    
    GetAndLogFreeSpace(SystemRoot, "after cleanup of %WinDir%\Temp and %WinDir%\Logs\CBS")
    
    CBSlog=%SystemRoot%\Logs\CBS\CBS.log
    FileGetSize sizeCBSlogMB, CBSlog, M
    FileAppend %A_Now% Size of %CBSlog% is %sizeCBSlogMB% MB`, limit is %CBSlogMaxSizeMB% MB`, , *, CP1
    If (sizeCBSlogMB > CBSlogMaxSizeMB) {
	; MOVEFILE_DELAY_UNTIL_REBOOT = 0x4
	If (!DllCall("MoveFileEx","str",CBSlog,"uint",0,"uint",0x4) ) {
	    FileAppend error %A_LastError% scheduling removal`n, *, CP1
	} Else {
	    FileAppend scheduled removal.`n,*,CP1
	}
    } Else {
	FileAppend keeping.`n,*,CP1
    }
}

If (GetAndLogFreeSpace(A_AppDataCommon) < FreeSpaceLowMarginMB) {
    Loop Files, %A_AppDataCommon%\Adobe\ARM\*.msi
        If (UninstallMSI(A_LoopFileFullPath))
            FileDelete %A_LoopFileFullPath%
    GetAndLogFreeSpace(A_AppDataCommon, "after """ A_AppDataCommon "\Adobe\ARM\*.msi"" uninstalling")
    FileRemoveDir %A_AppDataCommon%\Adobe\ARM, 1
    GetAndLogFreeSpace(A_AppDataCommon, "after """ A_AppDataCommon "\Adobe\ARM"" removal")
    
    For i, subDir in [ "Microsoft\Windows\Power Efficiency Diagnostics"
                     , "Package Cache" ] {
        CallCompact(A_AppDataCommon "\" subDir)
        GetAndLogFreeSpace(A_AppDataCommon, "after """ A_AppDataCommon . subDir """ compacting")
    }
    
}

If (GetAndLogFreeSpace(SystemDrive) < FreeSpaceLowMarginMB && InStr(FileExist(SystemDrive . "\RecoveryImage\Drivers"), "D") ) {
    CallCompact(SystemDrive . "\RecoveryImage\Drivers")
    GetAndLogFreeSpace(SystemDrive, "after """ SystemDrive "\RecoveryImage\Drivers"" compression")
}

If (GetAndLogFreeSpace(A_ProgramFiles) < FreeSpaceLowMarginMB) {
    ; – закрывает explorer.exe и перезапускает от администратора – RunWait %comspec% /C "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\cleanup\BleachBit-auto.cmd"

    For i, dirProgFiles in GetProgramFilesDirs()
        If (FileExist(ClickToRunsUpdatesDir := dirProgFiles "\Common Files\Microsoft Shared\ClickToRun\Updates")) {
            FileRemoveDir %ClickToRunsUpdatesDir%, 1
            GetAndLogFreeSpace(SystemDrive, "after """ ClickToRunsUpdatesDir """ removal")
        }
    
    For i, compactArgs in [ "K-Lite Codec Pack"
                            , "Common Files\Microsoft Shared\ClickToRun"
			    , ["Adobe","*.api *.dll"]
			    , "Canon"
			    , "foobar2000"
			    , ["Google","*. *.exe *.dll *.nexe *.bdic"]
			    , ["LibreOffice *","*.aff *.bmp *.class *.dat *.db *.db_ *.dct *.dic *.dll *.exe *.ht *.html *.idx *.js *.key *.py *.pyd *.txt *.ui *.xcd *.xcu *.xml *.xsl"]
			    , "Java"
			    , "ATI Technologies"
			    , "NVIDIA Corporation"
			    , "Microsoft Office"
			    , "Total Commander"
			    , "Notepad2"
			    , "Movie Maker"
			    , "Outlook Express"
			    , "Skype"
			    , "Small CD-Writer"] {
	If (IsObject(compactArgs))
	    CallCompactProgramFiles(compactArgs*)
	Else
	    CallCompactProgramFiles(compactArgs)
    }

    GetAndLogFreeSpace(A_ProgramFiles, "after ProgramFiles compression")
    Defrag(A_ProgramFiles)
    GetAndLogFreeSpace(A_ProgramFiles, "after defrag")
}

If (GetAndLogFreeSpace(SystemRoot) < FreeSpaceLowMarginMB) {
    For i, subdir in [ "assembly" , "ie8" , "ie8updates" , "inf" , "Microsoft.NET" , "WinSxS" , "Installer" , "pchealth", "$*" ]
	CallCompact(SystemRoot "\" subdir)
    
    GetAndLogFreeSpace(SystemRoot, "after compression of Windows subdirs")
    Defrag(SystemRoot)
    GetAndLogFreeSpace(A_ProgramFiles, "after defrag")
}

If (GetAndLogFreeSpace(SystemRoot) < FreeSpaceLowMarginMB) {
    ; Win7+		RunWait dism /online /cleanup-image /spsuperseded
    ; interactive	RunWait vssadmin Delete Shadows /All
    FileAppend %A_Now% Emptying SoftwareDistribution\Download`n, *, CP1
    EnvGet ConfigDir, ConfigDir
    RunWait %comspec% /C "%ConfigDir%_Scripts\cleanup\Empty SoftwareDistribution_Download.cmd" Exit,,UseErrorLevel
    FileAppend %A_Now% Running Clean Manager`n, *, CP1
    RunWait %comspec% /C "%ConfigDir%_Scripts\cleanup\cleanmgr-full.cmd",,UseErrorLevel
    
    GetAndLogFreeSpace(SystemRoot,"after cleanup scripts")
    Defrag(SystemRoot)
    GetAndLogFreeSpace(SystemRoot,"after defrag")
}

Exit

GetAndLogFreeSpace(ByRef path, ByRef textnote := "") {
    DriveSpaceFree FreeSpace, %path%
    FileAppend %A_Now% FreeSpace for "%path%" %textnote%: %FreeSpace% MB`n, *, CP1
    return FreeSpace
}

GetProgramFilesDirs() {
    static oProgramFiles := ""
    If (!IsObject(oProgramFiles)) {
	If (A_Is64bitOS) {
	    EnvGet ProgramFilesx86, ProgramFiles(x86)
	    EnvGet ProgramFiles64bit, ProgramW6432
	    oProgramFiles := [ProgramFilesx86, ProgramFiles64bit]
	} Else
	    oProgramFiles := [A_ProgramFiles]
    }
    return oProgramFiles
}

CallCompactProgramFiles(ByRef subdir, ByRef masks := "") {
    For i, baseDir in GetProgramFilesDirs()
	CallCompact(baseDir "\" subdir, masks)
}

CallCompact(ByRef path, ByRef masks := "") {
    global System32
    static ArgsCompact := ""
    If (!ArgsCompact)
	ArgsCompact := "/C /I " . (A_OSVersion > "10." ? "/EXE:LZX " : "")
    
    If (InStr(path, "*") || InStr(path, "?")) {
	Loop Files, %path%, D
	    CallCompact(A_LoopFileLongPath, masks)
    } Else If (InStr(FileExist(path), "D")) {
	FileAppend Calling Compact for %masks% in %path%`n, *, CP1
	RunWait %System32%\compact.exe %ArgsCompact% /S:"%path%" %masks%, %A_Temp%, Min UseErrorLevel
    } Else {
	FileAppend Compacting %path%%masks%`n, *, CP1
	RunWait %System32%\compact.exe %ArgsCompact% "%path%%masks%", %A_Temp%, Min UseErrorLevel
    }
    
    GetAndLogFreeSpace(path)
}

Defrag(ByRef path) {
    If (SubStr(path, 2, 1)==":") {
	defragDrive := SubStr(path, 1, 2)
	FileAppend %A_Now% Running defrag on %defragDrive%`n, *, CP1
	
	If A_WinVer in WIN_XP, WIN_VISTA
	    RunWait "%System32%\defrag.exe" -f %defragDrive%,,UseErrorLevel
	Else If A_WinVer in WIN_7
	    RunWait "%System32%\defrag.exe" %defragDrive%,,UseErrorLevel
	Else ; Win8 or higher
	    RunWait "%System32%\defrag.exe" %defragDrive% /O,,UseErrorLevel
    }
}

UninstallMSI(path) {
    Loop
    {
        RunWait "%A_WinDir%\System32\MsiExec.exe" /X"%path%" /qn /norestart,,UseErrorLevel
        If (ErrorLevel) {
            If (ErrorLevel==1618) { ; Another install is currently in progress
                FileAppend %A_Now% Error %ErrorLevel% uninstalling %path%: another install currently in progress`, waiting 30 s [try %A_Index%]`n, *, CP1
                Sleep 30000
                continue
            } Else If (ErrorLevel!=3010) { ;3010: restart required
                FileAppend %A_Now% Error %ErrorLevel% uninstalling %path%
                return 0
            }
        }
        return %A_Index%
    }
}
