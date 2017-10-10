;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

global ProfilePath, LocalAppData
	, UIDSYSTEM:="S-1-5-18;s:y"
	, UIDAdministrators:="S-1-5-32-544;s:y"
EnvGet ProfilePath, USERPROFILE
EnvGet LocalAppData, LOCALAPPDATA

logsDir = %LocalAppData%\mobilmir.ru\%A_ScriptName%
backupsDest = %ProfilePath%\.Archive
packDest = %ProfilePath%\.Archive-Pack
MoveToPackTimeHorizon=
MoveToPackTimeHorizon += -90, Days

;  0 = оставить
; -n = удалить, если старше n дней
UserProfileDirs := {".oracle_jre_usage": -1
    , ".Archive": 0
    , ".Archive-Pack": 0
    , "AppData": 0
    , "Application Data": 0
    , "Contacts": 0
    , "Cookies": 0
    , "Desktop": 0
    , "Documents": 0
    , "Downloads": -31
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
Try {
    SetWorkingDir %ProfilePath%
    FileCreateDir %logsDir%
    
    If (!InStr(FileExist(backupsDest), "D")) {
	FileCreateDir %backupsDest%
	FileSetAttrib +H, %backupsDest%, 2
    }
    
    findexefunc:="findexe"
    If(IsFunc(findexefunc)) {
	Try SetACLexe := %findexefunc%(SystemDrive . "\SysUtils\SetACL.exe", "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils")
    } Else {
	SetACLexe:=SystemDrive . "\SysUtils\SetACL.exe"
    }

    ;https://autohotkey.com/boards/viewtopic.php?t=21406
    For process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId = " DllCall("GetCurrentProcessId")) {
	VarSetCapacity(var, 24, 0), vref := ComObjActive(0x400C, &var)
	process.GetOwnerSid(vref)
	;https://msdn.microsoft.com/en-us/library/aa394372.aspx
	ArchiveOwner := vref[] . ";s:y"
	vref:=""
	break
    }
    If (!ArchiveOwner)
	ArchiveOwner=%A_UserName%;s:n
    
    ;ToDo: настроить доступ к backupsDest, чтобы можно было менять
    RunWait "%SetACLexe%" -on "%backupsDest%" -ot file -actn setprot -op "dacl:p_nc;sacl:np" -actn clear -clr dacl -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc`,so" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:sc`,so" -actn ace -ace "n:%ArchiveOwner%;p:change`,FILE_DELETE_CHILD`,WRITE_DAC;i:sc" -actn ace -ace "n:%ArchiveOwner%;p:write`,read`,FILE_DELETE_CHILD`,DELETE`,WRITE_DAC;i:io`,so" -ignoreerr -silent,, Hide UseErrorLevel
    
    delList =
    moveList =
    skipList =
    For incDir, d in includeDirs {
	If (incDir = ".")
	    Loop Files, *, D
		If (UserProfileDirs.HasKey(A_LoopFileName)) {
		    If (v := UserProfileDirs[A_LoopFileName]) {
			If (v < 0) {
			    ;FileRemoveDir %A_LoopFileFullPath%, 1
			    timeHorizon=
			    timeHorizon += v, Days
			    Loop Files, %A_LoopFileFullPath%\*.*, R
				If (A_LoopFileTimeModified < timeHorizon)
				    Try
					FileDelete %A_LoopFileFullPath%
					
			    RemoveEmptyDir(A_LoopFileFullPath)
			}
		    }
		} Else { ; папки нет в списке известных
		    ; MsgBox Перемещение %A_LoopFileFullPath%
		    destPath=Downloads\%A_LoopFileName%
		    While FileExist(destPath)
			destPath=Downloads\%A_LoopFileName% (%A_Index%)
		    FileMoveDir %A_LoopFileFullPath%, %destPath%, R
		    FileAppend %A_Now% "%A_LoopFileFullPath%" → "%destPath%"`n, %logsDir%\перемещенные папки.txt
		}
	
	; для всех папок, в том числе корневой, также проверяются файлы
	CheckDirAndArchiveFiles(backupsDest, incDir, d[1], d[2], delList, moveList)
    }
    ;MsgBox 0,Список на удаление,%delList%
    ;MsgBox --skipList--`n%skipList%
    If (delList)
	FileAppend %A_Now% файлы`, удаленные из %ProfilePath%:`n%delList%`n`n,%logsDir%\список удалённых файлов.txt
    If (moveList)
	FileAppend %A_Now% файлы`, перемещенные из %ProfilePath%:`n%moveList%`n`n,%logsDir%\список перемещённых в архив файлов.txt

    SetWorkingDir %backupsDest%
    Loop Files, *, R
    {
	If (A_LoopFileTimeModified < MoveToPackTimeHorizon && A_LoopFileTimeCreated < MoveToPackTimeHorizon) {
	    FileCreateDir %packDest%\%A_LoopFileDir%
	    Menu Tray, Tip, Moving %A_LoopFileFullPath%
	    FileMove %A_LoopFileFullPath%, %packDest%\%A_LoopFileFullPath%
	}
    }
    Loop Files, *, DR
	RemoveEmptyDir(A_LoopFileFullPath)
    
} Catch e {
    Throw e
}

; настройки доступа – только чтение и удаление (если не разрешить менять папки, нет доступа для удаления файлов)
Run "%SetACLexe%" -on "%backupsDest%" -ot file -actn setprot -op "dacl:p_nc;sacl:np" -actn clear -clr dacl -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc`,so" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:sc`,so" -actn ace -ace "n:%ArchiveOwner%;p:change`,FILE_DELETE_CHILD`,WRITE_DAC;i:sc" -actn ace -ace "n:%ArchiveOwner%;p:read`,DELETE`,WRITE_DAC;i:io`,so" -ignoreerr -silent,, Hide UseErrorLevel

ExitApp

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
		currBackupFPath = %backupsDest%\%A_LoopFileFullPath%
		If (currBackupDir != lastCreatedDest) {
		    FileCreateDir %currBackupDir%
		    lastCreatedDest := currBackupDir
		}
		If (FileExist(currBackupFPath))
		    FileSetAttrib -RSH, %currBackupFPath%
		Menu Tray, Tip, Moving %A_LoopFileFullPath%
		FileMove %A_LoopFileFullPath%, %currBackupFPath%, 1
		Menu Tray, Tip
		If (ErrorLevel || FileExist(path)) {
		    Throw Exception(A_LastError, "FileMove", path)
		}
		moveList .= path . "`n"
		FileSetAttrib +R, %currBackupFPath%
		    
		FileCreateShortcut %currBackupFPath%, %A_LoopFileFullPath% (архив).lnk,,, %shortcutNote%
		If (ErrorLevel)
		    Throw Exception(ErrorLevel, "FileCreateShortcut", path)
	    }
	    ;Else skipList .= "`t" . A_LoopFileFullPath . "`n"
	}
    }
    
    If (InStr(loopOptions, "R")) {
	Loop Files, %dirPath%\*.*, D ; проверка папок, в которых остались только ссылки на архив
	{
	    currBackupFPath = %backupsDest%\%A_LoopFileFullPath%
	    If (InStr(FileExist(currBackupFPath), "D") && CleanupArchives(A_LoopFileFullPath)) {
		; если папка в архиве, а в исходном расположении остались только ярлыки на архивы – сделать ярлык на папку в архиве, почистить исходное расположение
		FileCreateShortcut %currBackupFPath%, %A_LoopFileFullPath% (архив).lnk,,, %shortcutNote%
		If (CleanupArchives(A_LoopFileFullPath, 1)) {
		    ; CleanupArchives(путь, 1) удаляет все ярлыки на архив, папки должны остаться пустыми
		    RemoveEmptyDir(A_LoopFileFullPath) ; удаление пустых папок с подпапками
		}
	    }
	}
    }
}

RemoveEmptyDir(path) {
    Loop Files, %path%\*.*, D
	RemoveEmptyDir(A_LoopFileFullPath)
    Try {
	FileRemoveDir %path%
    }
}

CleanupArchives(path, rm:=0) {
    Loop Files, %path%, R
    {
	If (!EndsWith(A_LoopFileName, " (архив).lnk")) {
	    return 0
	}
	If (rm)
	    FileDelete %A_LoopFileFullPath%
    }
    return 1
}

EndsWith(long,short) {
    return short=SubStr(long,-StrLen(short)+1)
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
