;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet SystemDrive,SystemDrive
EnvGet SystemRoot,SystemRoot
global defaultConfig
Try retailDept := getDefaultConfigFileName() = "Apps_dept.7z"

destDir = %1%
srcDir = %2%

If (!srcDir)
    srcDir = %A_ScriptDir%\default_profile_template\extensions

If (!destDir) {
    Try destDir := FindThunderbirdProfile() . "\extensions"
    If (!destDir) {
	EnvGet UserProfile,UserProfile
	destDir=%UserProfile%\Mail\Thunderbird\profile\extensions
    }
}

unpackArchiveSuffixes := ["", (retailDept ? "" : "-not" ) . "-retail"]
For i, suff in unpackArchiveSuffixes {
    arcName = %srcDir%\staged%suff%.7z
    If (FileExist(arcName))
        Run7z("x -aoa -o""" destDir "\staged"" -- """ arcName """")
}

;If (retailDept) { ;Authenticated Users
;    userIcacls = *S-1-5-11
;} Else {
;    userIcacls = %A_UserName%
;}

;profilesSubkey = SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
;Loop Reg, HKEY_LOCAL_MACHINE\%profilesSubkey%, K
;{
;    RegRead profilePath, %A_LoopRegKey%\%profilesSubkey%\%A_LoopRegName%, ProfileImagePath
;    If ( (profilePath . "\") = SubStr(destDir, 1, StrLen(profilePath) + 1) ) {
;	userIcacls := "*" . A_LoopRegName
;	break
;    }
;}

; no more binary components
;RunWait "%SystemRoot%\System32\icacls.exe" "%destDir%" /grant:r "%userIcacls%:(OI)(CI)M",, Min UseErrorLevel
Exit

Run7z(args) {
    static exe7z
    If (!exe7z) {
        exe7z := find7zGUIorAny()
        If (!exe7z)
            Throw Exception("Не найден 7-Zip, архивы дополнений Thunderbird не будут распакованы.")
    }
    
    RunWait "%exe7z%" %args%,, UseErrorlevel
    If (ErrorLevel)
	Throw Exception(exe7z " " args " завершился с ошибкой " ErrorLevel)
}

#include %A_ScriptDir%\..\_Scripts\Lib\getDefaultConfig.ahk
#include *i %A_ScriptDir%\..\_Scripts\Lib\find7zexe.ahk

#include %A_ScriptDir%\FindThunderbirdProfile.ahk
