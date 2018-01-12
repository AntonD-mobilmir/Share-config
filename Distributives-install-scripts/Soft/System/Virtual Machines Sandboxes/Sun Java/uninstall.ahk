;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet RunInteractiveInstalls,RunInteractiveInstalls
If (!A_IsAdmin && RunInteractiveInstalls!="0") {
    Run % "*RunAs " DllCall( "GetCommandLine", "Str" )
    ExitApp
}

uninstKey = SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
For i, regview in [32,64] {
    SetRegView %regview%
    Loop Reg, HKEY_LOCAL_MACHINE\%uninstKey%, K
    {
	RegRead DisplayName, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, DisplayName
	RegRead URLUpdateInfo, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, URLUpdateInfo
	RegRead Publisher, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, Publisher
	
	If (   	StartsWith(DisplayName, "Java ")
		    && (   Publisher == "Oracle Corporation"
			|| URLUpdateInfo == "http://java.sun.com")
		    && (   DisplayName ~= "^Java [0-9]+ Update [0-9]+\b") ; "Java 8 Update 152" "Java 8 Update 152 (64-bit)"
			|| DisplayName ~= "^Java (\d+\.)+\d+\b" ) { ; Java 9.0.1 (64-bit)
	    Run_msiexecExe("/X """ A_LoopRegName """ /qn /norestart")
	}
    }
}
ExitApp

Run_msiexecExe(params) {
    static SystemRoot:=""
    If (SystemRoot=="")
	EnvGet SystemRoot, SystemRoot
    
    Loop {
	Menu Tray, Tip, Running %params%
	RunWait "%SystemRoot%\System32\msiexec.exe" %params%,, UseErrorLevel
	
	If (ErrorLevel==1618) { ; Another install is currently in progress
	    TrayTip,, Error 1618: Another install currently in progress`, waiting 30 sec to repeat
	    Sleep 30000
	} Else
	    break
    }
    Menu Tray, Tip
    
    If (ErrorLevel==3010) ;3010: restart required
	return 0
    return ErrorLevel
}

StartsWith(longtext, shorttext) {
    return SubStr(longtext, 1, StrLen(shorttext)) == shorttext
}

;[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F83218066F0}]
;"AuthorizedCDFPrefix"=""
;"Comments"=""
;"Contact"="http://java.com"
;"DisplayVersion"="8.0.660.18"
;"HelpLink"=REG_EXPAND_SZ:"http://java.com/help"
;"HelpTelephone"=""
;"InstallDate"="20160128"
;"InstallLocation"="C:\\Program Files (x86)\\Java\\jre1.8.0_66\\"
;"InstallSource"="C:\\Users\\Install\\AppData\\LocalLow\\Oracle\\Java\\jre1.8.0_66\\"
;"ModifyPath"=REG_EXPAND_SZ:"MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83218066F0}"
;"NoModify"=dword:00000001
;"NoRepair"=dword:00000001
;"Publisher"="Oracle Corporation"
;"Readme"=REG_EXPAND_SZ:"[INSTALLDIR]README.txt"
;"Size"=""
;"EstimatedSize"=dword:000163ae
;"UninstallString"=REG_EXPAND_SZ:"MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83218066F0}"
;"URLInfoAbout"="http://java.com"
;"URLUpdateInfo"="http://java.sun.com"
;"VersionMajor"=dword:00000008
;"VersionMinor"=dword:00000000
;"WindowsInstaller"=dword:00000001
;"Version"=dword:08000294
;"Language"=dword:00000409
;"DisplayName"="Java 8 Update 66"
