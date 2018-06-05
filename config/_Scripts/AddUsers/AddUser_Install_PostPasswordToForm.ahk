;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;global debug:=Object()
RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain
If (!Domain)
    RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, DhcpDomain

UserName=%1%
Password=%2%
Status=%3%

If Domain not in office0.mobilmir,officeVPN.mobilmir
    Hostname .= "." . Domain
POSTDATA := { "entry.1427319477" : Hostname
	    , "entry.1727019064" : UserName
	    , "entry.1602906221" : Password
	    , "entry.1625305818" : Status
	    , "entry.1342070748" : Object() }

ReadURLs := []
Loop Read, %A_LineFile%\..\..\pseudo-secrets\%A_ScriptName%.txt
    ReadURLs[A_Index] := A_LoopReadLine
Until A_Index>2
ExitApp !PostGoogleFormWithPostID(ReadURLs, POSTDATA) ; PostGoogleFormWithPostID(ByRef URLs, ByRef kv, ByRef postID:="", ByRef trelloURL:="")

#Include %A_LineFile%\..\..\Lib\PostGoogleFormWithPostID.ahk
