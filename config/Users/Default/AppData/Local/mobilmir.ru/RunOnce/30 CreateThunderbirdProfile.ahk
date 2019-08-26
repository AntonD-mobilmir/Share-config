#NoEnv
#SingleInstance force

Try {
    FindThunderbirdProfile()
    ExitApp
}

EnvGet UserProfile,UserProfile
global MTProfileInUserProfileDir := UserProfile "\Mail\Thunderbird\profile"

If A_UserName In Install,Admin,Administrator,Администратор,Guest,Гость
    Finish()

Try DefaultConfigDir:=getDefaultConfigDir()
If (!DefaultConfigDir)
    DefaultConfigDir:="\\Srv0.office0.mobilmir\profiles$\Share\config"

FileEncoding cp1 ; OEM
FileRead fullAdminList, %DefaultConfigDir%\_Scripts\AddUsers\Add_Admins_list.txt

If (SubStr(A_LoopReadLine,1,1)!=";") {
    len := 0
    Loop Parse, A_LoopReadLine
    {
        If A_LoopField in /,%A_Tab%,%A_Space%
            break
        len++
    }
    If (len && A_UserName=SubStr(A_LoopReadLine, 1, len))
        Finish()
}

Loop Parse, A_UserName
    If (A_LoopField >= "А" && A_LoopField <= "Я" || A_LoopField >= "а" && A_LoopField <= "я" || A_LoopField==" ") ; Any russian letter or a space
	SharedUserActions()

; Non-shared user actions

; https://redbooth.com/a/#!/projects/59756/tasks/33304584
RunCreateMTProfile("thunderbird\create_new_profile_askparm.ahk")
Finish()

SharedUserActions() {
    SharedMTProfileDirPath:="D:\Mail\Thunderbird\profile"
    If (!FileExist(SharedMTProfileDirPath "\prefs.js")) {
	MsgBox 36, Текущий пользователь должен использовать общий профиль Thunderbird, Имя текущего пользователя - %A_UserName%`, но общий профиль почты (в %SharedMTProfileDirPath%) не существует.`nСоздать?
	IfMsgBox No
	    Finish()
	
	RunCreateMTProfile("_Scripts\CreateMTProfileForSharedUser.cmd")
	Sleep 15000
    }
    
    If (FileExist(SharedMTProfileDirPath)) {
	If (!FileExist(MTProfileInUserProfileDir "\*.*")) {
	    FileCreateDir %MTProfileInUserProfileDir%
	    ; user have no permission for SharedMTProfileDirPath, so linking back won't work. Must move only directory contents, and then link back.
	    FileMove %SharedMTProfileDirPath%\*, %MTProfileInUserProfileDir%\*
	    Loop Files, %SharedMTProfileDirPath%\*, D
		FileMoveDir %A_LoopFileFullPath%,%MTProfileInUserProfileDir%\%A_LoopFileName%,2
	    EnvGet SystemDrive,SystemDrive
	    RunWait %SystemDrive%\SysUtils\xln.exe -n "%MTProfileInUserProfileDir%" "%SharedMTProfileDirPath%",,Min
	}
	RunWait %comspec% /C linkthisdirtoprofile.cmd, %MTProfileInUserProfileDir%\gnupg, Min
	RunWait "%A_AhkPath%" "%MTProfileInUserProfileDir%\AddThisProfile.ahk", %MTProfileInUserProfileDir%
    }
    Finish()
}

RunCreateMTProfile(subpath:="") {
    global DefaultConfigDir
    For i, basePath in [  DefaultConfigDir
			, "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config"
			, "\\Srv0.office0.mobilmir\profiles$\Share\config"
			, "D:\Distributives\config"
			, A_AppDataCommon "\mobilmir.ru\config" ]
	If (FileExist(execCmd := basePath "\" subpath))
	    break
	Else
	    execCmd=
    If (!execCmd)
	MailCreationScriptNotFound()
    
    SplitPath execCmd, , , cmdExt
    If (cmdExt="ahk") {
	execCmd = "%A_AhkPath%" "%execCmd%"
    } Else If (cmdExt="cmd") {
	execCmd = %ComSpec% /C "%execCmd%"
    }
    RunWait %execCmd%,,UseErrorLevel

    If (ErrorLevel=="ERROR")
	MailCreationScriptNotFound(execCmd)
}

Finish() {
    ExitApp
}

MailCreationScriptNotFound(csPath:="") {
    If (csPath)
	csPathText = по пути "%csPath%"
    Else 
	csPathText = по стандартному пути
	
    MsgBox 0x35, Скрипт для создания профиля почты недоступен., Скрипт`, создающий профиль Mozilla Thunderbird`, не доступен %csPathText%.`n`nМожно прервать (Abort) выполнение сейчас`, в этом случае будет попытка запуска будет произведена при следующем входе в систему.`nЕсли причина устранена`, можно снова попытаться запустить его (Retry).`nЛибо можно игнорировать ошибку`, тогда для запуска почты скрипт необходимо будет выполнить вручную.

    IfMsgBox Abort
	ExitApp
    IfMsgBox Retry
    {
	Reload
	Sleep 3000
	MsgBox 0x10, Ошибка перезапуска %A_ScriptName%, Скрипт %A_ScriptName% не перезапустился. Сообщите в службу ИТ!
    }
    IfMsgBox Ignore
    {
	If(csPath) {
	    ;MsgBox 0x24, Ярлык создания профиля Thunderbird, Создать на рабочем столе ярлык для скрипта создания профиля`, чтобы скрипт было легче найти?
	    ;IfMsgBox Yes
		FileCreateShortcut %csPath%, %A_Desktop%\Скрипт создания профиля Thunderbird.lnk,,, Профиль необходимо создать до первого запуска Thunderbird!
		
	} Else 
	    FileCreateShortcut %A_ScriptFullPath%, %A_Desktop%\Скрипт создания профиля Thunderbird.lnk,,, Профиль необходимо создать до первого запуска Thunderbird!
	MsgBox 0x30, Thunderbird ещё не настроен!, Пока профиль не создан`, не запускайте Thunderbird!`, Если запустить`,страшного ничего не случится`, но после создания профиля скриптом придётся выпоплнять дополнительную работу: вручную очищать profiles.ini и удалять пустой профиль`, созданный Mozilla Thunderbird.
	Finish()
    }
}

FindThunderbirdProfile() {
    Encodings=UTF-8 UTF-16 CP1251

    profilesini=%A_AppData%\Thunderbird\profiles.ini

    Loop Parse, Encodings, %A_Space%
    {
	FileEncoding %A_LoopField%
	Loop Read, %profilesini%
	{
	    If (RegExMatch(Trim(A_LoopReadLine), "^\[Profile[0-9]+\]$")) {
		ProfileName:=SubStr(A_LoopReadLine, 2, -1)
		ProfilePathIsRelative=0
		Try {
		    ProfilePath := IniReadUnicode(profilesini,ProfileName,"Path")
		    ProfilePathIsRelative := IniReadUnicode(profilesini,ProfileName,"IsRelative")
		} catch
		    continue
		
		If ProfilePathIsRelative
		    ProfilePath = %A_AppData%\Thunderbird\%ProfilePath%
		
		ProfileDefault=0
		IfExist %ProfilePath%\prefs.js
		{
		    LastFoundProfilePath=%ProfilePath%
		    Try {
			ProfileDefault := IniReadUnicode(profilesini,ProfileName,"Default")
			If ProfileDefault
			    return %ProfilePath%
		    }
		}
	    }
	}
    }
    
    If LastFoundProfilePath
	return LastFoundProfilePath
    Else
	Throw Exception("Профиль не найден", -1, "Ни одна из папок профилей, прочитанных из profiles.ini, не содержит prefs.js")
}



#include <getDefaultConfig>
#Include <IniFilesUnicode>
