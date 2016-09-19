;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#include <IniFilesUnicode>

ProfilesIniDir = %A_AppData%\Thunderbird
ProfilesIni = %ProfilesIniDir%\profiles.ini

IfExist %ProfilesIni%
    Loop 
    {
	ProfileNum := A_Index - 1
	Try {
	    CheckSectionProfilePath := IniReadUnicode(ProfilesIni, "Profile" ProfileNum, "Path")
	    Loop %CheckSectionProfilePath%
		CheckSectionProfilePath=%A_LoopFileLongPath%
	    If ( A_ScriptDir = CheckSectionProfilePath )
	    {
		ExistingProfileName := IniReadUnicode(ProfilesIni, "Profile" ProfileNum, "Name")
		MsgBox Профиль с этим путём уже есть в "%ProfilesIni%".`nНазывается %ExistingProfileName%
		Exit
	    }
	} Catch e {
	    If (e.What == "IniReadUnicode" && e.Message == "section not found")
		Break
	    MsgBox 16, Ошибка, % e.Message "`nв процедуре " e.What "`nДополнительная информация: " e.Extra, 30
	    Exit
	}
    }
Else {
    IfNotExist %ProfilesIniDir%
	FileCreateDir %ProfilesIniDir%
    
    ProfileNum:=0
    FileAppend [General]`nStartWithLastProfile=1`n, %ProfilesIni%
}



; в profiles.ini не найден профиль с путём %A_ScriptDir%

FileAppend,
(

[Profile%ProfileNum%]
Name=%A_UserName%
IsRelative=0
Path=%A_ScriptDir%
Default=1

),%ProfilesIni%
