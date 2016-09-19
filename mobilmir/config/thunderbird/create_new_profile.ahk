;create_new_profile.ahk [username [full_path]]

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance off
EnvGet SystemDrive, SystemDrive
EnvGet UserProfile, UserProfile

Try {
    defaultConfig := getDefaultConfigFileName()
    retailDept := defaultConfig = "Apps_dept.7z"
}

Loop %0%
{
    argv := %A_Index%
    If (InStr(argv,"\")) {
	MailProfileDir:=argv
    } Else {
	MailAddress:=argv
	StringGetPos PosOfTheAtChar, MailAddress, @
	If (ErrorLevel) {
	    MailUserId:=MailAddress
	} Else {
	    StringLeft MailUserId, MailAddress, PosOfTheAtChar
	    StringMid MailDomain, MailAddress, PosOfTheAtChar + 2
	}
    }
}

If Not MailUserId
    MailUserId := A_UserName
If Not MailDomain
    MailDomain := "mobilmir.ru"
MailAddress := MailUserId . "@" . MailDomain

If (!MailProfileDir)
{
    If (!MailProfileDir)
	MailProfileDir=%UserProfile%\Mail\Thunderbird\profile
}

;MsgBox,,%A_ScriptName% Debug, MailUserId = "%MailUserId%"`nMailDomain = "%MailDomain%"`nMailProfileDir = "%MailProfileDir%"

IfExist %MailProfileDir%\prefs.js
{
    MsgBox 35,, "%MailProfileDir%" уже существует.`nВсё равно копировать шаблон и генерировать ключ?`n(если нет`, просто будет записан путь к профилю в [Profile0] в profiles.ini)

    IfMsgBox Cancel
	Exit

    IfMsgBox No
	skipCreatingProfile := 1

    IfMsgBox Yes
    {
	FileMoveDir %MailProfileDir%, %MailProfileDir%.%A_Now%, R
	If ErrorLevel
	    Throw "Can't move existing profile"
    }
}

If (!skipCreatingProfile) {
    FileCreateDir %MailProfileDir%
    IfNotExist %MailProfileDir%
    {
	MsgBox Не удалось создать "%MailProfileDir%"!
	Exit
    }

    FileCopyDir %A_ScriptDir%\default_profile_template, %MailProfileDir%, 1
    Run %A_windir%\System32\compact.exe /C /S:"%MailProfileDir%\Mail" /I, %MailProfileDir%, Min UseErrorLevel
    Run %A_windir%\System32\compact.exe /C /S:"%MailProfileDir%\ImapMail" /I, %MailProfileDir%, Min UseErrorLevel

    If ( IsObject(prefsJsHndl := FileOpen(MailProfileDir "\prefs.js", "r-wd", "UTF-8")) ) {
	prefsjs := prefsJsHndl.Read(), prefsJsHndl.Close()
    } Else {
	MsgBox Не удалось открыть файл prefs.js. A_LastError=%A_LastError%
	Exit
    }

    If (retailDept) {
	If ( IsObject(appendPrefsJsHndl := FileOpen(MailProfileDir "\prefs_AddressBookSync_retail.js", "r-wd", "UTF-8")) ) {
	    appendprefsjs := appendPrefsJsHndl.Read(), appendPrefsJsHndl.Close()

	    If (RegExMatch(A_ComputerName, "^([.+])-[K0-9]$", HostnameMatch)) {
		StringReplace appendprefsjs, appendprefsjs, {$HostnameMatch1$}, %HostNameDeptPrefix%, 1
		prefsjs .= "`r`n" . appendprefsjs
	    }
	}
    }

    StringReplace prefsjs, prefsjs, {$MailUserId$}, %MailUserId%, 1
    StringReplace prefsjs, prefsjs, {$MailDomain$}, %MailDomain%, 1
    prefsJsHndl := FileOpen(MailProfileDir "\prefs.js", "w-", "UTF-8"), prefsJsHndl.Write(prefsjs), prefsJsHndl.Close()

    RunWait "%A_AhkPath%" "%A_ScriptDir%\unpack_extensions.ahk", %MailProfileDir%
}

findexefunc:="findexe"
If(IsFunc(findexefunc)) {
    Try xlnexe := %findexefunc%(SystemDrive . "\SysUtils\xln.exe")
    If (xlnexe) {
	FileMoveDir %A_APPDATA%\gnupg, %MailProfileDir%\gnupg, R
	RunWait "%xlnexe%" -n "%MailProfileDir%\gnupg" "%A_APPDATA%\gnupg",,Min UseErrorLevel
    }
}

If (skipCreatingProfile || StartsWith(MailProfileDir,UserProfile)) {
    Run "%A_AhkPath%" "%MailProfileDir%\AddThisProfile.ahk", %MailProfileDir%

    FileCreateShortcut notepad.exe, %A_Desktop%\подпись в письмах электронной почты (Thunderbird).lnk, , %MailProfileDir%\подпись.txt, Текст`, добавляемый в конец создаваемых писем
    Run "%A_AhkPath%" "%A_ScriptDir%\create_startup_shortcut.ahk", %A_ScriptDir%
}
    
ExitApp

StartsWith(longstr, shortstr) {
    return shortstr == SubStr(longstr,1,StrLen(shortstr))
}

#Include *i %A_ScriptDir%\..\_Scripts\Lib\getDefaultConfig.ahk
#Include *i %A_ScriptDir%\..\_Scripts\Lib\find_exe.ahk
#include <IniFilesUnicode>
