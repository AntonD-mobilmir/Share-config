;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

FormatTime dateISO,, yyyy-MM-dd
extTimeStart := SubStr(A_Now, 1, 8) . (A_WDay == 1 || A_WDay == 7 ? "0830" : "1730")
While (A_Index<3) {
    extTimeHours := ""
    extTimeHours -= extTimeStart, Hours
    ;MsgBox extTimeStart: %extTimeStart%`nextTimeHours: %extTimeHours%
    
    If (extTimeHours>0 && extTimeHours<=10)
        break
    
    extTimeStart += -1, Days
}

;InputBox comment
;comment := UriEncodeR(comment)
Run https://docs.google.com/forms/d/e/1FAIpQLSdEN3LM_hZaMfL0JsAr2288ElZdTxomwqFlzqbk_Pu76-QVlQ/viewform?usp=pp_url&entry.1383268982=%dateISO%&entry.448792864=%extTimeHours%&entry.1981205041=%comment%


; wrapped to leave Russian letters intact
; а-я А-Я
UriEncodeR(Uri, Enc = "UTF-8") {
    global leaveCyrillicIntact
    If (leaveCyrillicIntact) {
	Loop Parse, Uri
	    If (A_LoopField >= "а" && A_LoopField <= "я" || A_LoopField >= "А" && A_LoopField <= "Я" || A_LoopField == "ё" || A_LoopField == "Ё")
		rVal .= A_LoopField
	    Else
		rVal .= UriEncode(A_LoopField)
	return rVal
    } Else {
	return UriEncode(Uri, Enc)
    }
}

;http://www.autohotkey.com/board/topic/75390-ahk-l-unicode-uri-encode-url-encode-function/
; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
; modified by LogicDaemon to include more safe characters
; safe characters: Alphanumerics [0-9a-zA-Z], special characters $-_.+!*'(), (https://perishablepress.com/stop-using-unsafe-characters-in-urls/)
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
			|| Code >= 0x61 && Code <= 0x7A ; a-z
			|| Code == 0x24 || Code == 0x2D || Code == 0x5F || Code == 0x2E || Code == 0x21 || Code == 0x2A || Code == 0x27 || Code == 0x2C ) ; safe special characters «$-_.+!*'(),» but «()» excluded for Markdown in Redbooth, and «+» is exclude because treated as space otherwise
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
