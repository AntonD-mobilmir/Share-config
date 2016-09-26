;Install Adobe Flash Player NPAPI Plugin and/or ActiveX
; usage:
; install.ahk [swtich [swtich […]]]
; switch: /[no]flag OR -[no]flag
; each switch sets a flag to 1 (true) without "no", or to 0 (false) with "no"
; Available flags:
;RunInteractiveInstalls	- if not 0, asks for elevation of privilegies if needed, and message boxes shown with queries to install components and set settings.
;			  if 0, script runs completely non-interactive.
;installActiveX		- run Install of ActiveX component. If not specified, it's only run if an older version is currently installed
;installPlugin		- run Install of NPAPI plugin component. If not specified, it's only run if an older version is currently installed
;SetSystemSettings	- unregisters NPSWF32.dll and removes AdobeFlashPlayerUpdateSvc service and fixes HKCR\MIME. 0 by default. 
;
; example: install.ahk /installActiveX /NoRunInteractiveInstalls
; 	installActiveX always installed, NPAPI Plugin in only installed if it's already installed, but older version than current distributive, and no are not modified by script (updater)
; example: install.ahk /NoRunInteractiveInstalls /SetSystemSettings
; 	both ActiveX and NPAPI plugins updated (only if already installed) and flash updater removed from system.

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

System32=%A_WinDir%\SysWOW64
If (!FileExist(System32))
    System32=%A_WinDir%\System32
FlashPlayerFilesLocation=%System32%\Macromed\Flash

Loop Files, %FlashPlayerFilesLocation%\NPSWF32*.dll
{
    PathPlugin:=A_LoopFileLongPath
    break
}
Loop Files, %FlashPlayerFilesLocation%\*.ocx
{
    PathActiveX:=A_LoopFileLongPath
    break
}
Loop Files, %A_ScriptDir%\install_flash_player_*_plugin.exe
    PathPluginDist=%A_LoopFileFullPath%
Loop Files, %A_ScriptDir%\install*active_x.exe
    PathActiveXDist=%A_LoopFileFullPath%

If %0%
{
    RunInteractiveInstalls=0
    Loop %0%
    {
	If (SkipNext=1) {
	    SkipNext=0
	    continue
	}
	arg:=%A_Index%
	FlagMarker:=SubStr(arg,1,1)
	If FlagMarker in /,-
	{
	    CurrentSwitch:=SubStr(arg,2)
	    FlagPrefix:=SubStr(CurrentSwitch,1,2)
	    If FlagPrefix=No
	    {
		FlagSwitchTo=0
		CurrentSwitch:=SubStr(CurrentSwitch,3)
	    } Else FlagSwitchTo=1
	    
	    If CurrentSwitch in installActiveX,installPlugin,SetSystemSettings,RunInteractiveInstalls
		%CurrentSwitch%=%FlagSwitchTo%

	    Else If CurrentSwitch=InteractiveInstall
		RunInteractiveInstalls:=FlagSwitchTo

	    Else If CurrentSwitch in Plugin,ActiveX
	    {
		Install%CurrentSwitch%=%FlagSwitchTo%
		If (FlagSwitchTo=1) {
		    NextArgNo:=A_Index+1
		    DistMask:=%NextArgNo%
		    Path%CurrentSwitch%DistMask=DistMask
		    SkipNext=1
		}
	    }
	} Else
	    Throw Exception("Invalid command line argument", 0, arg)
    }
} Else {
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If (RunInteractiveInstalls!=0 && !A_IsAdmin) {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

FileGetVersion verActiveX, %PathActiveX%
FileGetVersion verPlugin, %PathPlugin%

If PathActiveXDist
    FileGetVersion verActiveXDist, %PathActiveXDist%

If PathPluginDist
    FileGetVersion verPluginDist, %PathPluginDist%

installActiveX := installActiveX || verActiveX!="" && verActiveXDist!="" && verActiveXDist > verActiveX
installPlugin  := installPlugin  || verPlugin !="" && verPluginDist !="" && verPluginDist  > verPlugin

If (RunInteractiveInstalls!=0) {
    txtInstActiveX := verActiveX ? "Установлен " . verActiveX : "не установлен"
    txtInstActiveX .= verActiveXDist ? (installActiveX ? ", будет обновлён до " : ", есть дистрибутив " ) . verActiveXDist : ""
    txtInstPlugin  := verPlugin  ? "Установлен " . verPlugin  : "не установлен"
    txtInstPlugin  .= verPluginDist  ? (installPlugin  ? ", будет обновлён до " : ", есть дистрибутив " ) . verPluginDist  : ""
    TrayTip Установка Adobe Flash,ActiveX: %txtInstActiveX%`nPlugin: %txtInstPlugin%
    
    If (!verActiveX && !verPlugin) {
	MsgBox 35, Установка Adobe Flash, Установить (обновить) и плагин`, и ActiveX?
	IfMsgBox Cancel
	    Exit
	IfMsgBox Yes
	{
	    installActiveX:=1
	    installPlugin:=1
	}
    }
    
    installActiveX := installActiveX || AskInstall("ActiveX", verActiveX, verActiveXDist)
    installPlugin  := installPlugin  || AskInstall("Плагин NPAPI", verPlugin, verPluginDist)

    If (installActiveX || installPlugin) {
	If (SetSystemSettings=="" && ) {
	    MsgTextMore=
	    If A_OSVersion in XP,2000
		MsgTextMore=`nКроме того`, при установке на Windows 2000/XP Adobe Flash портит параметры безопасности ключа HKCR\MIME. Они также будут исправлены.
	    MsgBox 0x124, Установка Adobe Flash, Adobe Flash устанавливает специальную службу`, которая скачивает и предлагает установить обновления. Удалить её?%MsgTextMore%
	    IfMsgBox Yes
		SetSystemSettings=1
	}
    } Else {
	MsgBox 0, Установка Adobe Flash, Нечего делать. Совсем., 60
    }
}

If installActiveX
    RunWait "%PathActiveXDist%" -install
If installPlugin
    RunWait "%PathPluginDist%" -install

If ((installActiveX || installPlugin) && SetSystemSettings==1) {
    IfExist %FlashPlayerFilesLocation%\NPSWF32.dll
	Run regsvr32.exe /u /s NPSWF32.dll, %FlashPlayerFilesLocation%, Hide
    RunWait sc.exe STOP AdobeFlashPlayerUpdateSvc,,Hide
    Sleep 5000
    RuNWait sc.exe DELETE AdobeFlashPlayerUpdateSvc,,Hide
;        REM Delete updater
;        cacls "*.exe" /E /R Everyone
;        cacls "*.exe" /E /R Все
;        cacls "*.exe" /E /G Everyone:F
;        cacls "*.exe" /E /G Все:F
;        ATTRIB -R "*.*"
;        DEL "*.exe"

    RunWait schtasks.exe /DELETE /TN "Adobe Flash Player Updater" /F,, Hide
    If A_OSVersion in XP,2000
	RunWait %comspec% /C "%A_ScriptDir%\Reset_HKCR_MIME_ACL.cmd",, Hide
}

AskInstall(distName, verInst, verDist) {
    If (verDist && !verInst) {
	MsgBox 0x24, Установка Adobe Flash, Установить %distName%?
    } Else If (verDist>verInst) {
	MsgBox 0x24, Установка Adobe Flash, Обновить %distName%?
    } Else
	return 0
    IfMsgBox Yes
	return 1
    return 0
}
