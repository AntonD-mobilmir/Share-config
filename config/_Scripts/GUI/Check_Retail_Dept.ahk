;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server
EnvGet SystemDrive, SystemDrive
EnvGet UserProfile, UserProfile
EnvGet LocalAppData, LocalAppData
EnvGet ProgramFiles32bit, ProgramFiles(x86)
If (!ProgramFiles32bit)
    ProgramFiles32bit := A_ProgramFiles

ProxySettingsRegRoot	 = HKEY_CURRENT_USER
ProxySettingsIEKey	 = Software\Microsoft\Windows\CurrentVersion\Internet Settings
EnvironmentRegKey	 = Environment
ProxyOverride		 = <local>
RunKey                   = SOFTWARE\Microsoft\Windows\CurrentVersion\Run
minFreeSpace		:= 1024 * 5 ; мегабайт
reqdConfigName		:= "Apps_dept.7z"
subdirDistAutoHotkey	:= "Soft\Keyboard Tools\AutoHotkey"
maxAgeSavedInvReport	:= 14 ; дней

Gui Add, ListView, Checked Count100 -Hdr -E0x200 -Multi NoSortHdr NoSort R35 w600 vLogListView, Операция|Статус
Gui Show

OSVersionObj := RtlGetVersion()
WinBuildToName := {"10.0": { 10586: "1511"
                           , 14393: "1607"
                           , 15063: "1703"
                           , 17134: "1709"
                           , 17763: "1809"
                           , 18362: "1903" } }
OSVersionMinor := OSVersionObj[2] "." OSVersionObj[3]
If (WinBuildToName.HasKey(OSVersionMinor)) {
        OSVersionNameForLog := " " WinBuildToName[OSVersionMinor][OSVersionObj[4]]
} Else {
    OSVersionNameForLog := ""
}
AddLog("Запуск на Win" OSVersionMinor . OSVersionNameForLog . " (" OSVersionObj[2] "." OSVersionObj[3] "." OSVersionObj[4] ")", A_Now, 1)
AppXSupported := OSVersionObj[2] > 6 || (OSVersionObj[2] = 6 && OSVersionObj[3] >= 2) ; 10 or 6.[>2] : 6.0 = Vista, 6.1 = Win7, 6.2 = Win8

ReRunAsAdmin := !(A_IsAdmin || A_Args[1] = "/NoAdminRun")

LocationsProfilesShare := [ "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share"
			  , "\\Srv0.office0.mobilmir\profiles$\Share"
			  , "D:\Distributives" ]

dirProfilesShare := FirstExisting( LocationsProfilesShare* )
For i, baseDir_software_update in LocationsProfilesShare {
    If (InStr(FileExist(software_update_client_exec := baseDir_software_update "\software_update\client_exec"), "D"))
        break
    Else
        software_update_client_exec := ""
}

If (!dirProfilesShare)
    Throw "Папка с файлами и скриптами настройки не найдена"

officeDistSrvNetName := FirstContaining( "Distributives", "\\Srv1S-B.office0.mobilmir"
                                                        , "\\Srv0.office0.mobilmir"
                                                        , "D:" )
If (!officeDistSrvNetName)
    Throw "Папка дистрибутивов не найдена"
officeDistSrvPath := officeDistSrvNetName . "\Distributives"

dirConfigDistSrv	:= dirProfilesShare "\config"
scriptInventoryReport	:= dirProfilesShare "\Inventory\collector-script\SaveArchiveReport.cmd"
maskInventoryReport	:= dirProfilesShare "\Inventory\collector-script\Reports\" A_ComputerName " *.7z"
pathSrvConfigUpdater	:= dirConfigDistSrv "\update local config.cmd"
serverScriptPath	:= dirConfigDistSrv "\_Scripts\GUI\" A_ScriptName

regsvr32exe		:= FirstExisting(SystemRoot "\SysWOW64\regsvr32.exe", SystemRoot "\System32\regsvr32.exe")
If (!regsvr32exe)
    regsvr32exe		:= "regsvr32.exe"

FileReadLine AhkDistVer, %officeDistSrvPath%\Soft\Keyboard Tools\AutoHotkey\ver.txt, 1
If (RegexMatch(AhkDistVer, "^(\d+)\.(\d+)\.(\d+)\.(\d+)\s", AhkVc))
    AhkDistVer		:= Format("{:01u}.{:01u}.{:02u}.{:02u}", AhkVc1, AhkVc2, AhkVc3, AhkVc4)
Else
    AhkDistVer		:= "1.1.30.03"
runAhkUpdate := A_AhkVersion < AhkDistVer
AddLog(A_AhkPath, A_AhkVersion . (A_AhkVersion == AhkDistVer ? "" : " (дист. " AhkDistVer ")"), !runAhkUpdate)

If (A_IsAdmin) {
    AddLog("Скрипт запущен с правами администратора",A_UserName,1)
    Run %SystemRoot%\System32\net.exe user Aleksandr.Gladkov /delete,,Min
    Run %SystemRoot%\System32\net.exe user Aleksej.Olejnikov /delete,,Min
    Run %SystemRoot%\System32\net.exe user Nikolaj.Kravchenko /delete,,Min

    If (usingOfficeSrv && FileExist("D:\Distributives\Soft\PreInstalled\auto\SysUtils\*.7z")) {
        lDistributives := "D:\Distributives"
        rsyncPreinstalled := RunRSyncWithAddLog(lDistributives "\Soft\PreInstalled", 0)
    } Else
        lDistributives := Distributives

    If (runAhkUpdate)
	RunRsyncAutohotkey(0)
    RemoveDirsWithLog(SystemDrive "\Sun")
    
    Loop Files, %A_AhkPath%
        AhkDir := A_LoopFileDir
    If (FileExist(AhkDir "\*.bak")) {
	AddLog("Удаление " AhkDir "\*.bak")
	FileDelete %AhkDir%\*.bak, 1
	SetLastRowStatus(ErrorLevel, !ErrorLevel)
    }

    If (InStr(FileExist("d:\dealer.beeline.ru"), "D"))
        RunScript("\\IT-Head.office0.mobilmir\Backup\Retail\pack_dealer.beeline.ru.ahk", "Архивация D:\dealer.beeline.ru",, 0)
} Else {
    AddLog("Скрипт запущен **без** прав администратора",A_UserName,1)
    
    AddLog("Скрипт RetailHelper")
    shortcutPath=%A_Startup%\RetailHelper.lnk
    SetLastRowStatus("Добавление в автозагрузку", 0)
    FileCreateShortcut D:\Local_Scripts\RetailHelper.ahk, %shortcutPath%
    SetLastRowStatus(ErrorLevel, !ErrorLevel)

    DeleteWithLog(A_Startup "\1С - Рарус - Продавец.lnk"
                , A_Startup "\1С 8 Розница.lnk"
                , A_Desktop "\1С 8 Розница.lnk")
}

chkDefConfigDir := CheckPath(getDefaultConfigDir())
DefaultConfigDir := chkDefConfigDir.path

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
	SetLastRowStatus("запущен с сервера")
    } Else {
	AddLog("Скрипт на сервере")
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

CheckRemove(UserProfile . "\pdk-" . A_UserName)
CheckRemove(UserProfile . "\perl")
If (FileExist(UserProfile . "\fullprofile.*.sddl")) {
    AddLog("Перемещение fullprofile.*.sddl из корня папки пользователя", "→AppData\Local\ACL-backup")
    FileMove %UserProfile%\fullprofile.*.sddl, %LocalAppData%\ACL-backup\*.*
    If (!ErrorLevel)
	SetLastRowStatus()
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
	    proxystatus .= ", env" KeyName ":" ValDisp "=" proxyLMServer
    }
If (proxystatus := Trim(proxystatus, ", ")) {
    SetLastRowStatus(proxystatus,0)
    RunWait "%A_AhkPath%" "%A_ScriptDir%\SetProxy.ahk" "",, Min UseErrorLevel
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
    keepOpen += !!RemoveDirsWithLog(LocalAppData "\Microsoft\OneDrive")
    keepOpen += !!ErrorLevel
    SetLastRowStatus(ErrorLevel)
}

;[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\117d0af7dd935e33]
;"ShortcutAppId"="https://dealer.beeline.ru/dealer/DOL2/DOL.application#DOL.application, Culture=neutral, PublicKeyToken=1f1396238a473719, processorArchitecture=x86"
;"SupportShortcutFileName"="Техническая поддержка DOL"
;"ShortcutFileName"="DOL"
;"ShortcutFolderName"="Vimpelcom"
;"UrlUpdateInfo"="https://dealer.beeline.ru/dealer/DOL2/DOL.application"
;"UninstallString"="rundll32.exe dfshim.dll,ShArpMaintain DOL.application, Culture=neutral, PublicKeyToken=1f1396238a473719, processorArchitecture=x86"
;"Publisher"="Vimpelcom"
;"DisplayVersion"="11.5.0.15"
;"DisplayIcon"="dfshim.dll,2"
;"DisplayName"="DOL"
;"ShortcutSuiteName"=""
Loop 3
{
    RegRead DOL2Uninst, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\117d0af7dd935e33, UninstallString
    If (!DOL2Uninst)
        break
    If (A_Index == 1)
        AddLog("Удаление DOL2…")
    Else
        RunWait %SystemRoot%\System32\icacls.exe . /grant "%A_UserName%":(OI`,CI)M, %LocalAppData%\Apps, Min
    RunWait %DOL2Uninst%, %SystemRoot%\System32, UseErrorLevel
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
DeleteWithLog(A_Startup "\KKMGMSuite.exe window not on top.lnk")

regViews := [32]
If (A_Is64bitOS)
    regViews[2] := 64
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

RemoveDirsWithLog(A_AppData "\SibIT")

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

RemoveDirsWithLog(A_AppDataCommon "\dpn0")

RunWait %SystemRoot%\System32\schtasks.exe /Delete /TN "DreamkasAgentService" /F,, Min UseErrorLevel
RunWait %SystemRoot%\System32\schtasks.exe /Delete /TN "mobilmir\1S Rarus DispatchFiles" /F,, Min UseErrorLevel
For taskDirSuffix in {"": "", ".ru": ""}
    For taskName in {"backup_1S_base": "", "getmail.cmd - Rarus Mail Loader": "", "stunnel": ""}
        Run %SystemRoot%\System32\schtasks.exe /Delete /TN "mobilmir%taskDirSuffix%\%taskName%" /F,, Min UseErrorLevel

For i,regview in regViews {
    SetRegView %regview%
    RegRead unCR, HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7C05EEDD-E565-4E2B-ADE4-0C784C17311C}, UninstallString
    If (unCR) {
	AddLog("Удаление Crystal Reports")
	RunWait "%A_AhkPath%" "%A_ScriptDir%\..\cleanup\uninstall\050 Crystal Reports.ahk"
	SetLastRowStatus(ErrorLevel,!ErrorLevel)
    }
}

If (A_OSVersion == "WIN_7") {
    SetRegView 64
    RegDelete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Setup\11.0, DoNotAllowIE11
    
    ;[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup\ScheduleParams\Rules\2]
    ;"Root"="D:\\Users\\Продавец\\Mail\\Thunderbird\\profile\\Mail\\Local Folders\\"
    ;"UniqueId"=""
    ;"Flags"=dword:c000016f
    rkWin7backup = HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup\ScheduleParams\Rules
    dirSuffixTBLocalFolders = \Mail\Thunderbird\profile\Mail\Local Folders
    setupMailBackup := 1, ruleMaxIdx := 0
    Loop Reg, %rkWin7backup%, K
    {
        If (A_LoopRegName > ruleMaxIdx)
            ruleMaxIdx := A_LoopRegName
        RegRead bkpDirRoot, %rkWin7backup%\%A_LoopRegName%, Root
        If (EndsWith(bkpDirRoot, dirSuffixTBLocalFolders) || EndsWith(bkpDirRoot, dirSuffixTBLocalFolders "\")) {
            setupMailBackup := 0
            break
        }
    }
    If (setupMailBackup) {
        ruleMaxIdx++
        bkpruleRoot := ""
        For i, dir in ["D:\Users\Продавец", "D:\Users\Пользователь", "D:"]
            If (FileExist(dir . dirSuffixTBLocalFolders . "\Archives.sbd")) {
                bkpruleRoot = dir . dirSuffixTBLocalFolders
                break
            }
        If (bkpruleRoot) {
            AddLog("Добавление правила архивации " dir "\…\Local Folders")
            RegWrite REG_DWORD, %rkWin7backup%\%ruleMaxIdx%, Flags, 0xc000016f
            RegWrite REG_SZ, %rkWin7backup%\%ruleMaxIdx%, Root, %bkpruleRoot%
            RegWrite REG_SZ, %rkWin7backup%\%ruleMaxIdx%, UniqueId,
            SetLastRowStatus(ErrorLevel,!ErrorLevel)
        }
    }
}

SetRegView Default

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

; try reading Distributives source from _get_SoftUpdateScripts_source.cmd
AddLog("Distributives", "_get_SoftUpdateScripts_source.cmd")
gsussScript := FirstExisting(A_AppDataCommon . "\mobilmir.ru\_get_SoftUpdateScripts_source.cmd", SystemDrive . "\Local_Scripts\_get_SoftUpdateScripts_source.cmd")
If (gsussScript) {
    SetLastRowStatus("(есть)", 1)
} Else {
    SetLastRowStatus("Не установлен!", 0)
    keepOpen := 1
}
Distributives := EnvGetAfterScript(gsussScript, "Distributives")
SetLastRowStatus(SubStr(Distributives, 1, -StrLen("\Distributives")), InStr(FileExist(Distributives), "D"))
If (!FileExist(Distributives "\Soft\PreInstalled\utils\7za.exe")) {
    AddLog("В локальной папке дистрибутивов нет 7za.exe", "будут исп. дистрибутивы с сервера")
    Distributives := officeDistSrvPath
    usingOfficeSrv := 1
}

exe7z:=find7zexe()
AddLog("7-Zip: " . exe7z)
FileGetVersion ver7z, %exe7z%
ver7z_ := StrSplit(ver7z, ".")
If (ver7z_[1] < 15) {
    SetLastRowStatus(ver7z, 0)
    AddLog("Требуется 7-Zip версии ≥15. Запуск обновления с сервера (office0)")
    RunWait %comspec% /C "%officeDistSrvPath%\Soft\Archivers Packers\7Zip\install.cmd",,Min UseErrorLevel
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

If (software_update_client_exec) {
    Loop Files, %software_update_client_exec%\_TeamViewerSecurityPasswordAES *.ahk
    {
        tvPassChangeLog = %A_Temp%\TeamViewerPasswordChange%A_Now%.log
        tvPassChangeErr := RunScript(A_LoopFileFullPath, "Проверка/обновление пароля TeamViewer", " /log """ tvPassChangeLog """", 0)
        Loop Read, %tvPassChangeLog%
            SetLastRowStatus(A_LoopReadLine, !tvPassChangeErr)
    }
}

;tv5settingsSubPath	:= "\Soft\Network\Remote Control\Remote Desktop\TeamViewer 5\settings.cmd"
;AddLog("Обновление настроек TeamViewer", StartsWith(tv5settingscmd, "\\Srv0") ? "Srv0" : SubStr(tv5settingscmd, 1, -StrLen(tv5settingsSubPath)))
;tv5settingscmd := FirstExisting(Distributives . tv5settingsSubPath, officeDistSrvPath . tv5settingsSubPath)
;RunWait %comspec% /C "%tv5settingscmd%", %A_Temp%, Min UseErrorLevel
;SetLastRowStatus(ErrorLevel ? ErrorLevel : "",!ErrorLevel)

If (FileExist("D:\Credit")) {
    AddLog("Перемещение ""D:\Credit"" в ""D:\Program Files\Credit""")
    FileMoveDir D:\Credit, D:\Program Files\Credit, 2
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}

If (FileExist("c:\squid")) {
    FileGetTime mtimeSquidConf, c:\squid\etc\squid.conf
    AddLog("Удаление squid", mtimeSquidConf, 1)
    
    RunWait c:\squid\sbin\squid.exe -r, c:\squid\sbin, Min UseErrorLevel
    If (ErrorLevel)
	SetLastRowStatus("Ошибка " ErrorLevel " при удалении службы", 0)
    Else {
	SetLastRowStatus("Служба удалена")
	RemoveDirsWithLog("c:\squid", "d:\squid")
    }
} Else {
    RunWait %SystemRoot%\System32\schtasks.exe /Delete /TN "squid_logrorate" /F,, Min UseErrorLevel
    RunWait %SystemRoot%\System32\schtasks.exe /Delete /TN "squid_reconfig" /F,, Min UseErrorLevel
    RunWait %SystemRoot%\System32\schtasks.exe /Delete /TN "squid_start" /F,, Min UseErrorLevel
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
	    RunScript("\\" SubStr(A_ComputerName, 1, -1) . "K\SoftUpdateScripts$\_install\install_software_update_scripts.cmd")
	} Else {
	    SetLastRowStatus(fnameLastStatus . " (сегодня)")
	}
    }
}

If (FileExist("D:\Scripts")) {
    s_uline := AddLog("D:\Scripts существует! Переустановка software_update")
    softUpdScripts := {}
} Else {
    softUpdScripts := CheckPath("D:\Local_Scripts\software_update\Downloader\_DistDownload.cmd", 1, 0)
    If (IsObject(softUpdScripts)) {
        If (FileExist("D:\Local_Scripts\software_update\software_update_scripts.ver")) { ; "d:\Scripts\ver.flag"
            ;15.08.2016 20:09
            FileRead verFlagSoftUpdScripts, *m16 D:\Local_Scripts\software_update\software_update_scripts.ver
            SetLastRowStatus(verFlagSoftUpdScripts, 0)
            
            runDistributivesCopy := true
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
}

If (IsObject(softUpdScripts)) { ; если обновлять скрипты software_update не надо, объект будет удален в блоке выше
    If (!IsObject(distSoftUpdScripts))
	distSoftUpdScripts := CheckPath(dirConfigDistSrv "\_Scripts\software_update_autodist\downloader-dist.7z", 0, 0)
    If (IsObject(distSoftUpdScripts)) {
	distSoftUpdScripts.path := DefaultConfigDir . "\_Scripts\software_update_autodist\downloader-dist.7z"
	SetRowStatus(distSoftUpdScripts.line, "Обновляется", 0)
	RunWait %comspec% /C "%DefaultConfigDir%\_Scripts\software_update_autodist\SetupLocalDownloader.cmd",, Min UseErrorLevel
	SetRowStatus(distSoftUpdScripts.line, ErrorLevel ? ErrorLevel : timeDistSoftUpdScripts, ErrorLevel=0)

        If (s_uline) {
            FileMoveDir D:\Scripts, %A_Temp%\Scripts, R
            SetRowStatus(s_uline,"Перемещено в Temp текущего пользователя",!ErrorLevel)
        }
    }
}

;If (FileExist("D:\Local_Scripts\software_update"))
;    RunScript("D:\Local_Scripts\software_update\client_exec\PCX-1.13.3310-win32.msi.ahk")

If (IsObject(rsyncPreinstalled)) { ; pidRsyncPreinstalled
    AddLog("Ожидание завершения rsync PreInstalled")
    RunRSyncWithAddLog(rsyncPreinstalled)
}

;If (FileExist("D:\1S\Утилиты Вики-Принт\Fito 2.2.26")) {
;    AddLog("Fito 2.2.26", "уже установлен", 1)
;} Else If (FileExist("D:\Local_Scripts\software_update\client_exec\_Fito 2.2.26.ahk")) {
;        RunScript("D:\Local_Scripts\software_update\client_exec\_Fito 2.2.26.ahk", "Установка Fito 2.2.26")
;}

If (!((gpgexist := FileExist("C:\SysUtils\gnupg\gpg.exe")) && IsObject(softUpdScripts))) ; Если IsObject(softUpdScripts), SysUtils уже были обновлены выше
    RunScriptFromNewestDistDir("Soft\PreInstalled\auto\SysUtils\*.7z", "Soft\PreInstalled\SysUtils-cleanup and reinstall.cmd", "PreInstalled", gpgexist ? SystemDrive . "\SysUtils" : "", loopOptn:="DFR")
RunFromConfigDir("_Scripts\unpack_retail_files_and_desktop_shortcuts.cmd", "Замена ярлыков и распаковка стандартных скриптов")
;-- должен устранавливаться скриптом unpack_retail_files_and_desktop_shortcuts.cmd -- RunFromConfigDir("_Scripts\ScriptUpdater_dist\InstallScriptUpdater.cmd", "ScriptUpdater") 
CheckRemoveSchedulerTask("mobilmir\AddressBook")
RunFromConfigDir("_Scripts\Tasks\All XML.cmd", "Обновление задач планировщика")
RunFromConfigDir("_Scripts\Tasks\AddressBook_download.cmd")
RunWait %SystemRoot%\System32\NET.exe SHARE AddressBook$ /DELETE,,Min UseErrorLevel
If (!ErrorLevel) {
    abDir = D:\Mail\Thunderbird\AddressBook
    AddLog("Настройка доступа к " abDir, "Настройка \\…\AddressBook$")
    RunWait %SystemRoot%\System32\NET.exe SHARE AddressBook$="%abDir%" /GRANT:Everyone`,READ,,Min UseErrorLevel
    If (ErrorLevel)
	RunWait %SystemRoot%\System32\NET.exe SHARE AddressBook$="%abDir%" /GRANT:Все`,READ,,Min UseErrorLevel
    If (ErrorLevel)
	RunWait %SystemRoot%\System32\NET.exe SHARE AddressBook$="%abDir%",,Min UseErrorLevel
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
	RunWait %SystemRoot%\System32\takeown.exe /A /R /D Y /F "%abDir%",,Min UseErrorLevel
	RunWait %SystemRoot%\System32\icacls.exe "%abDir%" /reset /T /C /L,,Min UseErrorLevel
	RunWait %SystemRoot%\System32\icacls.exe "%abDir%" /inheritance:r /C /L,,Min UseErrorLevel
	RunWait %SystemRoot%\System32\icacls.exe "%abDir%" /setowner "*%sidAdministrators%" /T /C /L,,Min UseErrorLevel
	RunWait %SystemRoot%\System32\icacls.exe "%abDir%" /grant "*%sidAdministrators%:(OI)(CI)F" /grant "*%sidSYSTEM%:(OI)(CI)F" /grant "*%sidEveryone%:(OI)(CI)R" /C /L,,Min UseErrorLevel
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

If (FileExist(SystemRoot . "\System32\Tasks\mobilmir.ru\update dealer.beeline.ru criacx.ocx")) {
    AddLog("Удаление задачи планировщика ""update dealer.beeline.ru criacx.ocx""")
    RunWait %SystemRoot%\System32\schtasks.exe /Delete /TN "mobilmir.ru\update dealer.beeline.ru criacx.ocx" /F,,Min UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}
If (IsObject(instCriacxocx := CheckPath(FirstExisting("d:\dealer.beeline.ru\bin\CRIACX.ocx", SystemRoot . "\SysNative\criacx.ocx", SystemRoot . "\System32\criacx.ocx", SystemRoot . "\SysWOW64\criacx.ocx"), 0))) {
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

If (A_IsAdmin) {
    RunScriptFromNewestDistDir("Soft com freeware\MultiMedia\Plugins Frameworks Components\Adobe Flash\uninstaller\*.exe"
			     , "Soft com freeware\MultiMedia\Plugins Frameworks Components\Adobe Flash\uninstaller\uninstall_flash_player.cmd"
			     , "Удаление Flash Player")

    If (runDistributivesCopy)
        RunFromConfigDir("_Scripts\CopyDistributives_AllSoft.cmd", "Обновление дистрибутивов ПО")

    If (runAhkUpdate) {
        RunRsyncAutohotkey()
        RunScriptFromNewestDistDir(subdirDistAutoHotkey "\*.exe", subdirDistAutoHotkey "\install.cmd", "Обновление Autohotkey")
    }
}

finished := 1
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

CheckRemoveSchedulerTask(taskname) {
    If (FileExist(SystemRoot "\System32\Tasks\" taskname)) {
        AddLog("Удаление задачи планировщика " taskname "…")
        RunWait %SystemRoot%\System32\schtasks.exe /Delete /TN "%taskname%" /F,, Min UseErrorLevel
        SetLastRowStatus(ErrorLevel,!ErrorLevel)
    }
}

RunRsyncAutohotkey(wait := 1) {
    global subdirDistAutoHotkey, lDistributives, officeDistSrvPath
    static upToDate := 0, baseDirsDistAhk := ""
    
    If (!baseDirsDistAhk) {
	baseDirsDistAhk := [ "D:\Distributives" ]
	If (lDistributives && !(SubStr(lDistributives, 1, 2)=="\\"))
	    baseDirsDistAhk.Push(lDistributives)
    }
    ;AddLog("RunRsyncAutohotkey baseDirsDistAhk: " ObjectToText(baseDirsDistAhk))
    
    bakWorkDir = %A_WorkingDir%
    SetWorkingDir %officeDistSrvPath%\%subdirDistAutoHotkey%
    For i, baseDir in baseDirsDistAhk {
	If (InStr(FileExist(localDist := baseDir "\" subdirDistAutoHotkey), "D")) {
	    needSync := 0
	    Loop Files, *.*, R
	    {
		srvMT := A_LoopFileTimeModified, srvSz := A_LoopFileSize
		Loop Files, %localDist%\%A_LoopFileFullPath%
		    If (!(srvMT == A_LoopFileTimeModified && srvSz == A_LoopFileSize)) {
			needSync := 1
			break
		    }
	    } Until needSync
	    
	    If (needSync) {
		AddLog("rsync AutoHotkey, PreInstalled → " baseDir . (wait ? "" : " в фоне"))
		Try {
		    RunRSync(baseDir "\" subdirDistAutoHotkey, wait)
		    RunRSync(baseDir "\Soft\PreInstalled\utils", wait)
		    RunRSync(baseDir "\Soft\PreInstalled\auto", wait)
		    baseDirsDistAhk := [ baseDir ], rsyncErr := ""
		    break
		} Catch e
		    rsyncErr := e
	    } Else
		AddLog("AutoHotkey @ " baseDir " актуальный")
	}
    }
    If (rsyncErr)
	SetLastRowStatus(ObjectToText(e), 0)
    Else
	SetLastRowStatus()
    SetWorkingDir %bakWorkDir%
}

RunRSyncWithAddLog(dir, wait := 1) {
    row := AddLog("rSync """ AbbreviatePath(dir) """" (wait ? "" : " в фоне"))
    Try {
	RunRSync(dir, wait)
	SetLastRowStatus()
    } Catch e
	SetLastRowStatus(ObjectToText(e), 0)
}

RunRSync(dir, wait := 1) {
    global DefaultConfigDir
    static runningRsyncs := {}
	 , rsyncScript := ""
	 , maxLineLength := 100
    
    If (IsObject(dir)) {
	runningRsync := dir
	dir := runningRsync.dir
    } Else {
	If (!rsyncScript)
	    rsyncScript := DefaultConfigDir "\_Scripts\rSync_DistributivesFromSrv0.cmd"
	If (SubStr(dir, 1, 2) == "\\")
	    Throw Exception("rsync работает только с локальными папками",, dir)
	
	If (runningRsyncs.HasKey(dir)) {
	    runningRsync := runningRsyncs[dir]
	} Else {
	    Random rnd, 0, 0xFFFF
	    rndid := Format("{:.5i}-{:.4x}", A_TickCount, rnd)
	    For i, fname in [ ".sync.excludes", ".sync.includes", ".sync" ]
		Try FileDelete %dir%\%fname%
	    If (wait)
		RunWait %comspec% /C "TITLE "%rsyncScript%" & "%rsyncScript%" "%dir%" || ECHO ! >"%A_Temp%\%A_ScriptName%.%rndid%.rsync.log" 2>&1", %dir%, Min UseErrorLevel
	    Else
		Run %comspec% /C "TITLE "%rsyncScript%" & "%rsyncScript%" "%dir%" || ECHO ! >"%A_Temp%\%A_ScriptName%.%rndid%.rsync.log" 2>&1", %dir%, Min UseErrorLevel
	    
	    runningRsync := {rndid: rndid, dir: dir}
	}
    
	runningRsyncs[dir] := runningRsync
    }
    If (wait) {
	If (!rndid)
	    rndid := runningRsync.rndid
	logpath := A_Temp "\" A_ScriptName "." rndid ".rsync.log"
	Loop
	{
	    Sleep 300
	    Try logf := FileOpen(logpath, "r-")
	} Until IsObject(logf) || !FileExist(logpath)
	If (!runningRsync)
	    runningRsync := runningRsyncs[dir]
	runningRsyncs.Delete(dir)
	
	logf.Seek(-10) ; 3 bytes from end, Origin is end by default when position is negative
	flag := logf.Read(10)
	If (InStr(flag, "!")) {
	    logf.Seek(-maxLineLength)
	    lastStatus := logf.Read(maxLineLength)
	    lastStatus := SubStr(lastStatus, InStr(lastStatus, "`n",, 0) + 1) ; from last `n to end of line
	    logf.Close()
	    Throw Exception("rsync returned error",, "(last line) " lastStatus ", for more see " logpath)
	}
	logf.Close()
    }
    
    If (lastStatus)
	runningRsync.lastStatus := lastStatus
    
    return runningRsync
}

RunScriptFromNewestDistDir(ByRef distSubpath, ByRef scriptSubpath, title:="", flagMask:="", optnLoopFlag:="") {
    global officeDistSrvPath, Distributives, lDistributives
    static distDirs := ""
    latestFlagTime := 0
    , chkMTimes    := []
    , latestTime   := 0
    
    If (!IsObject(distDirs)) {
	distDirs := []
	prevDir := ""
	For i, dir in [lDistributives, Distributives, officeDistSrvPath] {
	    If (dir && !(dir==prevDir) && InStr(FileExist(dir), "D")) {
		distDirs.Push(dir)
		prevDir := dir
	    }
	}
    }
    ;MsgBox % ObjectToText(distDirs)
    
    If (!title)
	title := AbbreviatePath(flagMask ? flagMask : distSubpath)
    logline := AddLog(title, "Проверка")
    For i, distDir in distDirs
	If (distDir) {
	    FindLatest(distDir "\" distSubpath,, mtime := -1), chkMTimes[i] := mtime
	    If (latestTime < mtime) {
		latestTime := mtime
		latestDist := distDir
	    }
	}
    ;MsgBox latestTime: %latestTime%`nmtime: %mtime%`nlatestDist: %latestDist%
    SetRowStatus(logline, latestTime)
    If (flagMask) { ; если флаг не старше самого свежего найденного файла в дистрибутивах, запускать скрипт не требуется
	FindLatest(flagMask, optnLoopFlag, latestFlagTime)
	If (latestFlagTime) {
	    timeDiff := latestTime
	    timeDiff -= latestFlagTime, Minutes
	}
    }
    
    If (!latestFlagTime || timeDiff > 1) { ; если в дистрибутивах есть файл новоее флага больше, чем на 1 минуту, запускать скрипт
	SetRowStatus(logline, "← " AbbreviatePath(latestDist), 0)
	RunWait %comspec% /C "%latestDist%\%scriptSubpath%", %A_Temp%, Min UseErrorLevel
	return {run: 1, ErrorLevel: ErrorLevel, latestDist: latestDist, logline: logline} ; , (ErrorLevel ? SetLastRowStatus(ErrorLevel, 0) : SetLastRowStatus())
    } Else
        return {run: 0, latestFlagTime: latestFlagTime, logline: logline}, SetRowStatus(logline, TimeFormat(latestFlagTime), 1)
}

RunFromConfigDir(ByRef subPath, ByRef logLineText:="", ByRef args:="") {
    global DefaultConfigDir, dirConfigDistSrv
    
    runSc := LatestExisting(DefaultConfigDir "\" subPath, dirConfigDistSrv "\" subPath)
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

DeleteWithLog(ByRef paths*) {
    errors := 0
    For i, path in paths
        If (FileExist(path)) {
            AddLog("Удаление """ path """")
            FileDelete %path%
            errors := ErrorLevel || errors
            SetLastRowStatus(errors += ErrorLevel,!ErrorLevel)
        }
    return !errors
}

RemoveDirsWithLog(ByRef paths*) {
    For i, path in paths
        If (FileExist(path)) {
            AddLog("Удаление " path)
            FileRemoveDir %path%, 1
            errors := ErrorLevel || errors
            SetLastRowStatus(ErrorLevel, !ErrorLevel)
        }
    return !errors
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

FindLatest(mask, loopOptn := "", ByRef latestTime := 0) { ; FindLatest(,, -1) to avoid adding missing masks to log
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
    } Else If (latestTime == 0) {
	AddLog(AbbreviatePath(mask), "Не найдено подходящих файлов")
    }
}

AbbreviatePath(path) {
    global DefaultConfigDir
    path := RegExReplace(path, "i)^\\\\Srv0(\.office0\.mobilmir)?\\(profiles\$(\\Share)?|Distributives)?\\","{Srv0}")
    path := RegExReplace(path, "i)^\\\\Srv1S-B(\.office0\.mobilmir)?\\(Users\\Public\\Shares\\profiles\$(\\Share)?|Distributives)?\\","{Srv1S-B}")
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
    FormatTime ft, %time%, yyyy-MM-dd HH:mm '(%age%)'
    return ft
}

FirstExisting(paths*) {
    for index,path in paths
	If (FileExist(path))
	    return path
    
    return
}

FirstContaining(subpath, paths*) {
    for index,path in paths
	If (FileExist(path "\" subpath))
	    return path
    
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

StartsWith(longstr, shortstr) {
    return SubStr(longstr, 1, StrLen(shortstr)) = shortstr
}

EndsWith(longstr, shortstr) {
    return SubStr(longstr, 1-StrLen(shortstr)) = shortstr
}

#include %A_LineFile%\..\..\..\_Scripts\Lib\RtlGetVersion.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\getDefaultConfig.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\find7zexe.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\ObjectToText.ahk
;#include %A_LineFile%\..\..\..\_Scripts\Lib\find_exe.ahk
