;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

; -1 = удалить
;  0 = оставить
UserProfileDirs := {".oracle_jre_usage": -1
    , ".Archive": 0
    , "AppData": 0
    , "Application Data": 0
    , "Contacts": 0
    , "Cookies": 0
    , "Desktop": 0
    , "Documents": 0
    , "Downloads": 0
    , "Favorites": 0
    , "Links": 0
    , "Local Settings": 0
    , "Mail": 0
    , "Music": 0
    , "NetHood": 0
    , "Pictures": 0
    , "PrintHood": 0
    , "Recent": 0
    , "Saved Games": 0
    , "Searches": 0
    , "SendTo": 0
    , "Videos": 0
    , "Главное меню": 0
    , "Мои документы": 0
    , "Шаблоны": 0 }
    ;NTUSER.DAT
    ;ntuser.ini
    ;ntuser.dat.LOG1
    ;ntuser.dat.LOG2
    ;NTUSER.DAT*.TM.blf
    ;NTUSER.DAT*.TMContainer*.regtrans-ms

;~ToDo: 
;Общие папки – архив без копирования ACL файла. Доступ пользователя к папке – чтение, удаление файлов (без создания и изменения). Пользователи могут открывать файлы из архива, но для изменения файлов надо скопировать или переместить их в свою папку.
;D:\Users\{Пользователь,Продавец}
;D:\Users\Public

;includeDirs: {"path": ["loop options", age]}
includeDirs := {  "." : ["", 30] ; -1 means special processing for root
		, "Desktop": ["R", 30] ; "R" means recursive
		, "Documents": ["R", 95]
		, "Downloads": ["R", 30]
		, "Pictures": ["R", 95] }

;RegRead ProfilesDirectory, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory
;profilesSubkey = SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
;Loop Reg, HKEY_LOCAL_MACHINE\%profilesSubkey%, K
;{
;    RegRead profilePath, HKEY_LOCAL_MACHINE\%profilesSubkey%\%A_LoopRegName%, ProfileImagePath
;    If (!profilePath)
;	continue
    ; ProfilesDirectory:	D:\Users
    ;					↓ – StrLen(ProfilesDirectory) + 1
    ; profilePath:		D:\Users\Продавец
    ; 					 ↑ – StrLen(ProfilesDirectory) + 2
;    If (SubStr(profilePath, 1, StrLen(ProfilesDirectory)+1) = ProfilesDirectory . "\")
;	profileName := SubStr(profilePath, StrLen(ProfilesDirectory)+2)
;    Else
;	profileName := A_LoopRegName

;Loop Files, %ProfilesDirectory%\*, D ; Loop profiles
;{
;    profilePath := A_LoopFileFullPath
    EnvGet profilePath, USERPROFILE
    If (!InStr(profilePath, "D"))
	ExitApp 1
    backupsDest = %profilePath%\.Archive
    logsDir = %profilePath%\AppData\Local\mobilmir.ru\%A_ScriptName%
    SetWorkingDir %profilePath%
    If (!InStr(backupsDest, "D")) {
	FileCreateDir %backupsDest%
	FileSetAttrib +H, %backupsDest%, 2
    }
    FileCreateDir %logsDir%
    delList =
    moveList =
    skipList =
    For incDir, d in includeDirs {
	If (incDir = ".")
	    Loop Files, *, D
		If (UserProfileDirs.HasKey(A_LoopFileName)) {
		    actn := UserProfileDirs[A_LoopFileName]
		    If (actn=-1)
			FileRemoveDir %A_LoopFileFullPath%, 1
		} Else {
		    MsgBox Перемещение %A_LoopFileFullPath%
		    destPath=Downloads\%A_LoopFileName%
		    While FileExist(destPath)
			destPath=Downloads\%A_LoopFileName% (%A_Index%)
		    FileMoveDir %A_LoopFileFullPath%, %destPath%, R
		    FileAppend %A_Now% "%A_LoopFileFullPath%" → "%destPath%"`n, %logsDir%\перемещенные папки.txt
		}
	CheckDirAndArchiveFiles(backupsDest, incDir, d[1], d[2], delList, moveList)
    }
;}

SetWorkingDir %A_ScriptDir%
;MsgBox 0,Список на удаление,%delList%
;MsgBox --skipList--`n%skipList%
If (delList)
    FileAppend %A_Now% файлы`, удаленные из %profilePath%:`n%delList%`n`n,%logsDir%\список удалённых файлов.txt
If (moveList)
    FileAppend %A_Now% файлы`, перемещенные из %profilePath%:`n%moveList%`n`n,%logsDir%\список перемещённых в архив файлов.txt

Exit

CheckDirAndArchiveFiles(ByRef backupsDest, ByRef dirPath, loopOptions, ageLimit, ByRef delList, ByRef moveList) {
    static lastCreatedDest
	, shortcutNote:="Файл не использовался долгое время и перемещён в архив. Если он Вам всё ещё нужен, переместите его из архива!"
	, ignoreRegex := FillIgnoreRegex()
	, delFilesRegex := FillDelFilesRegex()
    
    dateLimit += -ageLimit, Days ; ageLimit days prior to today
    
    Loop Files, %dirPath%\*.*, %loopOptions%
    {
	If (A_LoopFileTimeModified < dateLimit && A_LoopFileTimeCreated < dateLimit && !(A_LoopFileFullPath ~= ignoreRegex)) {
	    ;MsgBox Found %A_LoopFileFullPath%:`ndateLimit = %dateLimit%`nA_LoopFileTimeModified = %A_LoopFileTimeModified%`nA_LoopFileTimeCreated = %A_LoopFileTimeCreated%`nError: %ErrorLevel%
	    If (A_LoopFileFullPath ~= delFilesRegex) {
		FileAppend Удаление %A_LoopFileFullPath%`n, *
		FileDelete %A_LoopFileFullPath%
		If (ErrorLevel)
		    delList .= "[ERR" ErrorLevel "] "
		delList .= A_LoopFileFullPath . "`n"
	    } Else {
		;MsgBox Перемещение %A_LoopFileLongPath% в %backupsDest%\%A_LoopFileDir%
		currBackupDir = %backupsDest%\%A_LoopFileDir%
		currBackupFPath =  %backupsDest%\%A_LoopFileFullPath%
		If (currBackupDir != lastCreatedDest) {
		    FileCreateDir %currBackupDir%
		    lastCreatedDest := currBackupDir
		}
		If (FileExist(currBackupFPath))
		    FileSetAttrib -RSH, %currBackupFPath%
		FileMove %A_LoopFileFullPath%, %currBackupFPath%, 1
		If (ErrorLevel || FileExist(path)) {
		    Throw Exception(A_LastError, "FileMove", path)
		} Else {
		    moveList .= path . "`n"
		    FileSetAttrib +R, %currBackupFPath%
		    
		    FileCreateShortcut %currBackupFPath%, %A_LoopFileFullPath% (архив).lnk,,, %shortcutNote%
		    If (ErrorLevel)
			Throw Exception(ErrorLevel, "FileCreateShortcut", path)
		}
	    }
	    ;Else skipList .= "`t" . A_LoopFileFullPath . "`n"
	}
    }
}

FillIgnoreRegex() {
    ignoreFilesRegex =
	(LTrim Join
	(\.lnk$
	|\.url$
	|\\desktop\.ini$
	|^\.\\Обмен в розничных отделах\.url$
	|^\.\\ntuser\.(ini|DAT|pol|LOG)$
	|^\.\\ntuser\.dat.*$
	|^\.\\install-pwd\.txt$
	|^Documents\\Default\.rdp$)
	)
	;NTUSER\.DAT.*\.TM\.blf$
	;NTUSER\.DAT.*\.TMContainer.+\.regtrans-ms$
    return "Si)" . ignoreFilesRegex
}

FillDelFilesRegex() {
    delFilesRegex =
	(LTrim Join
	(\\\.\~lock\..*\#$
	|\\Thumbs\.db$)
	)
    return "Si)" . delFilesRegex
}
