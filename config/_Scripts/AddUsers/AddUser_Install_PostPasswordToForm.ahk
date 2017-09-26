;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;global debug:=Object()
RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain
If (!Domain)
    RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, DhcpDomain

URL:="https://docs.google.com/a/mobilmir.ru/forms/d/1eBHS2d49-qtD096mYZDK_wIXwjS1WyImFi-_kYWUkhY/formResponse"
UserName=%1%
Password=%2%
Status=%3%

;ToDo: сменить на Trello ID
Random postID, 0, 0xFFFF
postID := A_Now . "#" . Format("{:04x}", postID)

If (Domain != "office0.mobilmir" && Domain != "officeVPN.mobilmir")
    Hostname .= "." . Domain
POSTDATA := { "entry.1427319477" : Hostname
	    , "entry.1727019064" : UserName
	    , "entry.1602906221" : Password
	    , "entry.1625305818" : Status
	    , "entry.1342070748" : postID }

;PostGoogleForm(URL, ByRef kv, tries:=20, retryDelay:=20000)
While (!(success:=PostGoogleForm(URL, POSTDATA, 2, 1000))) {
    If (IsObject(debug)) {
	debugtxt=
	For n,v in debug
	    debugtxt .= n ": " SubStr(v, 1, 100) "`n"
    } Else {
	debugtxt=При отправке пароля произошла ошибка.
    }
    MsgBox 53, Запись пароля %UserName% в таблицу, %debugtxt%`n`n[Попытка %A_Index%`, автоповтор – 5 минут], 300
    IfMsgBox Cancel
	break
}

;ToDo: загружать https://docs.google.com/spreadsheets/d/16j2LRTvGMsX5zLxrJJFC0eQtOMZYRVomwdJ5msqAu_A/export?format=csv&gid=1201239047 и проверять, добавилась ли строчка с postID

ExitApp !success

#Include %A_LineFile%\..\..\Lib\PostGoogleForm.ahk
