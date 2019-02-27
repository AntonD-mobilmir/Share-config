;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

ver := RtlGetVersion()

If (ver[2] < 8 || VersionAtLeast(ver, [1,1,10,0,17763,134])) {
    If (InStr(FileExist("D:\Users"), "D")) {
        FileAppend Windows version is outside range`, setting up correct ProfilesDirectory path, *
        EnvGet configDir, configDir
        RunWait %A_AhkPath% /ErrorStdOut "%configDir%\_Scripts\MoveUserProfile\SetProfilesDirectory_D_Users.ahk",, UseErrorLevel
    } Else {
        FileAppend Windows version is outside range`, but D:\Users does not exist. Doing nothing., *
    }
    
    ExitApp %ErrorLevel%
}

FileAppend Windows version is in range`, restoring ProfilesDirectory from backup., *

EnvGet SystemDrive, SystemDrive

profilesListKey := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

if (!A_IsAdmin) {
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If (RunInteractiveInstalls!="0") {
	Run % "*RunAs " DllCall( "GetCommandLine", "Str" ) ; Requires v1.0.92.01+
	ExitApp
    }
}

Try RegRead ProfilesDirectory, %profilesListKey%, ProfilesDirectory.bak
Catch exc
    e := exc
If (ErrorLevel || !ProfilesDirectory)
    ProcError(e, "Резервная копия ProfilesDirectory не прочитана из «" profilesListKey ": ProfilesDirectory.bak»")

Try RegWrite REG_EXPAND_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory, %ProfilesDirectory%
Catch exc
    ProcError(exc, "Путь к папке профилей не записан")
RegDelete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory.bak

ProcError(e, msg := "", errCode := "") {
    If (errCode=="")
        errCode := A_LastError
    If (msg)
        errMsg := msg . ", код системной ошибки: " Format("0x{:X}", errCode) ", исключение: " ObjectToText(e)
    Else 
        errMsg := e.Extra . ", ошибка " e.What ", код системной ошибки: " errCode
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If (RunInteractiveInstalls!="0")
        MsgBox %errMsg%
    Else
        FileAppend %errMsg%`n, **, CP1
    ExitApp 1
}

ObjectToText(ByRef obj) {
    return IsObject(obj) ? ObjectToText_nocheck(obj) : obj
}

ObjectToText_nocheck(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText_nocheck(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}

RtlGetVersion() {
    static RTL_OSVIEX, init := VarSetCapacity(RTL_OSVIEX, 284, 0) && NumPut(284, RTL_OSVIEX, "UInt")
    If (!NumGet(RTL_OSVIEX,         4, "UInt"  ))
	if (DllCall("ntdll.dll\RtlGetVersion", "Ptr", &RTL_OSVIEX) != 0)
	    Throw Exception("DllCall failed", "RtlGetVersion")
    return { 1 : NumGet(RTL_OSVIEX, 282, "UChar" ),  2 : NumGet(RTL_OSVIEX,         4, "UInt"  )
           , 3 : NumGet(RTL_OSVIEX,   8, "UInt"  ),  4 : NumGet(RTL_OSVIEX,        12, "UInt"  )
           , 5 : NumGet(RTL_OSVIEX,  16, "UInt"  ),  6 : StrGet(&RTL_OSVIEX + 20, 128, "UTF-16")
           , 7 : NumGet(RTL_OSVIEX, 276, "UShort"),  8 : NumGet(RTL_OSVIEX,       278, "UShort")
           , 9 : NumGet(RTL_OSVIEX, 280, "UShort") }
	;. "ProductType:`t`t"           RtlGetVersion[1]   "`n"
	;. "MajorVersion:`t`t"          RtlGetVersion[2]   "`n"
	;. "MinorVersion:`t`t"          RtlGetVersion[3]   "`n"
	;. "BuildNumber:`t`t"           RtlGetVersion[4]   "`n"
	;. "PlatformId:`t`t"            RtlGetVersion[5]   "`n"
	;. "CSDVersion:`t`t"            RtlGetVersion[6]   "`n"
	;. "ServicePackMajor:`t`t"      RtlGetVersion[7]   "`n"
	;. "ServicePackMinor:`t`t"      RtlGetVersion[8]   "`n"
	;. "SuiteMask:`t`t"             RtlGetVersion[9]   "`n"
}

; compare versions by components
VersionAtLeast(verTest, verMin) {
    For i, min in verMin {
        test := verTest[i]
        If (test < min)
            return false
        Else If (test > min)
            return true
    }
    
    ;equal
    return true
}
