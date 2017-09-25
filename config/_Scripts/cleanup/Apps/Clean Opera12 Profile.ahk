;скрипт сброса профиля Opera (Local и Roaming, кроме нескольких файлов, с сохранением [Personal Info])
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

LocalAppData := GetKnownFolder("LocalAppData")
LocalAppDataLow := GetKnownFolder("LocalAppDataLow")

Loop %A_AppData%\Opera\*,2 ; For each Opera config subdirectory
{
    BackupDir=%A_TEMP%\%A_LoopFileName%.%A_Now%
    MsgBox 35, Очистка профилей Opera, Очистить "%A_LoopFileFullPath%"?`n`nЗакладки`, быстрый набор`, заметки`, настройки поиска и сохранённые пароли останутся.
    IfMsgBox Cancel
	Exit
    
    IfMsgBox No
	Continue

    Loop {
	Process Close, opera.exe
    } Until !ErrorLevel
	
    FileMoveDir %A_LoopFileFullPath%, %BackupDir%
    If ErrorLevel
	MsgBox Can't move away profile to do a cleanup:`n%A_LoopFileFullPath%`nto`n%BackupDir%
    Else
	Try {
	    FileCreateDir %A_LoopFileFullPath%
	} Catch e {
	    MsgBox % "Problem creating new profile dir:`n" . e.What . ": " . e.Message . " (" . e.Extra . ")"
	}

	Try {
	    ;Read and Write To New File section [Personal Info] from Roaming\Opera\Opera\operaprefs.ini 
	    FileAppend % "[Personal Info]`n" . IniReadSectionUnicode(BackupDir . "\operaprefs.ini","Personal Info"), %A_LoopFileFullPath%\operaprefs.ini
	} Catch e {
	    MsgBox % "Problem copying Personal Info:`n" . e.What . ": " . e.Message . " (" . e.Extra . ")"
	}

	;CopyToNewProfile Roaming\Opera\Opera\
		;bookmarks.adr
		;notes.adr
		;search.ini
		;speeddial.ini
		;wand.dat
	FileCopy %BackupDir%\bookmarks.adr, %A_LoopFileFullPath%
	FileCopy %BackupDir%\notes.adr, %A_LoopFileFullPath%
	FileCopy %BackupDir%\speeddial.ini, %A_LoopFileFullPath%
	FileCopy %BackupDir%\wand.dat, %A_LoopFileFullPath%
	FileCopy %BackupDir%\global_history.dat, %A_LoopFileFullPath%
    
    If LocalAppData
	FileRemoveDir %LocalAppData%\Opera\%A_LoopFileName%\cache
    If LocalAppDataLow
	FileRemoveDir %LocalAppDataLow%\Opera\%A_LoopFileName%\cache
}
