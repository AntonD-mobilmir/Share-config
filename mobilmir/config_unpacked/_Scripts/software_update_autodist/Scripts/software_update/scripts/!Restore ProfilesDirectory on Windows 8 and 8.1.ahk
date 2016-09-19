#NoEnv

If A_OSVersion no in WIN_8,WIN_8.1
    Fail("Only restoring ProfilesDirectory on Windows 8 and 8.1", 1)

EnvGet SystemDrive, SystemDrive

if not A_IsAdmin
{
;    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
;    If RunInteractiveInstalls!=0
;    {
;	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
;	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
;	ExitApp
;    }
    Fail("Not an admin, wouldn't even try to continue")
}

RegRead ProfilesDirectory, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory.bak
If ErrorLevel
    Fail("Couldn't read ProfilesDirectory.bak", ErrorLevel)

RegWrite REG_EXPAND_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory, %ProfilesDirectory%
If ErrorLevel
    Fail("RegWrite ProfilesDirectory=""" . ProfilesDirectory . """ error, keeping backup intact.")
FileAppend Restored ProfilesDirectory to %ProfilesDirectory%`, removing ProfilesDirectory.bak, *, cp1
RegDelete HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory.bak
If ErrorLevel
    Fail("RegDelete ProfilesDirectory.bak failed.")

Fail(text, errlevel=1) {
    FileAppend %text%`n,*,cp1
    ExitApp %errlevel%
}
