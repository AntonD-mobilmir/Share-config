#NoEnv
SetFormat IntegerFast, D
FreeSpaceLowMarginMB := 3072
CBSlogMaxSizeMB := 512

;to get extensions:
;1. regex replace "^([^\.]+)$" → ""
;2. regex replace ".+\.([^\.]+)$" → "\1"

EnvGet SystemDrive, SystemDrive

global System32,SystemDrive
System32=%A_WinDir%\System32
IfExist %A_WinDir%\SysNative
    System32 = %A_WinDir%\SysNative
    

If (CheckAndLogFreeSpace(A_WinDir) < FreeSpaceLowMarginMB) {
; not in win below 7   RunWait dism /online /cleanup-image /spsuperseded
; requires confirmation    RunWait vssadmin Delete Shadows /All
    Loop Files, %A_WinDir%\Logs\CBS\*.*, D
	FileRemoveDir %A_LoopFileFullPath%, 1
    FileDelete %A_WinDir%\Logs\CBS\*.*
    CallCompact(A_WinDir . "\Logs\CBS")
    Loop Files, %A_WinDir%\Temp\*.*, D
	FileRemoveDir %A_LoopFileFullPath%, 1
    FileDelete %A_WinDir%\Temp\*.*
    
    CheckAndLogFreeSpace(A_WinDir,"after cleanup of %WinDir%\Temp and %WinDir%\Logs\CBS")
    
    CBSlog=%A_WinDir%\Logs\CBS\CBS.log
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

If (CheckAndLogFreeSpace(A_ProgramFiles) < FreeSpaceLowMarginMB) {
    ; – закрывает explorer.exe и перезапускает от администратора – RunWait %comspec% /C "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\cleanup\BleachBit-auto.cmd"
    
    CallCompact(A_ProgramFiles . "\K-Lite Codec Pack")
    CallCompact(A_ProgramFiles . "\Adobe","*.api *.dll")
    CallCompact(A_ProgramFiles . "\Canon")
    CallCompact(A_ProgramFiles . "\foobar2000")
    CallCompact(A_ProgramFiles . "\Google","*. *.exe *.dll *.nexe *.bdic")
    Loop Files, %A_ProgramFiles%\LibreOffice *, D
	CallCompact(A_LoopFileFullPath,"*.aff *.bmp *.class *.dat *.db *.db_ *.dct *.dic *.dll *.exe *.ht *.html *.idx *.js *.key *.py *.pyd *.txt *.ui *.xcd *.xcu *.xml *.xsl")
;    CallCompact(A_ProgramFiles . "\LibreOffice 4","*.aff *.bmp *.class *.dat *.db *.db_ *.dct *.dic *.dll *.exe *.ht *.html *.idx *.js *.key *.py *.pyd *.txt *.ui *.xcd *.xcu *.xml *.xsl")
    CallCompact(A_ProgramFiles . "\Java")
    CallCompact(A_ProgramFiles . "\ATI Technologies")
    CallCompact(A_ProgramFiles . "\NVIDIA Corporation")
    CallCompact(A_ProgramFiles . "\Microsoft Office")
    CallCompact(A_ProgramFiles . "\Total Commander")
    CallCompact(A_ProgramFiles . "\Notepad2")
    CallCompact(A_ProgramFiles . "\Movie Maker")
    CallCompact(A_ProgramFiles . "\Outlook Express")
    CallCompact(A_ProgramFiles . "\Skype")
    CallCompact(A_ProgramFiles . "\Small CD-Writer")
    
    CheckAndLogFreeSpace(A_ProgramFiles,"after ProgramFiles compression")
    Defrag(A_ProgramFiles)
    CheckAndLogFreeSpace(A_ProgramFiles,"after defrag")
}

If (CheckAndLogFreeSpace(A_WinDir) < FreeSpaceLowMarginMB) {
    CallCompact(A_WinDir . "\assembly")
    CallCompact(A_WinDir . "\ie8")
    CallCompact(A_WinDir . "\ie8updates")
    CallCompact(A_WinDir . "\inf")
    CallCompact(A_WinDir . "\Microsoft.NET")
    CallCompact(A_WinDir . "\WinSxS")
    CallCompact(A_WinDir . "\Installer")
    CallCompact(A_WinDir . "\pchealth")
    Loop %A_WinDir%\$*, 2
	RunWait compact /c /i /s "%A_LoopFileFullPath%",,UseErrorLevel

    CheckAndLogFreeSpace(A_WinDir,"after compression of Windows dirs")
    Defrag(A_WinDir)
    CheckAndLogFreeSpace(A_ProgramFiles,"after defrag")
}

If (CheckAndLogFreeSpace(A_WinDir) < FreeSpaceLowMarginMB) {
; Win7+		RunWait dism /online /cleanup-image /spsuperseded
; interactive	RunWait vssadmin Delete Shadows /All
    FileAppend %A_Now% Emptying SoftwareDistribution\Download`n, *, CP1
    EnvGet ConfigDir, ConfigDir
    RunWait %comspec% /C "%ConfigDir%_Scripts\cleanup\Empty SoftwareDistribution_Download.cmd" Exit,,UseErrorLevel
    FileAppend %A_Now% Running Clean Manager`n, *, CP1
    RunWait %comspec% /C "%ConfigDir%_Scripts\cleanup\cleanmgr-full.cmd",,UseErrorLevel
    
    ; compacted above CallCompact(A_WinDir . "\Logs\CBS")
    CallCompact(A_WinDir . "\assembly")
    CallCompact(A_WinDir . "\ie8")
    CallCompact(A_WinDir . "\ie8updates")
    CallCompact(A_WinDir . "\inf")
    CallCompact(A_WinDir . "\Microsoft.NET")
    CallCompact(A_WinDir . "\WinSxS")
    CallCompact(A_WinDir . "\Installer")
    CallCompact(A_WinDir . "\pchealth")
    Loop %A_WinDir%\$*, 2
	CallCompact(A_LoopFileFullPath)

    Defrag(A_WinDir)

    CheckAndLogFreeSpace(A_WinDir,"after compression")
}

;If (CheckAndLogFreeSpace(SystemDrive) < FreeSpaceLowMarginMB) {
;    FileAppend Scheduling chkdsk for %SystemDrive%, *, CP1
;    Run %comspec% /C "echo y | chkdsk %SystemDrive% /f /x",,UseErrorLevel
;}

Exit

CheckAndLogFreeSpace(path, textnote="") {
    DriveSpaceFree FreeSpace, %path%
    FileAppend %A_Now% FreeSpace for "%path%" %textnote%: %FreeSpace% MB`n, *, CP1
    return FreeSpace
}

CallCompact(path, mask="*.*") {
    IfExist %path%\.
    {
	FileAppend Calling Compact for %mask% in %path%`n, *, CP1
	RunWait %System32%\compact.exe /c /i /s %mask%, %path%,,UseErrorLevel
    }
}

Defrag(path) {
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
