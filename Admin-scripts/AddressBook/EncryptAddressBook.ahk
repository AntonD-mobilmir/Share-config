;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet UserProfile, UserProfile
tmp = %A_Temp%\%A_ScriptName%.%A_Now%
GNUPGHOME=%tmp%\gnupg
EnvSet GNUPGHOME,%GNUPGHOME%
FileCreateDir %GNUPGHOME%
FileCopy %A_AppData%\gnupg\*.gpg, %GNUPGHOME%\
EnvGet SystemDrive, SystemDrive
gpgexe := findexe("gpg.exe", SystemDrive "\SysUtils\gnupg\pub")
fpubkeys := FileOpen(tmp "\pubkeys.asc", "w", "CP1")
Loop Files, \\Srv0.office0.mobilmir\profiles$\Share\gpg\*.asc
{
    Status(A_LoopFileName, "Loading keys")
    rcptList .= " -r """ SubStr(A_LoopFileName, 1, -StrLen(A_LoopFileExt)-1) """"
    FileRead key, %A_LoopFileLongPath%
    fpubkeys.WriteLine(key)
    TrayTip
}
fpubkeys.Close()

cmdPID=
SetTimer ShowCMDWindow, -15000
Status("gpg.exe imports keys into keyring…", "Loading keys")
RunWait "%gpgexe%" --homedir "%GNUPGHOME%" --batch --import pubkeys.asc, %tmp%, Hide, cmdPID

Status("Encrypting addressbook for all recipients")
FileCopy \\Srv0.office0.mobilmir\profiles$\Share\adrbooks\business_contacts.mab, %tmp%
SetTimer ShowCMDWindow, -3000
RunWait "%gpgexe%" --homedir "%GNUPGHOME%" --trust-model always %rcptList% -e business_contacts.mab, %tmp%, Hide, cmdPID
FileCopy %tmp%\business_contacts.mab.gpg, %UserProfile%\Dropbox\it.mobilmir.ru Team Folder\pub\*.*, 1

ExitApp

Status(msg, title := "") {
    TrayTip
    TrayTip %title%, %msg%
    Menu Tray, Tip, %title%`n%msg%
    SetTimer ResetTrayTip, -15000
}

ResetTrayTip() {
    Menu Tray, Tip
}

ShowCMDWindow() {
    global cmdPID
    If (cmdPID)
	WinShow ahk_pid %cmdPID%
}
