;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force
SetRegView 64

CommandLine := DllCall( "GetCommandLine", "Str" )
CmdlArgs := SubStr(CommandLine, InStr(CommandLine,A_ScriptName,1)+StrLen(A_ScriptName)+2)

regPath := Trim(CmdlArgs, """ `t")
regPath := RegExReplace(regPath, "^HKCR\\", "HKEY_CLASSES_ROOT\",,1)
regPath := RegExReplace(regPath, "^HKCU\\", "HKEY_CURRENT_USER\",,1)
regPath := RegExReplace(regPath, "^HKLM\\", "HKEY_LOCAL_MACHINE\",,1)
regPath := RegExReplace(regPath, "^HKU\\", "HKEY_USERS\",,1)
regPath := RegExReplace(regPath, "^HKCC\\", "HKEY_CURRENT_CONFIG\",,1)

Process Close, regedit.exe
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %regPath%

EnvGet SystemRoot,SystemRoot
Run "%SystemRoot%\regedit.exe"
