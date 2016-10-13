;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

reqdConfigName=Apps_dept.7z
pathSrvConfigUpdater=\\Srv0.office0.mobilmir\profiles$\Share\config\update local config.cmd
maxAgeSavedInvReport=1
tv5settingsSubPath = \Soft\Network\Remote Control\Remote Desktop\TeamViewer 5\settings.cmd
scriptInventoryReport = \\Srv0.office0.mobilmir\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd
maskInventoryReport = \\Srv0.office0.mobilmir\profiles$\Share\Inventory\collector-script\Reports\%A_ComputerName% *.7z

chkDefConfigDir := CheckPath(getDefaultConfigDir())
global DefaultConfigDir := chkDefConfigDir.path

Gui Add, ListView, Checked Count100 -Hdr -E0x200 -Multi NoSortHdr NoSort R30 w600 vLogListView, Операция|Статус
Gui Show

OSVersionObj := RtlGetVersion()
AddLog("Запуск на Win" . OSVersionObj[2] . "." . OSVersionObj[3] . "." . OSVersionObj[4],A_Now,1)
AppXSupported := OSVersionObj[2] > 6 || (OSVersionObj[2] = 6 && OSVersionObj[3] >= 2) ; 10 or 6.[>2] : 6.0 = Vista, 6.1 = Win7, 6.2 = Win8

xlnexe := findexe("xln.exe", "C:\SysUtils")
If (xlnexe)
    AddLog("xln.exe: " . xlnexe, , 1)
DriveSpaceFree dfc, C:\
AddLog("Свободно на C:", dfc . " MB", dfc > 1536)
DriveSpaceFree dfd, D:\
AddLog("Свободно на D:", dfd . " MB", dfd > 1536)
DriveSpaceFree dfr, R:\
AddLog("Свободно на R:", dfr ? dfr . " MB" : "", dfr > 1536)

serverScriptPath = \\Srv0.office0.mobilmir\profiles$\Share\config\Users\depts\update_beeline_activex_and_desktop_shortcuts.ahk

AddLog("Скрипт на Srv0")
FileGetTime timestampServerScript, %serverScriptPath%
SetLastRowStatus(timestampServerScript)

AddLog("Работающий скрипт")
FileGetTime timestampRunningScript, %A_ScriptFullPath%

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
    SetLastRowStatus(timestampRunningScript)
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

sendemailcfg := CheckPath("d:\1S\Rarus\ShopBTS\ExtForms\post\sendemail.cfg")
If (IsObject(sendemailcfg)) {
    AddLog("Запуск ShopBTS_Add.install.ahk /skipSchedule")
    Run "%A_AhkPath%" "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\D_1S_Rarus_ShopBTS\ShopBTS_Add.install.ahk" /skipSchedule,,UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
    If (ErrorLevel)
	keepOpen := 1
}

userFoldersChk := AddLog("Проверка папок пользователя")
Loop Reg, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
{
    RegRead path
    If (!FileExist(Expand(path))) {
	AddLog(path, A_LoopRegName)
	userFoldersChk=
	keepOpen := 1
    }
}
If (userFoldersChk) {
    SetLastRowStatus()
} Else {
    MsgBox 4, %A_ScriptName%, Некоторые папки пользователя недоступны. Из-за этого могут также не работать библиотеки.`n`nСбросить пути к папкам пользователя на стандартные?
    IfMsgBox Yes
    {
	RunWait "%A_AhkPath%" "%A_ScriptDir%\..\..\_Scripts\MoveUserProfile\reset HKCU folders.ahk"
	If (!ErrorLevel)
	    keepOpen := 0
    }
}

RegRead OneDriveSetup, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, OneDriveSetup
If (!ErrorLevel) {
    AddLog("OneDriveSetup в автозагрузке", "Удаление")
    RegDelete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, OneDriveSetup
    FileRemoveDir D:\Users\Пользователь\AppData\Local\Microsoft\OneDrive, 1
    If (ErrorLevel)
	keepOpen := 1
    SetLastRowStatus(ErrorLevel)
}

If (AppXSupported && (A_UserName="Продавец" || A_UserName="Пользователь")) {
    AddLog("Запуск удаления всех приложений AppX")
    Run %comspec% /C "TITLE Удаление всех приложений AppX & "%DefaultConfigDir%\_Scripts\cleanup\AppX\Remove All AppX Apps for current user.cmd" /Quiet",, Min UseErrorLevel, removeAppXPID
    If (ErrorLevel)
	keepOpen := 1
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}

If (!A_IsAdmin) {
    AddLog("Скрипт запущен **без** прав администратора",A_UserName,1)
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    If (removeAppXPID)
	WaitProcessEnd(removeAppXPID, "Ожидание завершения скрипта удаления AppX")
    AddLog("Перезапуск от имени администратора…")
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    If (keepOpen)
	Exit
    ExitApp
}
AddLog("Скрипт запущен с правами администратора",A_UserName,1)

AddLog(A_AhkPath, A_AhkVersion)
If (A_AhkVersion < "1.1.21") {
    AddLog("Запуск обновления с Srv0.office0.mobilmir.")
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    RunWait %comspec% /C "PING Srv0.office0.mobilmir -n 5 & CALL "\\Srv0.office0.mobilmir\Distributives\Soft\Keyboard Tools\AutoHotkey\install.cmd" & CALL "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\auto\AutoHotkey_Lib.cmd" & %ScriptRunCommand%",,Min UseErrorLevel
    If (ErrorLevel) {
	LV_Modify(LV_GetCount(),,,ErrorLevel)
	MsgBox Ошибка "%ErrorLevel%" при обновлении AutoHotkey. Автоматическое продолжение невозможно.
	ExitApp
    } Else {
	SetLastRowStatus()
    }
    MsgBox Запущено обновление AutoHotkey и перезапуск скрипта. Это окно должно само исчезнуть.
    Reload
}
SetLastRowStatus()

If (FileExist(scriptInventoryReport)) {
    prevSavedInvReport := FindLatest(maskInventoryReport)
    If (IsObject(prevSavedInvReport)) {
	ageSavedInvReport=
	EnvSub ageSavedInvReport,prevSavedInvReport,Days
	AddLog("Возраст отчёта об инвентаре", ageSavedInvReport . " дн.", ageSavedInvReport <= maxAgeSavedInvReport)
    }
    
    If (!IsObject(prevSavedInvReport) || ageSavedInvReport > maxAgeSavedInvReport) {
	SetLastRowStatus("Не найден, сбор информации")
	Run %comspec% /C "TITLE Сбор информации о компьютере&"%scriptInventoryReport%"",,Min UseErrorLevel
	SetLastRowStatus(ErrorLevel,!ErrorLevel)
    }
}

; try reading Distributives source from _get_SoftUpdateScripts_source.cmd
EnvGet SystemDrive, SystemDrive
AddLog("Distributives", "Searching _get_SoftUpdateScripts_source.cmd")
gsussScript := FirstExisting(A_AppDataCommon . "\mobilmir.ru\_get_SoftUpdateScripts_source.cmd", SystemDrive . "\Local_Scripts\_get_SoftUpdateScripts_source.cmd")
LV_Modify(LV_GetCount(),,gsussScript)
Distributives := EnvGetAfterScript(gsussScript, "Distributives")
SetLastRowStatus(SubStr(Distributives, 1, -StrLen("\Distributives")))
If (!FileExist(Distributives . "\Soft\PreInstalled\utils\7za.exe")) {
    Distributives=\\Srv0.office0.mobilmir\Distributives
    AddLog("В локальной папке дистрибутивов нет Preinstalled\*\7za.exe", "→ использовать Srv0")
}

exe7z:=find7zexe()
AddLog("7-Zip: " . exe7z)
FileGetVersion ver7z, %exe7z%
ver7z_ := StrSplit(ver7z, ".")
If (ver7z_[1] < 15) {
    SetLastRowStatus(ver7z, 0)
    AddLog("Требуется 7-Zip версии ≥15. Запуск обновления с Srv0.office0.mobilmir.")
    RunWait %comspec% /C "\\Srv0.office0.mobilmir\Distributives\Soft\Archivers Packers\7Zip\install.cmd",,Min UseErrorLevel
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
    runConfUpdScript:= locConfigUpdater
} Else {
    SetLastRowStatus("Устаревший", 0)
    runConfUpdScript := srvConfigUpdater
}

LV_Modify(runConfUpdScript.line,,,"Выполняется")
cmdupdateDefaultConfig := runConfUpdScript.path
RunWait %comspec% /C "%cmdupdateDefaultConfig%",,Min
SetRowStatus(runConfUpdScript.line, ErrorLevel)
CheckUpdateDefaultConfigName(reqdConfigName)

If (FileExist("D:\Credit")) {
    AddLog("Перемещение ""D:\Credit"" в ""D:\Program Files\Credit""")
    FileMoveDir D:\Credit, D:\Program Files\Credit, 2
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}

sharePublic := CheckPath("D:\Users\Public", 0)
If (!IsObject(sharePublic)) {
    If (FileExist("W:\Media")) {
	AddLog("Обнаружена папка W:\Media")
	RunWait "%xlnexe%" -n W:\Media D:\Users\Public,,Min UseErrorLevel
	AddLog("Создание ссылки D:\Users\Public",ErrorLevel,!ErrorLevel)
    }
    If (FileExist("W:\Обмен")) {
	AddLog("Обнаружена папка W:\Обмен", "Перемещение")
	Loop Files, W:\Обмен, D
	    FileMoveDir %A_LoopFileFullPath%, W:\Media\Documents\%A_LoopFileName%, R
	FileMove W:\Обмен\*.*, W:\Media\Documents
	FileRemoveDir W:\Обмен
	If (FileExist("W:\Обмен")) {
	    ;if it still exist, some files are in-use or duplicated in Documents
	    LV_Modify(LV_GetCount(),,,"Не перемещено")
	    AddLog("Создание ссылки W:\Обмен → ""W:\Media\Documents\старый обмен""")
	    RunWait "%xlnexe%" -n W:\Обмен "W:\Media\Documents\старый обмен",,Min UseErrorLevel
	    SetLastRowStatus(ErrorLevel,!ErrorLevel)
	} Else {
	    SetLastRowStatus()
	}
    }
}

If (FileExist("D:\1S\Rarus\ShopBTS\*.dbf")) {
    AddLog("Найден Рарус, замена Rarus_Scripts")
    Run "%A_AhkPath%" "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\Rarus_Scripts_unpack.ahk",,UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
    EnvSet Inst1S,1
}

AddLog("Ярлыки на рабочем столе и стандартные файлы","Замена")
RunWait %comspec% /C ""%DefaultConfigDir%\_Scripts\unpack_retail_files_and_desktop_shortcuts.cmd"", %DefaultConfigDir%\_Scripts, Min UseErrorLevel
SetLastRowStatus(ErrorLevel,!ErrorLevel)

instCriacxocx := CheckPath(FirstExisting("d:\dealer.beeline.ru\bin\CRIACX.ocx", A_WinDir . "\SysNative\criacx.ocx", A_WinDir . "\System32\criacx.ocx", A_WinDir . "\SysWOW64\criacx.ocx"))
If (IsObject(instCriacxocx)) {
    AddLog("d:\dealer.beeline.ru\update_dealer_beeline_activex.cmd")
    RunWait %comspec% /C "d:\dealer.beeline.ru\update_dealer_beeline_activex.cmd", d:\dealer.beeline.ru, Min UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
    
    ;FileGetTime criacxocxTimeDiff, instCriacxocx.path
    ;EnvSub criacxocxTimeDiff, instCriacxocx.mtime, Days
    ;SetRowStatus(instCriacxocx.line, criacxocxTimeDiff ? "обновился" : "не обновился",criacxocxTimeDiff > 0)
} Else {
    AddLog("CRIACX.ocx","отсутствует",1)
}

tv5settingscmd := FirstExisting(Distributives . tv5settingsSubPath, "\\Srv0.office0.mobilmir\Distributives" . tv5settingsSubPath)
AddLog("Обновление настроек TeamViewer 5", StartsWith(tv5settingscmd, "\\Srv0") ? "Srv0" : SubStr(tv5settingscmd, 1, StrLen(Distributives)))
RunWait %comspec% /C "%tv5settingscmd%", %A_Temp%, Min UseErrorLevel
SetLastRowStatus(ErrorLevel ? ErrorLevel : "",!ErrorLevel)

softUpdScripts := CheckPath("d:\Scripts\_DistDownload.cmd", 1, 0)
If (IsObject(softUpdScripts)) {
    If (FileExist("d:\Scripts\ver.flag")) {
	;15.08.2016 20:09
	FileRead verFlagSoftUpdScripts, *m16 d:\Scripts\ver.flag
	SetLastRowStatus(verFlagSoftUpdScripts,0)
    }
    
    distSoftUpdScripts := CheckPath(DefaultConfigDir . "\_Scripts\software_update_autodist\Scripts.7z")
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

If (IsObject(softUpdScripts)) {
    If (!IsObject(distSoftUpdScripts))
	distSoftUpdScripts := CheckPath("\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\software_update_autodist\Scripts.7z", 0, 0)
    If (IsObject(distSoftUpdScripts)) {
	distSoftUpdScripts.path := DefaultConfigDir . "\_Scripts\software_update_autodist\Scripts.7z"
	SetRowStatus(distSoftUpdScripts.line, "Обновляется", 0)
	RunWait %comspec% /C "%DefaultConfigDir%\_Scripts\software_update_autodist\SetupLocalDownloader.cmd",,Min UseErrorLevel
	SetRowStatus(distSoftUpdScripts.line, ErrorLevel ? ErrorLevel : timeDistSoftUpdScripts, ErrorLevel=0)
    }
}

AddLog("Журналы скриптов обновления")
EnvGet ProgramData,ProgramData
suSettingsScript=%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd
hostSUScripts:=ReadSetVarFromBatchFile(suSettingsScript, "SUSHost")
If (hostSUScripts) {
    SetLastRowStatus(hostSUScripts, 0)
    RunWait %comspec% /C "%A_ScriptDir%\..\..\_Scripts\software_update_autodist\CheckLocalUpdater.cmd",,Min UseErrorLevel
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

AddLog("Common_Scripts")
Loop Files, %A_AppDataCommon%\mobilmir.ru\Common_Scripts
{
    If (latestCommonScript < A_LoopFileTimeModified || !latestCommonScript)
	latestCommonScript := A_LoopFileTimeModified
}
FileGetTime mtimeCommonScriptsSrv0, \\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\auto\Common_Scripts.7z
FileGetTime mtimeCommonScriptslocal, %Distributives%\Soft\PreInstalled\auto\Common_Scripts.7z
If (mtimeCommonScriptsSrv0 > latestCommonScript) {
    SetLastRowStatus("Обновление",0)
    If (mtimeCommonScriptslocal==mtimeCommonScriptsSrv0)
	RunWait %comspec% /C "%Distributives%\Soft\PreInstalled\auto\Common_Scripts.cmd",,Min UseErrorLevel
    Else
	RunWait %comspec% /C "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\auto\Common_Scripts.cmd",,Min UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
} Else {
    SetLastRowStatus()
}

If (removeAppXPID)
    WaitProcessEnd(removeAppXPID, "Ожидание завершения скрипта удаления AppX")
If (AppXSupported) { ; 10 or 6.[>2] : 6.0 = Vista, 6.1 = Win7, 6.2 = Win8
    AddLog("Удаление лишних приложений AppX")
    RunWait %comspec% /C "TITLE Удаление лишних приложений AppX & "%DefaultConfigDir%\_Scripts\cleanup\AppX\Remove AppX Apps except allowed.cmd" /Quiet",, Min UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}

If (OSVersionObj[2] != 10 || OSVersionObj[2] != 0 || OSVersionObj[3] != 14393) { ; On Win 10 [1607] Start menu stops working after this
    AddLog("Запуск в фоновом режиме настройки ACL ФС")
    Run %comspec% /C "TITLE Настройка параметров безопасности файловой системы & "%DefaultConfigDir%\_Scripts\Security\_depts_simplified.cmd"",, Min UseErrorLevel
    SetLastRowStatus(ErrorLevel,!ErrorLevel)
}

finished := 1
AddLog("Готово",A_Now,1)
Exit

;Loop
;{
;    InputBox rmtHost, Remote Host
;    IF (ErrorLevel || rmtHost=="")
;	break
;    If (!(SubStr(rmtHost, 1, 2)=="\\"))
;	rmtHost = \\%rmtHost%

;    Run %comspec% /C "CALL "D:\dealer.beeline.ru\remote_register.cmd" %rmtHost% || PAUSE", D\dealer.beeline.ru
;}


GuiEscape:
GuiClose:
ButtonCancel:
    If (!finished) {
	MsgBox 0x134, %A_ScriptName%, Скрипт ещё работает. Точно выйти?
	IfMsgBox No
	    return
    }
    ExitApp

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
	configCheck := configName=reqdConfigName
	AddLog("Путь к файлу конфигурации: " . DefaultConfig, configName, configCheck)
	If (!configCheck) {
	    MsgBox 4, %A_ScriptName%, В розничных отделах название локального файла конфигурации должно быть %reqdConfigName%`, но на этом компьютере файл конфигурации (полный путь): %DefaultConfig%`n`nИзменить на "%configDir%\%reqdConfigName%"?
	    IfMsgBox Yes
	    {
		FileDelete %A_AppDataCommon%\mobilmir.ru\_get_defaultconfig_source.cmd
		FileAppend SET "DefaultsSource=%configDir%\%reqdConfigName%"`n,%A_AppDataCommon%\mobilmir.ru\_get_defaultconfig_source.cmd, CP866
		continue
	    }
	}
	break
    }
    DefaultConfigDir := configDir
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
    FileDelete %outFile%
    FileDelete %tempFile%
    return Trim(out, "`r`n`t ")
}

StartsWith(longstr, shortstr) {
    return SubStr(longstr, 1, StrLen(shortstr)) = shortstr
}

ShortenSrv0(path) {
    return RegExReplace(path, "i)^\\\\Srv0(\.office0\.mobilmir)?\\(profiles\$(\\Share)?|Distributives|)?\\","{Srv0}")
}

CheckPath(path, logTime:=1, checkboxIfExist:=1) {
    If (!path)
	return
    exist := FileExist(path)
    If (exist)
	FileGetTime mtime, %path%
    line := AddLog(ShortenSrv0(path), logTime ? mtime : exist, checkboxIfExist & (exist!=""))
    If (exist)
	return {"path":path, "attr":exist, "mtime":mtime, "line":line}
    Else
	return
}

FindLatest(path, flags:="") {
    Loop Files, %path%, %flags%
    {
	If (A_LoopFileTimeModified > latestTime) {
	    latestPath := A_LoopFileFullPath
	    latestMTime := A_LoopFileTimeModified
	}
    }
    
    If (latestPath) {
	objLatest := {"path":latestPath, "attr":FileExist(latestPath), "mtime":latestMTime, "line":line}
	
    } Else {
	AddLog(ShortenSrv0(path), "Не найден")
    }
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

SetRowStatus(row, status:="", check:=1) {
    If (status=0) {
	status=OK
    } Else If (RegexMatch(status,"^[\d\-]{1-7}$")) {
	status=! %status%
    }
    
    If (status=="")
	return LV_Modify(row, check ? "Check" : "")
    Else
	return LV_Modify(row, check ? "Check" : "",,status)
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
#Include %A_LineFile%\..\..\..\_Scripts\Lib\getDefaultConfig.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\find7zexe.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
