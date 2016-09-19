;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

if not A_IsAdmin
{
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

;HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
;HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders

;OR 

;HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
;Public

destDir=%A_AppDataCommon%\mobilmir.ru\reg-backup

FileCreateDir %destDir%
RunWait %A_WinDir%\System32\REG.exe EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "%destDir%\HKLM-Shell Folders.%A_Now%.reg"
RunWait %A_WinDir%\System32\REG.exe EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" "%destDir%\HKLM-User Shell Folders.%A_Now%.reg"

RunWait %A_WinDir%\System32\REG.exe IMPORT "%A_ScriptDir%\HKLM User Shell Folders D_Users_Public.reg"

Loop Files, %A_ScriptDir%\D\*, D
{
    FileCopyDir %A_LoopFileFullPath%, D:\%A_LoopFileName%, 1
}
