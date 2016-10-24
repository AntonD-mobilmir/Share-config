;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
    ExitApp
}

;recommended way (instead of %PATH%)
;To map an application's executable file name to that file's fully-qualified path
;is to write it in
;HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths
;http://msdn.microsoft.com/en-us/library/ee872121(VS.85).aspx

Loop %0%
    Loop % %A_Index%
    {
	FileAppend %A_LoopFileLongPath%`n,*
	SplitPath A_LoopFileLongPath, , FilePath, , OutNameNoExt
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%A_LoopFileName%,, %A_LoopFileLongPath%
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%A_LoopFileName%, Path, %FilePath%
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%OutNameNoExt%,, %A_LoopFileLongPath%
	RegWrite REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%OutNameNoExt%, Path, %FilePath%
    }
