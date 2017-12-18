;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

RetailStatusReport(ByRef st:="", ByRef einf:="", ByRef mdl:="") {
    RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    RegRead oldHostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, NV Hostname
    RegRead domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, DhcpDomain
    
    If (hostname != oldHostname)
	hostSuffix := oldHostname
    If (domain != "office0.mobilmir")
	hostname .= "." domain
    
    If (mdl == "") {
	FileGetTime scriptmtime, %A_ScriptFullPath%
	FormatTime scriptmtime, %scriptmtime%, yyyy-MM-dd HH:mm
	mdl := A_ScriptName " (" scriptmtime ")"
    }
    
    SplitPath A_LineFile, ScriptName
    FileReadLine URL, %A_LineFile%\..\..\pseudo-secrets\%ScriptName%.txt, 1
    return PostGoogleFormWithPostID(URL
	, {"entry.1804185158":	GetMailUserId()
	 , "entry.1223335585":	hostname . (hostSuffix ? " (" hostSuffix ")" : "")
	 , "entry.338457113":	(A_IsAdmin ? "^" : "") A_UserName
	 , "entry.1438758954":	mdl
	 , "entry.1526229986":	st
	 , "entry.1738366749":	einf} )
}

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    ;RetailStatusReport.ahk <Module> <Status> <Extended info …>
    FileEncoding UTF-8

    Loop %0%
    {
	arg:=%A_Index%
	If (!mdl) {
	    mdl := arg
	} Else If (!st) {
	    st := arg
	} Else 
	    einf .= "`n" arg
    }
    
    ExitApp !mdl || !RetailStatusReport(st, Trim(einf, "`n"), mdl)
}

#include %A_LineFile%\..\PostGoogleFormWithPostID.ahk
#include %A_LineFile%\..\GetMailUserId.ahk
