;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;#Warn
;#Warn LocalSameAsGlobal, OutputDebug
;
; варианты аргументов:
;CreatePDDAcc.ahk <login> 
;CreatePDDAcc.ahk <файл со списком учетных записей>
;
; формат файла со списком учетных записей:
;login[@domain]	FirstName	LastName
;
; Если домен не указан в строке, скрипт попытается использовать начало имени файла (до первого пробела) без расширения в качестве домена

debug:=0
FileEncoding UTF-8

acclist := {}

listpath=%1%
If (FileExist(listpath)) {
    logPath = %listpath%.log
    Loop Read, %listpath%
    {
	If (RegExMatch(A_LoopReadLine, "^(?P<email>(?P<login>[^ @\t]+)(@(?P<domain>[^ \t]+))?)(\t((?P<FirstName>[^\t]+)\t(?P<LastName>[^\t]+)?)?(?P<leftovers>.*))?$", m)) {
	    If (!mdomain) {
		SplitPath listpath,,,,listNameNoExt
		If (domnameLen := InStr(listNameNoExt, " "))
		    mdomain := SubStr(listNameNoExt, 1, domnameLen - 1)
		Else
		    mdomain := listNameNoExt
		memail := mlogin "@" mdomain
	    }
	    If acclist.HasKey(memail)
		Throw Exception("Учетная запись указана повторно",, memail "`n" listpath " (" A_Index "):`n" A_LoopReadLine)
	    acclist[memail] := {login: mlogin, domain: mdomain, FirstName: mFirstName, LastName: mLastName}
	} Else {
	    Throw Exception("Не удалось разобрать строку",, listpath " (" A_Index "):`n" A_LoopReadLine)
	}
    }
} Else {
    logPath = %A_ScriptName%.log
    reqFieldsSeq := ["login", "domain", "FirstName", "LastName"]
    argC = %0%
    argN := 1
    Loop
    {
	acc := {}
	For i, fieldName in reqFieldsSeq {
	    If (argv == "") {
		argv := %argN% ; нельзя использовать %i%, потому что login может быть как отдельно от домена, так и в виде login@domain. Во втором случае все оставшиеся аргументы сдвигаются.
		If (i==1) {
		    If (argv == "") {
			InputBox argv, %A_ScriptName%, Введите полный адрес e-mail (login@domain)
			If (ErrorLevel)
			    Exitapp
		    }
		    If (atPos := InStr(argv, "@")) {
			acc[fieldName] := SubStr(argv, 1, atPos-1)
			argv := SubStr(argv, atPos+1)
			continue
		    }
		}
	    }
	    acc[fieldName] := argv
	    argv=
	    If (++argN > argC)
		break
	}
	acclist.Push(acc)
    } Until argN > argC
}

For accID, acc in acclist {
    If (!AddMailbox(acc.domain, acc.login, pass := GenPass(), acc.FirstName, acc.LastName, response))
	FileAppend "<!>:", %logPath%
    FileAppend % acc.login "@" acc.domain A_Tab pass A_Tab acc.FirstName A_Tab acc.LastName A_Tab response "`n", %A_ScriptName%.log
}
ExitApp
