;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

;EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server

ProxySettingsRegRoot	 = HKEY_CURRENT_USER
ProxySettingsIEKey	 = Software\Microsoft\Windows\CurrentVersion\Internet Settings
EnvironmentRegKey	 = Environment
ProxyOverride		 = <local>
minFreeSpace		:= 1024 * 5 ; мегабайт

arg1=%1%
ReRunAsAdmin := !A_IsAdmin && arg1!="/NoAdminRun"

reqdConfigName		:= "Apps_dept.7z"
ServerPath		:= "\\Srv0.office0.mobilmir"
ServerDistPath		:= ServerPath . "\Distributives"
configDirSrv0		:= "\\Srv0.office0.mobilmir\profiles$\Share\config"
pathSrvConfigUpdater	:= configDirSrv0 "\update local config.cmd"
maxAgeSavedInvReport	:= 1
;tv5settingsSubPath	:= "\Soft\Network\Remote Control\Remote Desktop\TeamViewer 5\settings.cmd"
scriptInventoryReport	:= "\\Srv0.office0.mobilmir\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd"
maskInventoryReport	:= "\\Srv0.office0.mobilmir\profiles$\Share\Inventory\collector-script\Reports\" . A_ComputerName . " *.7z"
serverScriptPath	:= configDirSrv0 "\_Scripts\GUI\" . A_ScriptName
ShopBTS_InitialBaseDir	:= FirstExisting(A_ScriptDir "\..\..\..\..\..\1S\ShopBTS_InitialBase", "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase")

regsvr32exe		:= FirstExisting(A_WinDir "\SysWOW64\regsvr32.exe", A_WinDir "\System32\regsvr32.exe")
If (!regsvr32exe)
    regsvr32exe		:= "regsvr32.exe"

FileReadLine AhkDistVer, %ServerDistPath%\Soft\Keyboard Tools\AutoHotkey\ver.txt, 1
If (RegexMatch(AhkDistVer, "^(\d+)\.(\d+)\.(\d+)\.(\d+)\s", AhkVc)) {
    AhkDistVer		:= Format("{:01u}.{:01u}.{:02u}.{:02u}", AhkVc1, AhkVc2, AhkVc3, AhkVc4)
} Else
    AhkDistVer		:= "1.1.26.01"

RunKey=SOFTWARE\Microsoft\Windows\CurrentVersion\Run
DOL2SettingsRegRoot=HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line
DOL2SettingsKey=%DOL2SettingsRegRoot%\Contract\Dirs
DOL2ReqdBaseDir=d:\dealer.beeline.ru\DOL2

Gui Add, ListView, Checked Count100 -Hdr -E0x200 -Multi NoSortHdr NoSort R35 w600 vLogListView, Операция|Статус
Gui Show

OSVersionObj := RtlGetVersion()
AddLog("Запуск на Win" . OSVersionObj[2] . "." . OSVersionObj[3] . "." . OSVersionObj[4],A_Now,1)
AppXSupported := OSVersionObj[2] > 6 || (OSVersionObj[2] = 6 && OSVersionObj[3] >= 2) ; 10 or 6.[>2] : 6.0 = Vista, 6.1 = Win7, 6.2 = Win8

If (A_IsAdmin) {
    AddLog("Скрипт запущен с правами администратора",A_UserName,1)
    Run %A_WinDir%\System32\net.exe user Aleksandr.Gladkov /delete,,Min
} Else {
    AddLog("Скрипт запущен **без** прав администратора",A_UserName,1)
    
    AddLog("Скрипт RetailHelper")
    shortcutPath=%A_Startup%\RetailHelper.lnk
;    If (!FileExist(shortcutPath)) {
	SetLastRowStatus("Добавление в автозагрузку", 0)
	FileCreateShortcut D:\Local_Scripts\RetailHelper.ahk, %shortcutPath%
	SetLastRowStatus(ErrorLevel, !ErrorLevel)
;    } Else {
;	SetLastRowStatus("Скрипт есть", 1)
;    }
}

runAhkUpdate := A_AhkVersion < AhkDistVer
AddLog(A_AhkPath, A_AhkVersion . (A_AhkVersion == AhkDistVer ? "" : " (дист. " AhkDistVer ")"), !runAhkUpdate)

chkDefConfigDir := CheckPath(getDefaultConfigDir())
global DefaultConfigDir := chkDefConfigDir.path

xlnexe := findexe("xln.exe", "C:\SysUtils")
DriveGet drives, List, FIXED
For i, d in ["C", "D", "R"]
    If (!InStr(drives, d))
	missingLetters .= d
If (missingLetters)
    AddLog("Некоторых стандартных букв дисков нет нет в системе", missingLetters)
Loop Parse, drives
{
    DriveGet dlabel, Label, %A_LoopField%:
    DriveGet dsize, Capacity, %A_LoopField%:\
    DriveSpaceFree df, %A_LoopField%:\
    AddLog("Свободно на " A_LoopField ": [" dlabel "]", MBGB(df) " / " MBGB(dsize) " (" (100 * df // dsize) " %)", df > minFreeSpace)
}

FileGetTime timestampRunningScript, %A_ScriptFullPath%
runningScript := AddLog("Работающий скрипт", TimeFormat(timestampRunningScript))

Loop Files, %serverScriptPath%
{
    If (A_LoopFileLongPath = A_ScriptFullPath) {
	SetLastRowStatus("запущен с Srv0")
    } Else {
	AddLog("Скрипт на Srv0")
	FileGetTime timestampServerScript, %serverScriptPath%
	SetLastRowStatus(TimeFormat(timestampServerScript))

	If (timestampServerScript =! timestampRunningScript) {
	    SetLastRowStatus("Не совпадает", 0)
	    Loop
	    {
		MsgBox 0x4, %A_ScriptName%, Скрипт на сервере новее`, чем работающий. Запустить с сервера?`n`nНа сервере: "%serverScriptPath%":%timestampServerScript%`nРаботает:"%A_ScriptFullPath%":%timestampRunningScript%`n`n(автоматический перезапуск через 60 секунд), 60
		IfMsgBox No
		    break
		Run "%A_AhkPath%" "%serverScriptPath%"
		ExitApp
	    }
	} Else {
	    SetRowStatus(runningScript)
	}
    }
    break
}

EnvGet UserProfile,UserProfile
CheckRemove(UserProfile . "\pdk-" . A_UserName)
CheckRemove(UserProfile . "\perl")
If (FileExist(UserProfile . "\fullprofile.*.sddl")) {
    AddLog("Перемещение fullprofile.*.sddl из корня папки пользователя", "→AppData\Local\ACL-backup")
    FileMove %UserProfile%\fullprofile.*.sddl, %UserProfile%\AppData\Local\ACL-backup\*.*
    If (!ErrorLevel)
	SetLastRowStatus()
}

If (IsObject(sendemailcfg := CheckPath("d:\1S\Rarus\ShopBTS\ExtForms\post\sendemail.cfg"))) {
    ;If (!A_IsAdmin) {
    ;    ShopBTS_AddInstArg:=" /install"
    ;    ShopBTS_AddInstTextSuffix:=" с добавлением задачи в планировщик"
    ;}
    AddLog("ShopBTS_Add.install.ahk" . ShopBTS_AddInstTextSuffix, "Запуск")
    RunWait "%A_AhkPath%" "%ShopBTS_InitialBaseDir%\D_1S_Rarus_ShopBTS\ShopBTS_Add.install.ahk" /skipSchedule %ShopBTS_AddInstArg%,, Min UseErrorLevel
    statusShopBTS_Add := ErrorLevel
    If (!statusShopBTS_Add)
	FileReadLine verShopBTS_Add, d:\1S\Rarus\ShopBTS\ExtForms\post\ShopBTS_Add_ver.txt, 1
    SetLastRowStatus(errShopBTS_Add ? errShopBTS_Add : verShopBTS_Add,!errShopBTS_Add)
    
    If (FileExist(rarusnotifcfgFile := "d:\1S\Rarus\ShopBTS\ExtForms\post\DispatchFiles-NotificationsAccount.pwd")) {
	AddLog("DispatchFiles-NotificationsAccount.pwd")
	rarusnotifCurcfg := []
	;currentConfigFieldNames := ["server", "login", "password"]
	Loop Read, %rarusnotifcfgFile%
	    rarusnotifCurcfg.Push(A_LoopReadLine)
	rarusnotifsmtpsrvr := rarusnotifCurcfg[1]
	SetLastRowStatus(rarusnotifsmtpsrvr, rarusnotifsmtpsrvrOK := (rarusnotifsmtpsrvr=="smtp.yandex.ru:587"))
	If (rarusnotifsmtpsrvrOK) {
	    rarusnotifLogin := SubStr(rarusnotifCurcfg[2], 1, InStr(rarusnotifCurcfg[2], "@") - 1)
	} Else {
	    rarusnotifLogin := SubStr(A_ComputerName, 1, InStr(A_ComputerName, "-") - 1)
	    rarusnotifMiscfg := rarusnotifsmtpsrvr
	}
	FileRead allPass, \\IT-Head.office0.mobilmir\d$\Users\LogicDaemon\Google Drive\IT\Ограниченный доступ\Аккаунты почтовых ящиков для 1С-Рарус\rarus.robots.mobilmir.ru.txt
	If (allPass) {
	    Loop Parse, allPass, `n, `r
	    {
		found:=""
		Loop Parse, A_LoopField, `t
		{
		    If (A_Index==1) {
			If (found := A_LoopField = rarusnotifLogin)
			    rarusnotifLogin := A_LoopField
		    } Else If (A_Index==2 && found) {
			rarusnotifPass := A_LoopField
			break
		    } Else
			break
		}
		
		If (found)
		    break
	    }
	    allPass=
	    
	    If (found) {
		If (rarusnotifPass == rarusnotifCurcfg[3])
		    SetLastRowStatus()
		Else
		    rarusnotifMiscfg .= ", пароль"
	    } Else {
		rarusnotifMiscfgFatal := "Логин " rarusnotifLogin " не найден в файле учетных записей"
	    }
	} Else If (!rarusnotifsmtpsrvrOK) {
	    rarusnotifMiscfgFatal := "Неправильный сервер/нет доступа к списку"
	}
	
	If (rarusnotifMiscfgFatal) {
	    SetLastRowStatus(rarusnotifMiscfgFatal, 0)
	} Else If (rarusnotifMiscfg && rarusnotifMiscfg := Trim(rarusnotifMiscfg, ", ")) {
	    SetLastRowStatus("не совпадает: " rarusnotifMiscfg, 0)
	    Run "%A_AhkPath%" "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\D_1S_Rarus_ShopBTS\ShopBTS_Add.Fill_DispatchFiles-NotificationsAccount.pwd.ahk"
	} Else
	    SetLastRowStatus(rarusnotifLogin)
    }
}

AddLog("Прокси")
RegRead proxyCUEnable, HKEY_CURRENT_USER\%ProxySettingsIEKey%, ProxyEnable
If (proxyCUEnable) {
    RegRead proxyCUServer, HKEY_CURRENT_USER\%ProxySettingsIEKey%, ProxyServer
    proxystatus .= "CU: " proxyLMServer
}
RegRead proxyLMEnable, HKEY_LOCAL_MACHINE\%ProxySettingsIEKey%, ProxyEnable
If (proxyLMEnable) {
    RegRead proxyLMServer, HKEY_LOCAL_MACHINE\%ProxySettingsIEKey%, ProxyServer
    proxystatus .= ", LM: " proxyLMServer
}
envProxyKeys := {"HKEY_CURRENT_USER\Environment": "CU", "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment": "LM"}
envProxyValNames := {"http_proxy": "p", "https_proxy": "ps"}
For Key, KeyName in envProxyKeys
    For ValName, ValDisp in envProxyValNames {
	RegRead proxyVal, %Key%, %ValName%
	If (proxyVal)
	    proxystatus .= ", " KeyName ":" ValDisp "=" proxyLMServer
    }
RegRead envCUHttp_proxy, HKEY_CURRENT_USER\Environment, 
RegRead envCUHttps_proxy, HKEY_CURRENT_USER\Environment, 
RegRead envLMHttp_proxy, , http_proxy
RegRead envLMHttps_proxy, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment, https_proxy
If (proxystatus := Trim(proxystatus, ", ")) {
    SetLastRowStatus(proxystatus,0)
    RunWait "%A_AhkPath%" "%A_ScriptDir%\..\SetProxy.ahk" "",, Min UseErrorLevel
    If (ErrorLevel)
	SetLastRowStatus(proxystatus,0)
    Else
	SetLastRowStatus("был:" proxystatus)
} Else
    SetLastRowStatus("Не включен")

userFoldersChk := AddLog("Проверка доступности папок пользователя")
Loop Reg, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
{
    RegRead path
    If (!FileExist(Expand(path))) {
	AddLog(path, A_LoopRegName)
	userFoldersChk=
	keepOpen++
    }
}
If (userFoldersChk) {
    SetLastRowStatus("OK")
} Else {
    MsgBox 4, %A_ScriptName%, Некоторые папки пользователя недоступны. Из-за этого могут также не работать библиотеки.`n`nСбросить пути к папкам пользователя на стандартные?
    IfMsgBox Yes
    {
	RunWait "%A_AhkPath%" "%A_ScriptDir%\..\..\_Scripts\MoveUserProfile\reset HKCU folders.ahk",, Min UseErrorLevel
	keepOpen += !!ErrorLevel
    }
}

RegRead OneDriveSetup, HKEY_CURRENT_USER\%RunKey%, OneDriveSetup
If (!ErrorLevel) {
    AddLog("OneDriveSetup в автозагрузке", "Удаление")
    RegDelete HKEY_CURRENT_USER\%RunKey%, OneDriveSetup
    FileRemoveDir D:\Users\Пользователь\AppData\Local\Microsoft\OneDrive, 1
    keepOpen += !!ErrorLevel
    SetLastRowStatus(ErrorLevel)
}

If (AppXSupported && (A_UserName="Продавец" || A_UserName="Пользователь")) {
    AddLog("Запуск удаления всех приложений AppX")
    Run %comspec% /C "TITLE Удаление всех приложений AppX & "%DefaultConfigDir%\_Scripts\cleanup\AppX\Remove All AppX Apps for current user.cmd" /Quiet",, Min UseErrorLevel, removeAppXPID
    keepOpen += !!ErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}

;"C:\Program Files\KKMSuite\KKMWatcher.exe"
;"C:\Program Files (x86)\KKMSuite\KKMWatcher.exe"
FileDelete %A_Startup%\KKMGMSuite.exe window not on top.lnk

regViews := [32]
If (A_Is64bitOS)
    regViews.Push(64)
For i,regview in regViews {
    SetRegView %regview%
    HKLMRunKKMSuite=
    RegRead HKLMRunKKMSuite, HKEY_LOCAL_MACHINE\%RunKey%, KKMSuite
    If (!ErrorLevel && HKLMRunKKMSuite) {
	If (A_IsAdmin) {
	    AddLog("Значение KKMSuite найдено в HKLM\…\Run (" . regview . " бит), удаление…")
	    FileAppend HKEY_LOCAL_MACHINE\%RunKey%: KKMSuite=%HKLMRunKKMSuite%`n, %A_Temp%\KKMSuite-reg-HKLM-Run.txt
	    RegDelete HKEY_LOCAL_MACHINE\%RunKey%, KKMSuite
	    SetLastRowStatus(ErrorLevel,!ErrorLevel)
	} Else {
	    If (A_UserName="Продавец") {
		RegRead HKCURunKKMSuite, HKEY_CURRENT_USER\%RunKey%, KKMSuite
		If (ErrorLevel) {
		    AddLog("Запись значения KKMSuite в HKCU\…\Run")
		    RegWrite REG_SZ, HKEY_CURRENT_USER\%RunKey%, KKMSuite, %HKLMRunKKMSuite%
		    SetLastRowStatus(ErrorLevel,!ErrorLevel)
		}
	    }
	}
	break
    }
}
SetRegView Default

If (!A_IsAdmin) {
    RegRead dol2regRootDir, %DOL2SettingsKey%, RootDir
    If (!ErrorLevel && dol2regRootDir != DOL2ReqdBaseDir) {
	keepOpen:=1
	AddLog("Неправильная корневая папка DOL2", dol2regRootDir)
    }
}

If (ReRunAsAdmin) {
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    If (removeAppXPID)
	WaitProcessEnd(removeAppXPID, "Ожидание завершения скрипта удаления AppX")
    If (keepOpen) {
	MsgBox 0x31, %A_ScriptName%, При выполнении скрипта возникли ошибки. Проверьте журнал и нажмите OK для перезапуска с правами администратора., 300
	IfMsgBox TIMEOUT
	    ExitApp
	IfMsgBox Cancel
	    ExitApp
    }
    AddLog("Перезапуск от имени администратора…")
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    ExitApp
}

FileDelete C:\ScriptUpdaterDir.txt
FileDelete D:\ScriptUpdaterDir.txt

For i,regview in regViews {
    SetRegView %regview%
    RegRead unCR, HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7C05EEDD-E565-4E2B-ADE4-0C784C17311C}, UninstallString
    If (unCR) {
	AddLog("Запуск удаления Crystal Reports")
;	RunWait %unCR% /qn /norestart,, Min UseErrorLevel
	Run %unCR% /passive /norestart,, Min UseErrorLevel
	SetLastRowStatus(ErrorLevel,!ErrorLevel)
    }
}
SetRegView Default

If (IsObject(sendemailcfg)) {
    AddLog("MailLoader\install.cmd", "Запуск")
    RunWait %comspec% /C "%ShopBTS_InitialBaseDir%\MailLoader\install.cmd",,Min UseErrorLevel
    errMailLoader := ErrorLevel
    If (!errMailLoader)
	FileReadLine verGetMail, D:\1S\Rarus\MailLoader\getmail_dist_ver.txt, 1
    SetLastRowStatus(errMailLoader ? errMailLoader : verGetMail,!errMailLoader)
}

If (FileExist(scriptInventoryReport)) {
    prevSavedInvReport := FindLatest(maskInventoryReport)
    If (IsObject(prevSavedInvReport)) {
	ageSavedInvReport=
	ageSavedInvReport -= prevSavedInvReport.mtime,Days
	AddLog("Возраст отчёта об инвентаре", ageSavedInvReport . " дн.", ageSavedInvReport <= maxAgeSavedInvReport)
    }
    
    If (!IsObject(prevSavedInvReport) || ageSavedInvReport > maxAgeSavedInvReport) {
	SetLastRowStatus("Не найден, сбор информации")
	Run %comspec% /C "TITLE Сбор информации о компьютере&"%scriptInventoryReport%"",,Min UseErrorLevel
	SetLastRowStatus(ErrorLevel,!ErrorLevel)
    }
}

CheckUpdateDefaultConfigName(reqdConfigName)

;If (A_OSVersion=="WIN_7") {
;    netshexe := findexe("netsh.exe", SystemRoot . "\SysNative", SystemRoot . "\System32")
;    AddLog("Отключение Teredo")
;    RunWait %netshexe% interface ipv6 set teredo disable,,Min UseErrorLevel
;    err1netsh:=ErrorLevel
;    RunWait %netshexe% interface teredo set state disable,,Min UseErrorLevel
;    SetLastRowStatus("ipv6 STD: " . err1netsh . " / TSSD: " . ErrorLevel,!(err1netsh || ErrorLevel))
;}

; try reading Distributives source from _get_SoftUpdateScripts_source.cmd
EnvGet SystemDrive, SystemDrive
AddLog("Distributives", "Поиск _get_SoftUpdateScripts_source.cmd")
gsussScript := FirstExisting(A_AppDataCommon . "\mobilmir.ru\_get_SoftUpdateScripts_source.cmd", SystemDrive . "\Local_Scripts\_get_SoftUpdateScripts_source.cmd")
If (gsussScript) {
    LV_Modify(LV_GetCount(),,gsussScript)
} Else {
    SetLastRowStatus("Не установлен!", 0)
    keepOpen := 1
}
Distributives := EnvGetAfterScript(gsussScript, "Distributives")
SetLastRowStatus(SubStr(Distributives, 1, -StrLen("\Distributives")))
If (!FileExist(Distributives "\Soft\PreInstalled\utils\7za.exe")) {
    Distributives := ServerDistPath
    AddLog("В локальной папке дистрибутивов нет 7za.exe", "будут исп. дистрибутивы с Srv0")
}

exe7z:=find7zexe()
AddLog("7-Zip: " . exe7z)
FileGetVersion ver7z, %exe7z%
ver7z_ := StrSplit(ver7z, ".")
If (ver7z_[1] < 15) {
    SetLastRowStatus(ver7z, 0)
    AddLog("Требуется 7-Zip версии ≥15. Запуск обновления с Srv0.office0.mobilmir.")
    RunWait %comspec% /C "%ServerDistPath%\Soft\Archivers Packers\7Zip\install.cmd",,Min UseErrorLevel
    If (ErrorLevel) {
	MsgBox Ошибка "%ErrorLevel%" при обновлении 7-Zip. Автоматическое продолжение невозможно.
	ExitApp
    } Else {
	SetLastRowStatus(ErrorLevel,!ErrorLevel)
    }
    Reload
}
SetLastRowStatus(ver7z)

srvConfigUpdater := CheckPath(pathSrvConfigUpdater)
SplitPath pathSrvConfigUpdater, fnameConfigUpdater
pathLocConfigUpdater=%DefaultConfigDir%\%fnameConfigUpdater%
locConfigUpdater := CheckPath(pathLocConfigUpdater,1,0)

If (locConfigUpdater.mtime == srvConfigUpdater.mtime) {
    SetLastRowStatus("Актуальный")
    runConfUpdScript := locConfigUpdater
} Else {
    SetLastRowStatus("Устаревший", 0)
    runConfUpdScript := srvConfigUpdater
}

LV_Modify(runConfUpdScript.line,,,"Выполняется")
cmdupdateDefaultConfig := runConfUpdScript.path
RunWait %comspec% /C "%cmdupdateDefaultConfig%",,Min UseErrorLevel
SetRowStatus(runConfUpdScript.line, ErrorLevel)

If (FileExist("D:\Credit")) {
    AddLog("Перемещение ""D:\Credit"" в ""D:\Program Files\Credit""")
    FileMoveDir D:\Credit, D:\Program Files\Credit, 2
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}

If (FileExist("D:\1S\Rarus\ShopBTS\*.dbf")) {
    AddLog("Найден Рарус, замена Rarus_Scripts")
    Run "%A_AhkPath%" "%ShopBTS_InitialBaseDir%\Rarus_Scripts_unpack.ahk",,UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
    EnvSet Inst1S,1
}

tvPassChangeLog = %A_Temp%\TeamViewerPasswordChange%A_Now%.log
tvPassChangeErr := RunScript("\\Srv0.office0.mobilmir\profiles$\Share\software_update\scripts\_TeamViewerSecurityPasswordAES 2017-09-13.ahk", "Проверка/обновление пароля TeamViewer", "/warn /log """ tvPassChangeLog """", 0)
Loop Read, %tvPassChangeLog%
    SetLastRowStatus(A_LoopReadLine, !tvPassChangeErr)

;AddLog("Обновление настроек TeamViewer", StartsWith(tv5settingscmd, "\\Srv0") ? "Srv0" : SubStr(tv5settingscmd, 1, -StrLen(tv5settingsSubPath)))
;tv5settingscmd := FirstExisting(Distributives . tv5settingsSubPath, ServerDistPath . tv5settingsSubPath)
;RunWait %comspec% /C "%tv5settingscmd%", %A_Temp%, Min UseErrorLevel
;SetLastRowStatus(ErrorLevel ? ErrorLevel : "",!ErrorLevel)

If (FileExist("c:\squid")) {
    FileGetTime mtimeSquidConf, c:\squid\etc\squid.conf
    AddLog("Удаление squid", mtimeSquidConf, 1)
    
    RunWait c:\squid\sbin\squid.exe -r, c:\squid\sbin, Min UseErrorLevel
    If (ErrorLevel)
	SetLastRowStatus("Ошибка " ErrorLevel " при удалении службы", 0)
    Else {
	SetLastRowStatus("Служба удалена")
	FileRemoveDir c:\squid, 1
	squidFolderRmvErr := ErrorLevel || squidFolderRmvErr
	FileRemoveDir d:\squid, 1
	squidFolderRmvErr := ErrorLevel || squidFolderRmvErr
	If (squidFolderRmvErr)
	    SetLastRowStatus("Папка осталась")
	Else
	    SetLastRowStatus("Папка удалена")
    }
}

backup_1S_baseTask := CheckPath(FirstExisting(A_WinDir . "\System32\Tasks\mobilmir.ru\backup_1S_base", A_WinDir . "\SysNative\Tasks\mobilmir.ru\backup_1S_base", A_WinDir . "\System32\Tasks\mobilmir\backup_1S_base", A_WinDir . "\SysNative\Tasks\mobilmir\backup_1S_base"), 0, 0)
If (IsObject(backup_1S_baseTask)) {
    AddLog("Задача резервного копирования 1С-Рарус", backup_1S_baseTask.mtime)
    Loop 2
    {
	FileGetTime xmlmtime, %ShopBTS_InitialBaseDir%\Tasks\backup_1S_base.xml
	xmlmtime -= % backup_1S_baseTask.mtime, Days
	If (xmlmtime) {
	    SetLastRowStatus("Обновление", 0)
	    RunWait %comspec% /C "%ShopBTS_InitialBaseDir%\_shedule_backup1Sbase.cmd",,Min UseErrorLevel
	    SetLastRowStatus(ErrorLevel,!ErrorLevel)
	} Else {
	    SetLastRowStatus()
	    break
	}
    }
}


AddLog("Журналы скриптов обновления")
suSettingsScript=%A_AppDataCommon%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd
Try hostSUScripts:=ReadSetVarFromBatchFile(suSettingsScript, "SUSHost")
If (hostSUScripts) {
    SetLastRowStatus(hostSUScripts, 0)
    cmdCheckLocalUpdater := FirstExisting(A_ScriptDir . "\..\..\_Scripts\software_update_autodist\CheckLocalUpdater.cmd")
    RunWait %comspec% /C "%cmdCheckLocalUpdater%",,Min UseErrorLevel
    FileRead pathLastStatus, *P866 *m65536 %A_Temp%\CheckLocalUpdater.flag
    pathLastStatus := Trim(pathLastStatus, "`r`n`t ")
    If (!ErrorLevel && FileExist(pathLastStatus)) {
	FileGetTime timeLastStatus, pathLastStatus
	SplitPath pathLastStatus, fnameLastStatus
	ageLastStatus=
	ageLastStatus-=timeLastStatus, Days
	If (ageLastStatus) {
	    SetLastRowStatus(hostSUScripts . " [" . ageLastStatus . " дн.]", 0)
	} Else {
	    SetLastRowStatus(fnameLastStatus . " (сегодня)")
	}
    }
}

softUpdScripts := CheckPath("d:\Scripts\_DistDownload.cmd", 1, 0)
If (IsObject(softUpdScripts)) {
    If (FileExist("d:\Scripts\ver.flag")) {
	;15.08.2016 20:09
	FileRead verFlagSoftUpdScripts, *m16 d:\Scripts\ver.flag
	SetLastRowStatus(verFlagSoftUpdScripts,0)
    }
    
    distSoftUpdScripts := CheckPath(DefaultConfigDir . "\_Scripts\software_update_autodist\downloader-dist.7z")
    If (!IsObject(distSoftUpdScripts))
	softUpdScripts=
    FormatTime timeDistSoftUpdScripts, % distSoftUpdScripts.mtime, dd.MM.yyyy HH:mm
    If (timeDistSoftUpdScripts == verFlagSoftUpdScripts) {
	SetRowStatus(distSoftUpdScripts.line, timeDistSoftUpdScripts, 1)
	SetRowStatus(softUpdScripts.line, "Актуальный", 1)
	softUpdScripts=
    } Else {
	SetRowStatus(distSoftUpdScripts.line, timeDistSoftUpdScripts, 0)
	SetRowStatus(softUpdScripts.line, , 0)
    }
}
If (IsObject(softUpdScripts)) { ; если обновлять скрипты software_update не надо, объект будет удален в блоке выше
    If (!IsObject(distSoftUpdScripts))
	distSoftUpdScripts := CheckPath(configDirSrv0 "\_Scripts\software_update_autodist\downloader-dist.7z", 0, 0)
    If (IsObject(distSoftUpdScripts)) {
	distSoftUpdScripts.path := DefaultConfigDir . "\_Scripts\software_update_autodist\downloader-dist.7z"
	SetRowStatus(distSoftUpdScripts.line, "Обновляется", 0)
	RunWait %comspec% /C "%DefaultConfigDir%\_Scripts\software_update_autodist\SetupLocalDownloader.cmd",, Min UseErrorLevel
	SetRowStatus(distSoftUpdScripts.line, ErrorLevel ? ErrorLevel : timeDistSoftUpdScripts, ErrorLevel=0)
    }
}
If (!((gpgexist := FileExist("C:\SysUtils\gnupg\gpg.exe")) && IsObject(softUpdScripts))) {
    If (SubStr(Distributives, 1, 2) != "\\" && FileExist(Distributives "\rSync_DistributivesFromSrv0.cmd") && FileExist(Distributives "\Soft\PreInstalled\auto\SysUtils\*")) {
	AddLog("rSync_DistributivesFromSrv0.cmd PreInstalled")
	RunWait %comspec% /C ""%Distributives%\rSync_DistributivesFromSrv0.cmd" "%Distributives%\Soft\PreInstalled"", %Distributives%, Min UseErrorLevel
	SetLastRowStatus(ErrorLevel, !ErrorLevel)
    }
    ;				  distSubpath, 				  scriptSubpath,					  title:="",	 flagMask:="",				    loopOptn:="")
    RunScriptFromNewestDistDir("Soft\PreInstalled\auto\SysUtils\*.7z", "Soft\PreInstalled\SysUtils-cleanup and reinstall.cmd", "PreInstalled", gpgexist ? SystemDrive . "\SysUtils" : "", loopOptn:="DFR")
}
;MsgBox % "softUpdScripts: " IsObject(softUpdScripts) "`ndistSoftUpdScripts: " IsObject(distSoftUpdScripts)

RunFromConfigDir("_Scripts\unpack_retail_files_and_desktop_shortcuts.cmd", "Замена ярлыков и распаковка стандартных скриптов")
;-- должен устранавливаться скриптом unpack_retail_files_and_desktop_shortcuts.cmd -- RunFromConfigDir("_Scripts\ScriptUpdater_dist\InstallScriptUpdater.cmd", "ScriptUpdater") 
AddLog("Удаление задачи планировщика mobilmir\AddressBook…")
RunWait %A_WinDir%\System32\schtasks.exe /Delete /TN "mobilmir\AddressBook_download" /F,, Min UseErrorLevel
SetLastRowStatus(ErrorLevel,!ErrorLevel)

RunFromConfigDir("_Scripts\Tasks\All XML.cmd", "Обновление задач планировщика")
RunFromConfigDir("_Scripts\Tasks\AddressBook_download.cmd")
RunWait %A_WinDir%\System32\NET.exe SHARE AddressBook$ /DELETE,,Min UseErrorLevel
If (!ErrorLevel) {
    abDir = D:\Mail\Thunderbird\AddressBook
    AddLog("Настройка доступа к " abDir, "Настройка \\…\AddressBook$")
    RunWait %A_WinDir%\System32\NET.exe SHARE AddressBook$="%abDir%" /GRANT:Everyone`,READ,,Min UseErrorLevel
    If (ErrorLevel)
	RunWait %A_WinDir%\System32\NET.exe SHARE AddressBook$="%abDir%" /GRANT:Все`,READ,,Min UseErrorLevel
    If (ErrorLevel)
	RunWait %A_WinDir%\System32\NET.exe SHARE AddressBook$="%abDir%",,Min UseErrorLevel
    If (ErrorLevel)
	SetLastRowStatus(ErrorLevel ? ErrorLevel : "",!ErrorLevel)
    Else {
	SetLastRowStatus("Настройка ACL")
	sidEveryone=S-1-1-0
	;sidAuthenticatedUsers=S-1-5-11
	;sidUsers=S-1-5-32-545
	sidSYSTEM=S-1-5-18
	;sidCreatorOwner=S-1-3-0
	sidAdministrators=S-1-5-32-544
	;Administrators=S-1-5-32-544
	;SYSTEM=S-1-5-18
	;sidBackupOperators=S-1-5-32-551
	;sidCREATOROWNER=S-1-3-0
	RunWait %A_WinDir%\System32\takeown.exe /A /R /D Y /F "%abDir%",,Min UseErrorLevel
	RunWait %A_WinDir%\System32\icacls.exe "%abDir%" /reset /T /C /L,,Min UseErrorLevel
	RunWait %A_WinDir%\System32\icacls.exe "%abDir%" /inheritance:r /C /L,,Min UseErrorLevel
	RunWait %A_WinDir%\System32\icacls.exe "%abDir%" /setowner "*%sidAdministrators%" /T /C /L,,Min UseErrorLevel
	RunWait %A_WinDir%\System32\icacls.exe "%abDir%" /grant "*%sidAdministrators%:(OI)(CI)F" /grant "*%sidSYSTEM%:(OI)(CI)F" /grant "*%sidEveryone%:(OI)(CI)R" /C /L,,Min UseErrorLevel
	SetLastRowStatus(ErrorLevel ? ErrorLevel : "",!ErrorLevel)
    }
}
	
If (IsObject(instCriacxocx)) {
    If (timecriacxcab) {
	FileGetTime criacxocxTimeNew, % instCriacxocx.path
	criacxocxTimeDiff:=criacxocxTimeNew
	EnvSub criacxocxTimeDiff, instCriacxocx.mtime, Days
	If (criacxocxTimeDiff) {
	    statusTextcriacxocx := " → " . criacxocxTimeNew . " (обновился)"
	} Else {
	    statusTextcriacxocx := instCriacxocx.mtime . " (не обновился)"
	}
	SetRowStatus(instCriacxocx.line, statusTextcriacxocx, criacxocxTimeDiff > 0)
    } Else {
	SetRowStatus(instCriacxocx.line, "ocx~=cab (" . TimeFormat(instCriacxocx.mtime) . ")",1)
    }
} Else {
    AddLog("CRIACX.ocx","отсутствует",1)
}

cleanupAdobeReadercmd=Soft\Office Text Publishing\PDF\Adobe Reader\RemoveUnneededAutorunAndServices.cmd
RunScriptFromNewestDistDir(cleanupAdobeReadercmd, cleanupAdobeReadercmd, "Удаление лишней службы Adobe Reader")

AddLog("Удаление задачи планировщика ""update dealer.beeline.ru criacx.ocx""")
RunWait %A_WinDir%\System32\schtasks.exe /Delete /TN "mobilmir.ru\update dealer.beeline.ru criacx.ocx" /F,,Min UseErrorLevel
SetLastRowStatus(ErrorLevel,!ErrorLevel)
If (IsObject(instCriacxocx := CheckPath(FirstExisting("d:\dealer.beeline.ru\bin\CRIACX.ocx", A_WinDir . "\SysNative\criacx.ocx", A_WinDir . "\System32\criacx.ocx", A_WinDir . "\SysWOW64\criacx.ocx"), 0))) {
    ;FileGetTime timecriacxcab,%DefaultConfigDir%\Users\depts\D\dealer.beeline.ru\bin\criacx.cab
    ;timecriacxcab -= instCriacxocx.mtime, Days
    ;https://redbooth.com/a/#!/projects/59756/tasks/32400133
    AddLog("Удаление " instCriacxocx.path, "regsvr32 /u")
    RunWait % """" regsvr32exe """ /s /u """ instCriacxocx.path """",,Min UseErrorLevel
    SetLastRowStatus("Удаление… | regsvr32 err: " regsvr32err := ErrorLevel)
    FileDelete % instCriacxocx.path
    SetLastRowStatus("ocx " (ErrorLevel ? "не " : "") "удалён! regsvr32 err: " regsvr32err, !ErrorLevel)
    
    RunFromConfigDir("_Scripts\cleanup\Apps\clean dealer.beeline.ru dir.ahk")
}

If (removeAppXPID)
    WaitProcessEnd(removeAppXPID, "Ожидание завершения скрипта удаления AppX")
If (AppXSupported) { ; 10 or 6.[>2] : 6.0 = Vista, 6.1 = Win7, 6.2 = Win8
    AddLog("Удаление лишних приложений AppX")
    RunWait %comspec% /C "TITLE Удаление лишних приложений AppX & "%DefaultConfigDir%\_Scripts\cleanup\AppX\Remove AppX Apps except allowed.cmd" /Quiet",, Min UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}

If (OSVersionObj[2] != 10 || OSVersionObj[3] != 0 || OSVersionObj[4] != 14393) { ; On Win 10 [1607] Start menu stops working after this
    aclSetupLine := AddLog("Запуск в фоновом режиме настройки ACL ФС")
;    If (teeexe := findexe("tee.exe", "C:\SysUtils"))
;	logsuffix= 2>&1 | "%teeexe%" -a "`%TEMP`%\FSACL _depts_simplified.cmd.log"
	;>"`%TEMP`%\FSACL _depts_simplified.cmd.log" 2>&1 
;    Run %comspec% /C "TITLE Настройка параметров безопасности файловой системы & CALL "%DefaultConfigDir%\_Scripts\Security\_depts_simplified.cmd" %logsuffix%",, Min UseErrorLevel
    Run "%A_AhkPath%" "%DefaultConfigDir%\_Scripts\Security\_run_depts_simplified.ahk",, UseErrorLevel, aclSetupPID
    
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
} Else {
    AddLog("Настройка ACL пропущена, т.к. на Windows 10 [1607] это вызывает проблемы")
}

finished := 1

If (runAhkUpdate && A_IsAdmin) {
    AddLog("Обновление AutoHotkey с Srv0.office0.mobilmir.")
    If (aclSetupLine) {
	Loop
	{
	    Process Exist, %aclSetupPID%
	    If (!ErrorLevel) {
		SetRowStatus(aclSetupLine, "Завершено")
		break
	    }
	    If (A_Index=1)
		SetLastRowStatus("ожидание заверш. настр. ACL")
	    Sleep 1000
	}
	SetLastRowStatus("Запущено")
    }
    ;ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    ;If (ReRunAsAdmin) {
    ;	Run %comspec% /C "TITLE Ожидание обновления AutoHotkey, перезапуск %A_ScriptName% & (PING 127.0.0.1 -n 30 >NUL) & (ECHO Нажмите любую клавишу в этом окне, когда завершится обнолвление.) & (PAUSE >NUL) & %ScriptRunCommand% /NoAdminRun"
    ;	Run *RunAs %comspec% /C "CALL "%ServerDistPath%\Soft\Keyboard Tools\AutoHotkey\install.cmd" & CALL "%ServerDistPath%\Soft\PreInstalled\auto\AutoHotkey_Lib.cmd" & %ScriptRunCommand%"
    ;} Else {
    ;	Run %comspec% /C "PING Srv0.office0.mobilmir -n 5 >NUL & CALL "%ServerDistPath%\Soft\Keyboard Tools\AutoHotkey\install.cmd" & CALL "%ServerDistPath%\Soft\PreInstalled\auto\AutoHotkey_Lib.cmd" & %ScriptRunCommand%"
    ;}
    Run %comspec% /C "%ServerDistPath%\Soft\Keyboard Tools\AutoHotkey\install.cmd"
    If (ErrorLevel) {
	SetLastRowStatus(ErrorLevel, 0)
	MsgBox Ошибка "%ErrorLevel%" при запуске обновления AutoHotkey. Автоматическое продолжение невозможно.
    } Else {
	SetLastRowStatus()
    }
    ;ExitApp
} Else {
    SetLastRowStatus()
}
AddLog("Готово", A_Now, 1)
Sleep 300000
ExitApp

GuiEscape:
GuiClose:
ButtonCancel:
    If (!finished) {
	MsgBox 0x134, %A_ScriptName%, Скрипт ещё работает. Точно выйти?
	IfMsgBox No
	    return
    }
    ExitApp

RunScriptFromNewestDistDir(ByRef distSubpath, ByRef scriptSubpath, title:="", flagMask:="", optnLoopFlag:="") {
    global ServerDistPath, Distributives
    latestFlagTime:=0

    If (!title)
	title := AbbreviatePath(flagMask ? flagMask : distSubpath)
    AddLog(title, "Проверка")
    FindLatest(Distributives "\" distSubpath,, mtimelocal)
    FindLatest(ServerDistPath "\" distSubpath,, mtimeSrv0)
    
    If (flagMask)
	FindLatest(flagMask, optnLoopFlag, latestFlagTime)
    
    If (latestFlagTime) {
	timeDiff := mtimeSrv0
	timeDiff -= latestFlagTime, Minutes
    }
    
    If (!latestFlagTime || timeDiff > 5) { ; если архив на Srv0 новее всех файлов по маске больше, чем на 5 минут, – обновлять
        If (mtimelocal==mtimeSrv0) {
	    SetLastRowStatus("Обновление из " Distributives,0)
	    RunWait %comspec% /C "%Distributives%\%scriptSubpath%",%A_Temp%,Min UseErrorLevel
        } Else {
	    SetLastRowStatus("Обновление с " ServerDistPath,0)
	    RunWait %comspec% /C "%ServerDistPath%\%scriptSubpath%",%A_Temp%,Min UseErrorLevel
	}
        SetLastRowStatus(ErrorLevel,!ErrorLevel)
    } Else {
        SetLastRowStatus(TimeFormat(latestFlagTime), 1)
    }
}

RunFromConfigDir(ByRef subPath, ByRef logLineText:="", ByRef args:="") {
    global DefaultConfigDir, configDirSrv0
    
    runSc := LatestExisting(DefaultConfigDir "\" subPath, configDirSrv0 "\" subPath)
    return RunScript(runSc.Path, logLineText, args)
}

RunScript(Byref runScPath, ByRef logLineText:="", ByRef args:="", wait := 1) {
    SplitPath runScPath, , , ext
    If (ext="exe") {
	
    } Else If (ext="ahk") {
	interpreter := """" A_AhkPath """ "
    } Else If (ext="cmd" || ext = "bat") {
	interpreter = %Comspec% /C "
	suffix = "
    } Else
	Throw Exception("Для этого расширения файла не определен интерпретатор",, ext)
    
    If (logLineText)
	l := AddLog(logLineText)
    Else
	l := AddLog(AbbreviatePath(runScPath))
    If (wait)
	RunWait %interpreter%"%runScPath%" %args%%suffix%, %A_Temp%, Min UseErrorLevel
    Else
	Run %interpreter%"%runScPath%" %args%%suffix%, %A_Temp%, Min UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
    
    return l
}

MBGB(val) {
    If (!val)
	return ""
    format:="{:d}"
    unit:="MB"
    If (val > 1024) {
	format:="{:0.2f}"
	val /= 1024.
	unit:="GB"
    }
    return Format(format, val) . " " . unit
}

CheckRemove(path) {
    trashDir := A_Temp . "\trash-" . A_ScriptName
    FileCreateDir %trashDir%
    If (attr:=FileExist(path)) {
	AddLog(path, "Удаление мусора")
	If(InStr(attr, "D"))
	    FileMoveDir %path%,%trashDir%,R
	Else
	    FileMove %path%,%trashDir%
	If (!ErrorLevel)
	    SetLastRowStatus()
    }
}

CheckUpdateDefaultConfigName(reqdConfigName) {
    Loop {
	DefaultConfig:=GetDefaultConfig()
	SplitPath DefaultConfig,configName,configDir
	AddLog("Путь к файлу конфигурации: " . configDir, configName)
	If (!FileExist(DefaultConfig)) {
	    configDir = d:\Distributives\config
	    MsgBox 4, %A_ScriptName%, Файл конфигурации "%DefaultConfig%" не существует (или недоступен).`n`nИзменить на "%configDir%\%configName%"?
	} Else If (configName!=reqdConfigName) {
	    configName:=reqdConfigName
	    MsgBox 4, %A_ScriptName%, В розничных отделах название локального файла конфигурации должно быть %reqdConfigName%`, но на этом компьютере файл конфигурации (полный путь): %DefaultConfig%`n`nИзменить на "%configDir%\%reqdConfigName%"?
	} Else {
	    SetLastRowStatus()
	    break
	}
	
	IfMsgBox No
	    break

	FileDelete %A_AppDataCommon%\mobilmir.ru\_get_defaultconfig_source.cmd
	FileAppend SET "DefaultsSource=%configDir%\%configName%"`n,%A_AppDataCommon%\mobilmir.ru\_get_defaultconfig_source.cmd, CP866
    }

    return DefaultConfigDir := configDir
}

WaitProcessEnd(pid, message:="Ожидание завершения процесса", timeout:=0) {
    Process Exist, %pid%
    If (ErrorLevel) {
	AddLog(message)
	waited := 1
	If (timeout)
	    Process WaitClose, %pid%, %timeout%
	Else
	    Process WaitClose, %pid%
    }
    
    If (waited) {
	SetLastRowStatus(ErrorLevel)
    }
    return ErrorLevel
}

EnvGetAfterScript(batch, varName) {
    tempFile = %A_Temp%\%A_ScriptName%-envGetAfterScript.%A_Now%.cmd
    outFile = %A_Temp%\%A_ScriptName%-envGetAfterScript.%A_Now%.txt
    FileAppend,
    (LTrim
	@(REM coding`:OEM
	CALL "%batch%">"`%~dpn0.log" && DEL "`%~dpn0.log"
	`)
	(ECHO `%%varName%`%
	`)>"%outFile%"
    ),%tempFile%,CP1
    RunWait %comspec% /C "%tempFile%", %A_Temp%, Min UseErrorLevel
    FileRead out, *P1 *m65536 %outFile%
    Sleep 0
    FileDelete %tempFile%
    Sleep 0
    FileDelete %outFile%
    return Trim(out, "`r`n`t ")
}

StartsWith(longstr, shortstr) {
    return SubStr(longstr, 1, StrLen(shortstr)) = shortstr
}

CheckPath(path, logTime:=1, checkboxIfExist:=1) {
    If (!path)
	return
    exist := FileExist(path)
    If (exist)
	FileGetTime mtime, %path%
    If logTime is integer
    {
	If (exist) {
	    If (logTime==1 || logTime==2) {
		logTime := TimeFormat(mtime)
	    }
	} Else {
	    logTime:="(не найден)"
	}
	line := AddLog(AbbreviatePath(path), logTime, checkboxIfExist & (exist!=""))
    }
    If (exist)
	return {path: path, attr: exist, mtime: mtime, line: line}
    Else
	return
}

LatestExisting(paths*) {
    for index,path in paths
	If (FileExist(path) && newFound := FindLatest(path,, latestTime))
	    curFound := newFound
    
    return curFound
}

FindLatest(mask, loopOptn:="", ByRef latestTime:=0) {
    Loop Files, %mask%, %loopOptn%
    {
	If (A_LoopFileTimeModified > latestTime) {
	    latestPath := A_LoopFileFullPath
	    latestTime := A_LoopFileTimeModified
	}
    }
    
    If (latestPath) {
	objLatest := {"path": latestPath, "attr": FileExist(latestPath), "mtime": latestTime}
	return objLatest
    } Else If (!latestTime) {
	AddLog(AbbreviatePath(mask), "Не найдено подходящих файлов")
    }
}

AbbreviatePath(path) {
    path := RegExReplace(path, "i)^\\\\Srv0(\.office0\.mobilmir)?\\(profiles\$(\\Share)?|Distributives)?\\","{Srv0}")
    If (DefaultConfigDir)
	path := RegExReplace(path,"\Q" . DefaultConfigDir . "\E", "{configDir}")
    return path
}

AddLog(text, status:="", check:=0) {
    checkOpt := check ? "Check " : "" 
    addedRow := LV_Add(checkOpt . "Vis", text, status)
    LV_ModifyCol()
    return addedRow
}

SetLastRowStatus(status:="", check:=1) {
    return SetRowStatus(LV_GetCount(),status,check)
}

SetRowStatus(ByRef roworobj, status:="", check:=1) {
    If status is integer
	If (status==0)
	    status:="OK"
	Else If (status > 2000000000000000) ; If status is time but full YYYYMMDDHH24MISS, not like just year
	    status := TimeFormat(status)
	Else
	    status=! %status%

    
    row := IsObject(roworobj) ? roworobj.line : roworobj
    If (status=="")
	return LV_Modify(row, check ? "Check" : "")
    Else
	return LV_Modify(row, check ? "Check" : "",,status)
}

TimeFormat(ByRef time) {
    age=
    age -= time, Days ; ago from now
    If (age)
	age = %age% дн.
    Else
	age = сегодня
    FormatTime ft, %status%, yyyy-MM-dd HH:mm '(%age%)'
    return ft
}

FirstExisting(paths*) {
    for index,path in paths
    {
	IfExist %path%
	    return path
    }
    
    return
}

Expand(string) {
    PrevPctChr:=0
    LastPctChr:=0
    VarnameJustFound:=0
    output:=""

    While ( LastPctChr:=InStr(string, "%", true, LastPctChr+1) ) {
	If VarnameJustFound
	{
	    EnvGet CurrEnvVar,% SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    output .= CurrEnvVar
	    VarnameJustFound:=0
	} else {
	    output .= SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    If (SubStr(string, LastPctChr+1, 1) == "%") { ;double-percent %% skipped ouside of varname
		output .= "%"
		LastPctChr++
	    } else {
		VarnameJustFound:=1
	    }
	}
	PrevPctChr:=LastPctChr
    }

    ;If VarnameJustFound ; That's bad, non-closed varname
    ;	Throw ("Var name not closed with %")
    
    output .= SubStr(string,PrevPctChr+1)
    
    return % output
}

#include %A_LineFile%\..\..\..\_Scripts\Lib\RtlGetVersion.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\getDefaultConfig.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\find7zexe.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
;#include %A_LineFile%\..\..\..\_Scripts\Lib\find_exe.ahk
