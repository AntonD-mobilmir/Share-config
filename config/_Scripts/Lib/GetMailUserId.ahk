;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

GetMailUserId(ByRef GetSharedMailUserIdScript:="") {
    EnvGet MailUserId,MailUserId
    If (MailUserId) {
	return MailUserId
    } Else {
	If (!GetSharedMailUserIdScript) {
	    EnvGet GetSharedMailUserIdScript,GetSharedMailUserIdScript
	    If (!GetSharedMailUserIdScript)
		GetSharedMailUserIdScript=%A_AppDataCommon%\mobilmir.ru\_get_SharedMailUserId.cmd
	}
	If (FileExist(GetSharedMailUserIdScript)) {
	    return ReadSetVarFromBatchFile(GetSharedMailUserIdScript, "MailUserId")
	}
    }
}

#include %A_LineFile%\..\ReadSetVarFromBatchFile.ahk
