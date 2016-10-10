;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

argc = %0%
If (argc) {
    Loop %argc%
    {
	FileAppend % URIfy(%A_Index%) . "`n",*,cp1
    }
} Else {
    InputBox path, Преобразование пути в URI, При нажатии OK`, URI будет скропирован в буфер обмена, , , , , , , , %clipboard%
    If (!ErrorLevel)
	clipboard := URIfy(path)
}
ExitApp

URIfy(path) {
    outPath := "file:/"
    If (SubStr(path,1,2) == "\\") {
	path := SubStr(path,3)
    }
    Loop Parse, path, \
    {
	outPath .= "/" . UriEncodeR(A_LoopField)
    }
    
    return outPath
}

; wrapped to leave Russian letters intact
; а-я А-Я
UriEncodeR(Uri, Enc = "UTF-8") {
    Loop Parse, Uri
	If (A_LoopField >= "а" && A_LoopField <= "я" || A_LoopField >= "А" && A_LoopField <= "Я" || A_LoopField == "ё" || A_LoopField == "Ё")
	    rVal .= A_LoopField
	Else
	    rVal .= UriEncode(A_LoopField)
    return rVal
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
			|| Code == 0x24|| Code == 0x2D|| Code == 0x5F|| Code == 0x2E|| Code == 0x2B|| Code == 0x21|| Code == 0x2A|| Code == 0x27|| Code == 0x28|| Code == 0x29|| Code == 0x2C ) ; safe special characters $-_.+!*'(),
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
