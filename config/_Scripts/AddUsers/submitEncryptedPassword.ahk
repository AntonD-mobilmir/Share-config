;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;global debug:=Object()

UserName=%1%
FilePath=%2%
EnvGet Status, UserAddError
Menu Tray, Tip, UserName: %UserName%`nStatus: %Status%`nFile: %FilePath%

FileRead data, %FilePath%
If (!data)
    Throw Exception("В файле нет данных для отправки",, FilePath)

RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain
If (!Domain)
    RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, DhcpDomain
If (Domain != "office0.mobilmir")
    Hostname .= "." . Domain

POSTDATA := { "entry.1247228425" : Hostname
	    , "entry.600554004" : UserName
	    , "entry.356325911" : Trim(data, " `n`r`t")
	    , "entry.1306387427" : Status
	    , "entry.1299832479" : Object() }

FileReadLine URL, %A_LineFile%\..\..\pseudo-secrets\%A_ScriptName%.txt, 1
ExitApp !PostGoogleFormWithPostID(URL, POSTDATA)

#include %A_LineFile%\..\..\Lib\PostGoogleFormWithPostID.ahk
