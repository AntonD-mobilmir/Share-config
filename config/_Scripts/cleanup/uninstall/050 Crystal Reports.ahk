;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

regViews := [32]
If (A_Is64bitOS)
    regViews[2] := 64

;https://archive.sap.com/discussions/thread/889740
ResetACL(SystemRoot "\winsxs\x86_microsoft.vc80.atl_1fc8b3b9a1e18e3b_8.0.50727.1_none_0c9d76766bee2c32\ATL80.dll")

For i,regview in regViews {
    SetRegView %regview%
    ;not working RegRead unCR, HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7C05EEDD-E565-4E2B-ADE4-0C784C17311C}, UninstallString
    RegRead unCR, HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7C05EEDD-E565-4E2B-ADE4-0C784C17311C}, ModifyPath
    If (unCR) {
	;RunWait %unCR% /qn /norestart,, Min UseErrorLevel
	Run %unCR% /norestart,, Min UseErrorLevel, rpid
	WinWait ahk_pid %rpid%, Re&move Crystal Reports for .NET Framework 2.0 (x86)
	Sleep 1000
	ControlClick Button4 ;  Re&move Crystal Reports for .NET Framework 2.0 (x86)
	Sleep 300
	ControlClick Button1 ;  &Finish
	
	titleWinFinish = Crystal Reports for .NET Framework 2.0 (x86) ahk_pid %rpid%
	GroupAdd endscreens, %titleWinFinish%, &Close
	GroupAdd endscreenFails, %titleWinFinish%, The installer was interrupted before Crystal Reports for .NET Framework 2.0 (x86) could be removed. You need to restart the installer to try again.
	GroupAdd endscreenSuccess, %titleWinFinish%, Crystal Reports for .NET Framework 2.0 (x86) has been successfully removed.

	While WinExist("ahk_pid " rpid) { ; ahk_class MsiDialogCloseClass ahk_exe msiexec.exe
	    WinWait ahk_group endscreens,,5
	    Sleep 1000
	    If (WinExist("ahk_group endscreenSuccess") || fail := WinExist("ahk_group endscreenFails")) { ; только для известных окон
		ControlClick Button1 ; &Close
		ControlClick &Close ; repeat, just in case
	    }
	}
	ExitApp fail
    }
}
SetRegView Default

ExitApp

ResetACL(ByRef path) {
    global SystemRoot
    sidEveryone=S-1-1-0
    ;sidAuthenticatedUsers=S-1-5-11
    ;sidUsers=S-1-5-32-545
    ;sidSYSTEM=S-1-5-18
    ;sidCreatorOwner=S-1-3-0
    sidAdministrators=S-1-5-32-544
    ;Administrators=S-1-5-32-544
    sidSYSTEM=S-1-5-18
    ;sidBackupOperators=S-1-5-32-551
    ;sidCREATOROWNER=S-1-3-0
    RunWait %SystemRoot%\System32\takeown.exe /F "%path%" /A,,Min UseErrorLevel
    RunWait %SystemRoot%\System32\icacls.exe "%path%" /reset /T /C /L,,Min UseErrorLevel
    RunWait %SystemRoot%\System32\icacls.exe "%path%" /inheritance:r /C /L,,Min UseErrorLevel
    RunWait %SystemRoot%\System32\icacls.exe "%path%" /grant "*%sidAdministrators%:F" /C /L,,Min UseErrorLevel
    RunWait %SystemRoot%\System32\icacls.exe "%path%" /grant "*%sidSYSTEM%:F" /C /L,,Min UseErrorLevel
    RunWait %SystemRoot%\System32\icacls.exe "%path%" /grant "*%sidEveryone%:RX" /C /L,,Min UseErrorLevel
}
