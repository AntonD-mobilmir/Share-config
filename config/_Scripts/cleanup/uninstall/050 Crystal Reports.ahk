;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

regViews := [32]
If (A_Is64bitOS)
    regViews.Push(64)

For i,regview in regViews {
    SetRegView %regview%
    RegRead unCR, HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7C05EEDD-E565-4E2B-ADE4-0C784C17311C}, UninstallString
    If (unCR) {
;	RunWait %unCR% /qn /norestart,, Min UseErrorLevel
	Run %unCR% /passive /norestart,, Min UseErrorLevel
    }
}
SetRegView Default
