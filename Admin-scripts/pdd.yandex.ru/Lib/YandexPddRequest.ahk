;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

YandexPddRequest(ByRef URL, ByRef domain, ByRef qPOSTDATA, ByRef response:="") {
    ;global debug := Object()
    static LocalAppData:="", PddToken:="", TokenDom:=""
    If (!LocalAppData)
	EnvGet LocalAppData,LOCALAPPDATA
    If (TokenDom != domain) {
	tokenTxtFName=%LocalAppData%\_sec\yapdd-%domain%.txt
	Loop 2
	{
	    FileRead PddToken, %tokenTxtFName%
	    If (PddToken)
		break
	    Run https://pddimp.yandex.ru/api2/admin/get_token
	    Run notepad.exe %tokenTxtFName%
	    MsgBox Получите токен в открывшемся сайте`, запишите его в файл "%tokenTxtFName%" и нажмите OK.
	}
	If (!PddToken)
	    Throw Exception("Не прочитался токен для домена", A_LastError, domain)
	TokenDom := domain
    }
    addHeaders:={PddToken:PddToken}
    
    POSTDATA := ""
    If (IsObject(qPOSTDATA)) {
	For k,v in qPOSTDATA {
	    POSTDATA .= k "=" v "&"
	}
	POSTDATA := SubStr(POSTDATA, 1, -1) ; remove excess &
    } Else {
	POSTDATA := qPOSTDATA
    }

    If (!InStr(POSTDATA, "domain="))
	POSTDATA := "domain=" domain "&" POSTDATA
    
    ;XMLHTTP_Post(ByRef URL, ByRef POSTDATA, ByRef response:=0, ByRef reqmoreHeaders:=0) {
    While !(res := XMLHTTP_Post((SubStr(URL, 1,1) == "/" ? "https://pddimp.yandex.ru" : "") . URL, POSTDATA, response, addHeaders)) {
	TrayTip %A_ScriptName%, PDD response: %response%
	Sleep 3000
	TrayTip
    }
    
    ;FileAppend % JSON.Dump(debug), *
    return res
}

;#include %A_LineFile%\..\XMLHTTP_Post.ahk
#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\XMLHTTP_Post.ahk
;#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\JSON.ahk
