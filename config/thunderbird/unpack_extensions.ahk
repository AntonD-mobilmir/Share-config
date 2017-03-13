;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet SystemDrive,SystemDrive
global defaultConfig
retailDept := getDefaultConfigFileName() = "Apps_dept.7z"

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

If (retailDept) {
    userOrSID = S-1-5-11;s:y ;Authenticated Users
} Else {
    userOrSID = %A_UserName%;s:n
}

profilesSubkey = SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
Loop Reg, HKEY_LOCAL_MACHINE\%profilesSubkey%, K
{
    RegRead profilePath, %A_LoopRegKey%\%profilesSubkey%\%A_LoopRegName%, ProfileImagePath
    If ( (profilePath . "\") = SubStr(destDir, 1, StrLen(profilePath) + 1) ) {
	userOrSID := A_LoopRegName . ";s:y"
	break
    }
}

arg7z = x -aoa -o"%destDir%\staged" -- "%srcDir%\staged.7z"
Run7z(arg7z)
If (retailDept) {
    arg7z = x -aoa -o"%destDir%\staged" -- "%srcDir%\staged-retail.7z"
} Else {
    arg7z = x -aoa -o"%destDir%\staged" -- "%srcDir%\staged-not-retail.7z"
}
Run7z(arg7z)

findexefunc:="findexe"
If(IsFunc(findexefunc)) {
    Try SetACLexe := %findexefunc%(SystemDrive . "\SysUtils\SetACL.exe", "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils")
} Else {
    SetACLexe:=SystemDrive . "\SysUtils\SetACL.exe"
}

RunWait "%SetACLexe%" -on "%destDir%" -ot file -actn ace -ace "n:%userOrSID%;p:change;i:so`,sc;m:set;w:dacl",, Min UseErrorLevel

Exit

Run7z(args) {
    static exe7z
    If (!exe7z) {
	find7zexefunc:="find7zexe"
	find7zaexefunc:="find7zaexe"
	If(IsFunc(find7zexefunc)) {
	    Try {
		exe7z := %find7zexefunc%("7zg.exe")
	    } Catch {
		Try {
		    exe7z := %find7zexefunc%()
		} Catch {
		    Try exe7z := %find7zaexefunc%()
		}
	    }
	} Else {
	    Throw "Не найден 7-Zip, архивы дополнений Thunderbird не будут распакованы."
	}
    }
    
    RunWait "%exe7z%" %args%,, UseErrorlevel
    If (ErrorLevel)
	MsgBox После выполненя`n"%exe7z%" %args%`nобнаружен код ошибки: %ErrorLevel%
}

#Include %A_ScriptDir%\..\_Scripts\Lib\getDefaultConfig.ahk
#Include *i %A_ScriptDir%\..\_Scripts\Lib\find7zexe.ahk

#Include %A_ScriptDir%\FindThunderbirdProfile.ahk
