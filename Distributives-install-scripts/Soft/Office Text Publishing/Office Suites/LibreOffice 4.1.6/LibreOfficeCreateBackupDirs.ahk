#NoEnv
#ErrorStdOut

RegRead ProfilesDirectoryReg, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory

VarSetCapacity(ProfilesDirectory,65536)
nRC := DllCall("ExpandEnvironmentStrings", "str", ProfilesDirectoryReg, "str", ProfilesDirectory, "int", 65535, "Cdecl int")
;MsgBox ProfilesDirectory=%ProfilesDirectory%`nnRC=%nRC%

If ProfilesDirectory
    IfExist %ProfilesDirectory%
	Loop %ProfilesDirectory%\*, 2
	    CheckAndCreateTwoBackupDirs(A_LoopFileLongPath)

IfExist C:\Documents and Settings
    Loop C:\Documents and Settings\*, 2
	CheckAndCreateTwoBackupDirs(A_LoopFileLongPath)

IfExist c:\Users
    Loop c:\Users\*, 2
	CheckAndCreateTwoBackupDirs(A_LoopFileLongPath)

IfExist d:\Users
    Loop d:\Users\*, 2
	CheckAndCreateTwoBackupDirs(A_LoopFileLongPath)

CreateDirAndLog(dir) {
    FileCreateDir %dir%
    FileAppend Creating "%dir%" Result %ErrorLevel%`n, *
}

CheckAndCreateTwoBackupDirs(dest) {
    SplitPath dest, BaseName
    If BaseName in LogicDaemon,All Users,Public,Все пользователи,LocalService,NetworkService,NTP,Install
	return
    CreateDirAndLog(dest . "\Application Data\LibreOffice\3\user\backup")
    CreateDirAndLog(dest . "\Application Data\LibreOffice\4\user\backup")
}
