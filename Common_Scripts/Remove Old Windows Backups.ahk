;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
SetRegView 64
SetFormat IntegerFast, D

; Win8+ File History
;https://msdn.microsoft.com/en-us/library/hh829770%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
;command must run under user account: Run FhManagew.exe -cleanup 0 -quiet (it leaves last version only)

; Win7 backups
RegRead BackupDrive, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup\ScheduleParams\TargetDevice, PresentableName
FileAppend BackupDrive: %BackupDrive%, *
If (!FileExist(BackupDrive . "\MediaID.bin")) {
    FileAppend %A_Space%does not contain "MediaID.bin". Terminating.`n, *
    Exit 128
}
RegRead Hostname, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
SetWorkingDir %BackupDrive%%Hostname%
If (ErrorLevel) {
    FileAppend `, but "%BackupDrive%%Hostname%" not accessible (cannot change working directory). Terminating.`n, *
    Exit 128
}
FileAppend `, processing...`n, *

BackupSetsSizes := Object()
BackupSetsNames =
MaxBackupSize := 0

;IfExist MediaID.bin
Loop Files, Backup Set *, D
{
    CurrentBackupSetSize:=FolderGetSize(A_LoopFileFullPath)/1048576 ; DriveSpaceFree, which is used for comparison everywhere, returns megabytes
    FileAppend `tFound %A_LoopFileName% [%CurrentBackupSetSize% MB]`n, *
    If (CurrentBackupSetSize > MaxBackupSize)
	MaxBackupSize:=CurrentBackupSetSize
    BackupSetsSizes[A_LoopFileName]:=CurrentBackupSetSize
    BackupSetsNames .= A_LoopFileName . "`n"
}

DriveSpaceFree SpaceFree, .
FileAppend `t* MaxBackupSize: %MaxBackupSize% MB`, free space: %SpaceFree% MB. Removing oldest until free space is at least 2x MaxBackupSize.`n, *
Sort BackupSetsNames, N P12 ; "Backup Set " length is 11, next char is 12th
;it's possible to sort by sizes using F in Sort and function(name1,name2) which compares BackupSetsSizes(name1) and BackupSetsSizes(name2)

While (MaxBackupSize*2) > SpaceFree
{
    StringGetPos NameDelimeterPos, BackupSetsNames, `n
    If (ErrorLevel || A_Index > 10)
	Break
    StringLeft BackupSetName, BackupSetsNames, NameDelimeterPos
    StringMid BackupSetsNames, BackupSetsNames, NameDelimeterPos+2
    SpaceFree+=BackupSetsSizes[BackupSetName]
    
    BackupSetSize:=BackupSetsSizes[BackupSetName]
    TrayTip Removing Old Windows Backups, Removing "%BackupSetName%"`nnew SpaceFree=%SpaceFree%`n`n(BackupSetName="%BackupSetName%"; BackupSetSize=%BackupSetSize%)
    FileAppend `tRemoving "%BackupSetName%" (BackupSetSize=%BackupSetSize%)`, new SpaceFree=%SpaceFree%`n, *
    FileRemoveDir %BackupSetName%, 1
}
DriveSpaceFree SpaceFreeAfter, .
FileAppend `tDone. Current free space %SpaceFreeAfter%`, expected (calculated): %SpaceFree%`n, *

Exit

FolderGetSize(path) {
    FolderSize = 0
    Loop Files, %path%\*.*, R
	FolderSize += %A_LoopFileSize%
    return FolderSize
}
