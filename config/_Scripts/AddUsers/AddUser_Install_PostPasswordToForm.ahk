;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

;global debug:=1

RegRead Hostname, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead Domain, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain

UserName=%1%
Password=%2%
Status=%3%

URL:="https://docs.google.com/a/mobilmir.ru/forms/d/1eBHS2d49-qtD096mYZDK_wIXwjS1WyImFi-_kYWUkhY/formResponse"
If (!Domain || !(Domain ~= "^(office0.mobilmir|officeVPN.mobilmir)$"))
    Hostname .= "." . Domain
POSTDATA:="entry.1427319477=" . UriEncode(Hostname) . "&entry.1727019064=" . UriEncode(UserName) . "&entry.1602906221=" . UriEncode(Password) . "&entry.1625305818=" . UriEncode(Status) . "&submit=%D0%93%D0%BE%D1%82%D0%BE%D0%B2%D0%BE"

Loop
{
    success := (SendWebRequest(ReadProxy("HKEY_LOCAL_MACHINE")) || SendWebRequest(ReadProxy("HKEY_CURRENT_USER")) || SendWebRequest("192.168.127.1:3128") || SendWebRequest())
    
    If (!success)
    {
	MsgBox 53, Запись пароля в таблицу, При отправке пароля произошла ошибка.`n`n[Попытка %A_Index%`, автоповтор – 5 минут], 300
	IfMsgBox Cancel
	    break
    }
} Until success

ExitApp !success

SendWebRequest(proxy="") {
    global debug, URL, POSTDATA

    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WebRequest.Open("POST", URL, false)
    WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    If (proxy) {
	WebRequest.SetProxy(2,proxy)
	tipAddText := " через прокси-сервер " . proxy
    } Else {
	tipAddText := " без использования прокси"
    }
    Try {
	Menu Tray, Tip,  Отправка пароля Install в таблицу «пароли общих административных пользователей»%tipAddText%
	TrayTip Отправка пароля Install, в таблицу «пароли общих административных пользователей»%tipAddText%,,1
	WebRequest.Send(POSTDATA)
	Menu Tray, Tip
	TrayTip
	aResponseHeaders := WebRequest.GetAllResponseHeaders
	aResponse := WebRequest.ResponseText
	aStatus:=WebRequest.Status	;can be 200, 404 etc., including proxy responses
	TrayTip Отправка пароля Install, Код HTTP-ответа: %aStatus%,, (aStatus >= 200 && aStatus < 300) ? 1 : 3
    } catch e {
	err:=e
    }
    WebRequest := ""
    
    If (debug==1) {
	;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
;	static document
;	Gui Add, ActiveX, w750 h550 vdocument, MSHTML:%aResponse%
;	Gui Show
	
	MsgText := "Over proxy=" . proxy
	    . "`nStatus=" . aStatus
	    . "`nerror:`nWhat=" . err.What
	    . "`nMessage=" . err.Message
	    . "`nExtra=" . err.Extra
	    . "`n`nResponse Headers: " . aResponseHeaders

	MsgBox %MsgText%
    }
    
    If err
	return 0
    Else
	return 1
}

ReadProxy(ProxySettingsRegRoot="HKEY_CURRENT_USER") {
    static ProxySettingsIEKey:="Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    RegRead ProxyEnable, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyEnable
    If ProxyEnable
	RegRead ProxyServer, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyServer
    return ProxyServer
}


;GuiClose:
;GuiEscape:
;    ExitApp

;http://www.autohotkey.com/board/topic/75390-ahk-l-unicode-uri-encode-url-encode-function/
; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
UriEncode(Uri, Enc = "UTF-8")
{
	StrPutVar(Uri, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
			Break
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	Return, Res
}

UriDecode(Uri, Enc = "UTF-8")
{
	Pos := 1
	Loop
	{
		Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
		VarSetCapacity(Var, StrLen(Code) // 3, 0)
		StringTrimLeft, Code, Code, 1
		Loop, Parse, Code, `%
			NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
		StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
	}
	Return, Uri
}

StrPutVar(Str, ByRef Var, Enc = "")
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}

;SetProxy(2,non-existing_proxy_hostname_here_including_empty_string) causes exception on .Send: .Message="0x80072EE7 - 
;	Source:		WinHttp.WinHttpRequest
;	Description:	The server name or address could not be resolved"
;	Extra=Send

;SetProxy(2,bad_proxy_name_like_including_quotes) causes:
;Error:  0x80070057 - The parameter is incorrect.
;Specifically: SetProxy

;SetProxy(2,inaccessible_proxy_including_no_port) causes:
;Message=0x80072EFD - 
;Source:		WinHttp.WinHttpRequest
;Description:	A connection with the server could not be established
;Extra=Send

;trying to get any .ResponseText or .Status or whatever before answer received causes
;Error:  0x8000000A - The data necessary to complete this operation is not yet available.
;Source:		WinHttp.WinHttpRequest
;Description:	The data necessary to complete this operation is not yet available.
;Specifically: Status
