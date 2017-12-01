#NoEnv
#SingleInstance force

If A_UserName In Install,Admin,Administrator,Guest,Гость
    Finish()

Try DefaultConfigDir:=getDefaultConfigDir()
If (!DefaultConfigDir)
    DefaultConfigDir:="\\Srv0.office0.mobilmir\profiles$\Share\config"

If A_UserName In Продавец,Пользователь
{
    SharedUserActions()
} Else {
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
}

Loop Parse, A_UserName
    If (A_LoopField >= "А" && A_LoopField <= "Я" || A_LoopField >= "а" && A_LoopField <= "я" || A_LoopField==" ") ; Any russian letter or a space
	SharedUserActions()

; Non-shared user actions

; https://redbooth.com/a/#!/projects/59756/tasks/33304584
If (InStr(SubStr(A_UserName, 2, 3), "."))
    RunCreateMTProfile("thunderbird\create_new_profile_askparm.ahk")
Else
    RunCreateMTProfile("thunderbird\create_new_profile.ahk")
Finish()

SharedUserActions() {
    SharedMTProfileDirPath:="D:\Mail\Thunderbird\profile"
    IfNotExist %SharedMTProfileDirPath%\prefs.js
    {
	MsgBox 36, Текущий пользователь должен использовать общий профиль Thunderbird, Имя текущего пользователя - %A_UserName%`, но общий профиль почты (в %SharedMTProfileDirPath%) не существует.`nСоздать?
	IfMsgBox No
	    Finish()
	
	RunCreateMTProfile("_Scripts\CreateMTProfileForSharedUser.cmd")
	Sleep 15000
    }
    
    IfExist %SharedMTProfileDirPath%
    {
	EnvGet UserProfile,UserProfile
	MTProfileInUserProfileDir=%UserProfile%\Mail\Thunderbird\profile
	IfNotExist %MTProfileInUserProfileDir%\*.*
	{
	    FileCreateDir %MTProfileInUserProfileDir%
	    ; user have no permission for SharedMTProfileDirPath, so linking back won't work. Must move only directory contents, and then link back.
	    FileMove %SharedMTProfileDirPath%\*, %MTProfileInUserProfileDir%\*
	    Loop %SharedMTProfileDirPath%\*, 2
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

ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	trimmedReadLine:=Trim(A_LoopReadLine)
	If (SubStr(trimmedReadLine, 1, 4) = "SET ") {
	    splitter := InStr(trimmedReadLine, "=")
	    If (splitter && Trim(SubStr(trimmedReadLine, 5, splitter-5), """`t ") = varname) {
		return Trim(SubStr(trimmedReadLine, splitter+1), """`t ")
	    }
	}
    }
}

getDefaultConfig() {
    EnvGet SystemDrive, SystemDrive
    defaultConfig := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd", "DefaultsSource")
    If (!defaultConfig)
	defaultConfig := ReadSetVarFromBatchFile(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd", "DefaultsSource")
    return defaultConfig
}

getDefaultConfigDir() {
    defaultConfig := getDefaultConfig()
    SplitPath defaultsSource,,OutDir
    return OutDir
}
