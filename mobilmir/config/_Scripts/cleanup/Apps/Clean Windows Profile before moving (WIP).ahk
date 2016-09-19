;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
Global flags

Loop %0% ; for each argument
{
    CurrentArg := %A_Index%
    If (SubStr(CurrentArg, 1, 1) == "/") { ; it's a switch
	StringLower CurrentArg, CurrentArg
	flags .= "," . SubStr(CurrentArg, 2)
	; u = unattended
	; f = force cleaning thunderbird profile up even if there are no prefs.js in a dir
	; c = clean up more (completely remove ImapMail, remove all indexes – *.msf)
    } Else { ; otherwise it's dir-path
	fDirInArgs := true
	Loop %CurrentArg%, 2
	    CleanupMTProfile(A_LoopFileFullPath)
    }
}

If (!fDirInArgs) ; if there were no dir-paths in args, alert
    MsgBox Among arguments`, there must be path to a profile directory`, which will be cleaned for transporting.

CleanupWindowsProfile(Dir) {
}
