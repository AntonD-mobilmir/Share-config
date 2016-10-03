;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

;global ProfilesDirectory
EnvAdd ageLimit, -95, Days

ignoreRegex =
    (LTrim
    \\desktop\.ini$
    \.\\Обмен в розничных отделах\.url$
    \.\\ntuser\.ini$
    \.\\NTUSER\.DAT$
    \.\\ntuser\.pol$
    \.\\ntuser\.LOG$
    \.\\ntuser\.dat\.LOG1$
    \.\\ntuser\.dat\.LOG2$
    \.\\NTUSER\.DAT.*\.TM\.blf$
    \.\\NTUSER\.DAT.*\.TMContainer00000000000000000001\.regtrans-ms$
    \.\\NTUSER\.DAT.*\.TMContainer00000000000000000002\.regtrans-ms$
    \.\\install-pwd\.txt$
    Documents\\Default\.rdp$
    )

delFilesRegex =
    (LTrim
    \\\.\~lock\..*\#$
    \\Thumbs\.db$
    )

;~ToDo: 
;Общие папки – архив без копирования ACL файла. Доступ пользователя к папке – чтение, удаление файлов (без создания и изменения).Пользователи могут открывать файлы из архива, но для изменения файлов надо скопировать или переместить их в свою папку.
;D:\Users\{Пользователь,Продавец}
;D:\Users\Public
;из всех папок – в одну папку архива (не отдельно для пользователя, продавца и Public).


includeDirs =
    (LTrim
    .
    Desktop\*
    Documents\*
    Downloads\*
    Music\*
    Pictures\*
    Videos\*
    )

RegRead ProfilesDirectory, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory
profilesSubkey = SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
Loop Reg, HKEY_LOCAL_MACHINE\%profilesSubkey%, K
{
    RegRead profilePath, HKEY_LOCAL_MACHINE\%profilesSubkey%\%A_LoopRegName%, ProfileImagePath
    If (!profilePath)
	continue
    If (SubStr(profilePath, 1, StrLen(ProfilesDirectory)+1) = ProfilesDirectory . "\")
	profileName:=SubStr(profilePath, StrLen(ProfilesDirectory)+2)
    Else
	profileName := A_LoopRegName

;Loop Files, %ProfilesDirectory%\*, D ; Loop profiles
;{
;    profilePath := A_LoopFileFullPath
    delList .= profilePath . ":`n"
    moveList .= profilePath . ":`n"
    skipList .= profilePath . ":`n"
    Loop Parse, includeDirs, `n
    {
	If (SubStr(A_LoopField, -1) == "\*") {
	    recurse = R
	    loopSuffix = 
	} Else {
	    recurse =
	    loopSuffix = \*
	}
	SetWorkingDir %profilePath%
	Loop Files, %A_LoopField%%loopSuffix%, %recurse%
	{
	    If (A_LoopFileTimeModified < ageLimit && A_LoopFileTimeCreated < ageLimit) {
		If (!RegexListMatch(A_LoopFileFullPath, ignoreRegex) ) {
		    If (RegexListMatch(A_LoopFileFullPath, delFilesRegex)) {
			FileAppend Deleting %A_LoopFileLongPath%`n, *
			FileDelete %A_LoopFileLongPath%
			delList .= "`t" . A_LoopFileFullPath . "`n"
		    } Else {
			MsgBox Moving %A_LoopFileLongPath%
			FileCreateDir %A_ScriptDir%\%profileName%\%A_LoopFileDir%
			FileMove %A_LoopFileLongPath%, %A_ScriptDir%\%profileName%\%A_LoopFileDir%
			moveList .= "`t" . A_LoopFileFullPath . "`n"
			
			;~ToDo: copy acl
			If (!FileExist(A_LoopFileLongPath)) {
			    FileCreateShortcut %A_ScriptDir%\%profileName%\%A_LoopFileFullPath%, %A_LoopFileLongPath% (архив).lnk, %A_ScriptDir%, "%A_LoopFileLongPath%", Файл не использовался три месяца и перемещён в архив. Если он Вам всё ещё нужен`, переместите его из архива!
			    MsgBox Shortcut ErrorLevel: %ErrorLevel%
			}
		    }
		}
		;Else skipList .= "`t" . A_LoopFileFullPath . "`n"
	    }
	}
    }
}

SetWorkingDir %A_ScriptDir%
MsgBox --delList--`n%delList%
;MsgBox --skipList--`n%skipList%
FileDelete move list.txt
FileAppend %moveList%`n,move list.txt,UTF-8

RegexListMatch(ByRef haystack, ByRef regexListLF, mode:="i") {
    Loop Parse, regexListLF, `n, `r
    {
	;MsgBox % "checking`n" . haystack . "`nfor match with`n" . ("S" . mode . ")" . A_LoopField)
	If (haystack ~= ("S" . mode . ")" . A_LoopField)) {
	    return 1
	    break
	}
    }
    return 0
}
