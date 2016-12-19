;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance off

global copied := 1

Gui Add, Text, xm section, Кому
Gui Add, Edit, ys x100 W300 vTo gUpdate
Gui Add, Text, xm section, Копия
Gui Add, Edit, ys x100 W300 vCC gUpdate
Gui Add, Text, xm section, Скрытая копия
Gui Add, Edit, ys x100 W300 vBCC gUpdate
Gui Add, Text, xm section, Тема
Gui Add, Edit, ys x100 W300 vSubject gUpdate
Gui Add, Text, xm, Текст письма
Gui Add, Edit, xm R10 W400 Multi VScroll vBody gUpdate
Gui Add, Checkbox, xm Checked vleaveCyrillicIntact gUpdate, Не кодировать русские буквы
Gui Add, Radio, xm section Checked vmailto gUpdate, mailto:
Gui Add, Radio, ys vgmail gUpdate, GMail
Gui Add, Text, xm, URI
Gui Add, Edit, xm ReadOnly Multi VScroll W400-m gSelectAllCopy vURI
Gui Add, Button, section gCopy, Скопировать (&c)
Gui Add, Button, ys gRun, Открыть (&o)
Gui Show

Exit

GuiEscape:
GuiClose:
ButtonCancel:
    If (!copied) {
	MsgBox 0x24, В окне остался текст, Вы вводили текст`, но не копировали URL. При закрытии окна всё содержимое будет утеряно. Точно выйти?
	IfMsgBox No
	    return
    }
    ExitApp

SelectAllCopy:
    EM_SETSEL := 0x00B1
    ;A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
    Gui +LastFound
    ControlFocus %CtrlHwnd%
    ;https://autohotkey.com/board/topic/39793-how-to-select-the-text-in-an-edit-control/
    SendMessage %EM_SETSEL%, 0, -1, %CtrlHwnd%
;    MsgBox %ERRORLEVEL%
return

Run:
    Run %URI%
return

Copy:
    copied := 1
    clipboard:=URI
return

Update:
    Gui, Submit, NoHide
    copied := 0
    
    If (mailto) {
	URI := "mailto:" . EncodeTo(To) . "?"
    } Else { ; If (gmail)
	URI := "https://mail.google.com/mail/?view=cm&to=" . EncodeTo(To) . "&"
    }
    If (CC)
	URI .= "cc=" . EncodeTo(CC) . "&"
    If (BCC)
	URI .= "&bcc=" . EncodeTo(BCC) . "&"

    If (mailto) {
	URI .= ConstructURL("subject","body")
    } Else { ; If (gmail)
	URI .= "su=" . UriEncodeR(subject) . "&body=" . UriEncodeR(body)
    }
    GuiControl,,URI,%URI%
return

EncodeTo(csv) {
    o:=""
    Loop Parse, csv, CSV
    {
	o .= EncodeSingleAddress(A_LoopField) . ","
    }
    return SubStr(o, 1, -1)
}

EncodeSingleAddress(a) {
    If (InStr(a, "@")) { 
	If (RegexMatch(a, "^(.+)\<([^ >]+@[^ >]+\.[^ >]+)\>(.+)$", s)) { ; "Name <address> comment"
	    return UriEncodeR(s1) . "<" . s2 . ">" . UriEncodeR(s3)
	} Else If (!InStr(a, " ")) { ; just "address"
	    return a
	}
    }
    ; it's just name or comment, there's no @, there are spaces in address, or something else wrong. Encode everything!
    return UriEncodeR(a)
}

ConstructURL(varNames*) {

    out := ""
    For i,v in varNames {
	If(%v%) {
	    out .= v . "=" . UriEncodeR(%v%) . "&"
	}
    }
    
    return SubStr(out,1,-1)
}

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
