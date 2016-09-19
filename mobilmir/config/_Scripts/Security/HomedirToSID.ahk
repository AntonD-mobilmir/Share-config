;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

destDir = %1%

profilesSubkey = SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
Loop Reg, HKEY_LOCAL_MACHINE\%profilesSubkey%, K
{
    RegRead profilePath, HKEY_LOCAL_MACHINE\%profilesSubkey%\%A_LoopRegName%, ProfileImagePath
    If ( (profilePath . "\") = SubStr(destDir . "\", 1, StrLen(profilePath) + 1) ) {
	SID := A_LoopRegName
	FileAppend %SID%`n,*,cp1
	Exit 0
    }
}

;FileAppend Not found user for %destDir%`n, **, cp1
Exit 1
