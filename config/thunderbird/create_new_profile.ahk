;usage variants:
;create_new_profile.ahk [path_with_a_backslash_in_it [MailUserId[@MailDomain] ["Sender Name"]]
;create_new_profile.ahk [MailUserId[@MailDomain] path_with_a_backslash_in_it ["Sender Name"]]
;create_new_profile.ahk [MailUserId[@MailDomain] ["Sender Name"] [any_path]]
;
;path_with_a_backslash_in_it must contain a "\"
;any_path - not necessarily
;
;default MailUserId is UserName
;default MailDomain is "mobilmir.ru"
;default profile path is "%UserProfile%\Mail\Thunderbird\profile" 
;
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance off
EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server
EnvGet SystemDrive, SystemDrive
EnvGet UserProfile, UserProfile
MailUserId=
mailProfileDir=
mailFullName=

Try {
    retailDept := Func("getDefaultConfigFileName").Call() = "Apps_dept.7z"
}

For i, argv in A_Args {
    If (mailProfileDir=="" && InStr(argv,"\")) {
	mailProfileDir := argv
    } Else {
	If (!MailUserId) {
	    If (posOfTheAtChar := InStr(argv,"@")) {
		StringLeft MailUserId, argv, posOfTheAtChar - 1
		StringMid MailDomain, argv, posOfTheAtChar + 1
	    } Else {
		MailUserId := argv
	    }
	} Else If (!mailFullName) {
	    mailFullName := argv
	} Else If (!mailProfileDir) {
	    mailProfileDir := argv
	} Else {
	    Throw Exception("Лишний аргумент в командной строке", i, argv)
	}
    }
}

If (!MailUserId)
    MailUserId := A_UserName
If (!MailDomain)
    MailDomain := "mobilmir.ru"
mailAddress := MailUserId . "@" . MailDomain

If (!mailProfileDir)
    mailProfileDir=%UserProfile%\Mail\Thunderbird\profile

;MsgBox,,%A_ScriptName% Debug, MailUserId = "%MailUserId%"`nMailDomain = "%MailDomain%"`nmailFullName = "%mailFullName%"`nmailProfileDir = "%mailProfileDir%"

If (FileExist(mailProfileDir . "\prefs.js")) {
    MsgBox 35,, "%mailProfileDir%" уже существует.`nВсё равно создать новый профиль?`n(если нет`, просто будет записан путь к профилю в [Profile0] в profiles.ini)

    IfMsgBox Cancel
	Exit

    IfMsgBox No
	skipCreatingProfile := 1

    IfMsgBox Yes
    {
	FileMoveDir %mailProfileDir%, %mailProfileDir%.%A_Now%, R
	If ErrorLevel
	    Throw Exception("Существующий профиль не удалось переименовать",, """" mailProfileDir """ → """  mailProfileDir "." A_Now)
    }
}

If (!skipCreatingProfile) {
    FileCreateDir %mailProfileDir%
    If (!InStr(FileExist(mailProfileDir), "D"))
	Throw Exception(A_LastError,, "Не удалось создать """ mailProfileDir """!")
    Try
        FileCopyDir %A_ScriptDir%\default_profile_template, %mailProfileDir%, 1
    Catch e
        Throw Exception(e,, "Ошибка при копировании """ A_ScriptDir "\default_profile_template"" в """ mailProfileDir """")
    If ( !(prefsjs := fRead(mailProfileDir "\prefs.js")) )
	Throw Exception(A_LastError,, "Не удалось прочитать файл """ mailProfileDir " \prefs.js"".")

    Run %SystemRoot%\System32\compact.exe /C /S:"%mailProfileDir%\Mail" /I, %mailProfileDir%, Min UseErrorLevel
    Run %SystemRoot%\System32\compact.exe /C /S:"%mailProfileDir%\ImapMail" /I, %mailProfileDir%, Min UseErrorLevel

    If (retailDept) {
        If (appendprefsjs := fRead(A_ScriptDir "\prefs-parts\prefs_AddressBookSync_retail.js")) {
            If (!InStr(FileExist("d:\Mail\Thunderbird\AddressBook"), "D")
                && RegExMatch(A_ComputerName, "^([.+])-[K0-9]$", HostnameMatch)) ; this only replaces hostname in comments, which is borderline superflous
                appendprefsjs := StrReplace(appendprefsjs, "{$HostNameDeptPrefix$}", HostnameMatch1)
            ; otherwise appendprefsjs may stay as is
	} Else If (InStr(FileExist("\\localhost\AddressBook$"), "D")
                   && appendprefsjs := fRead(A_ScriptDir "\prefs-parts\prefs_AddressBookSync_anypath.js")) {
            appendprefsjs := StrReplace(appendprefsjs, "{$path$}", "\\\\localhost\\AddressBook$")
        }

        If (appendprefsjs)
            prefsjs .= (   SubStr(appendprefsjs, 1, 1) == "`n"
                           || SubStr(prefsjs, 0, 1) == "`n"
                         ? "" : "`n" ) . appendprefsjs
    } Else Try {
	mailFullName := Func("WMIGetUserFullname").Call(2)
    }
    
    ;prefsjs := RegExReplace(prefsjs, "\{\$\w+\$\}", )
    prefsjs := StrReplace( StrReplace(prefsjs, "{$MailUserId$}", MailUserId), "{$MailDomain$}", MailDomain )
    If (mailFullName)
        prefsjs := StrReplace(prefsjs
                            , "//user_pref(""mail.identity.id1.fullName"", ""{$MailFullName$}"");"
                            , "user_pref(""mail.identity.id1.fullName"", """ mailFullName """);")
    prefsJsHndl := FileOpen(mailProfileDir "\prefs.js", "w-", "UTF-8"), prefsJsHndl.Write(prefsjs), prefsJsHndl.Close()

    RunWait "%A_AhkPath%" "%A_ScriptDir%\unpack_extensions.ahk" "%mailProfileDir%\extensions"
}

If (InStr(FileExist(A_APPDATA "\gnupg"), "D")) {
    FileMoveDir %A_APPDATA%\gnupg, %mailProfileDir%\gnupg, R
    RunWait %comspec% /C "MKLINK /J "%A_APPDATA%\gnupg" "%mailProfileDir%\gnupg"",,Min UseErrorLevel
}

If (skipCreatingProfile || StartsWith(mailProfileDir,UserProfile)) {
    Run "%A_AhkPath%" "%mailProfileDir%\AddThisProfile.ahk", %mailProfileDir%

    FileCreateShortcut notepad.exe, %A_Desktop%\подпись в письмах электронной почты (Thunderbird).lnk, , %mailProfileDir%\подпись.txt, Текст`, добавляемый в конец создаваемых писем
    Run "%A_AhkPath%" "%A_ScriptDir%\create_startup_shortcut.ahk", %A_ScriptDir%
}
    
ExitApp

StartsWith(longstr, shortstr) {
    return shortstr == SubStr(longstr,1,StrLen(shortstr))
}

fRead(ByRef path, encoding := "UTF-8", mode := "r-wd") {
    If ( IsObject(fo := FileOpen(path, mode, encoding)) )
        return fo.Read(), fo.Close()
}

#include *i %A_LineFile%\..\..\_Scripts\Lib\getDefaultConfig.ahk
#include *i %A_LineFile%\..\..\_Scripts\Lib\WMIGetUserFullname.ahk
#include <IniFilesUnicode>
