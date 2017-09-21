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
	FileAppend "<!>:", %A_ScriptName%.log
    FileAppend % acc.login "@" acc.domain A_Tab pass A_Tab acc.FirstName A_Tab acc.LastName A_Tab response "`n", %A_ScriptName%.log
}
ExitApp

AddRetailDept(ByRef login, ByRef firstName, ByRef leftovers:="") {
    static domains	:= {"k.mobilmir.ru": "(Обмен Рарус)", "rarus.robots.mobilmir.ru": "(Уведомления из Рарус)"}
	 , lists	:= ["all@k.mobilmir.ru"]

    resp1 := resp2 := ""
    For domain, lastName in domains {
	password := GenPass()
	AddMailbox(domain, login, password, firstName, lastName, resp2)
	FileAppend % login . A_Tab . password . A_Tab . firstName . leftovers . A_Tab . resp2 . "`n", %domain%.txt
	
	resp1 .= login "@" domain " → " resp2 "`n`n"
    }
    For i, listAddr in lists {
	If (atPos := InStr(listAddr, "@")) {
	    domain := SubStr(listAddr, atPos + 1)
	    maillist := SubStr(listAddr, 1, atPos - 1)
	}
	AddToList(domain, maillist, login, resp2)
	resp2 := Trim(resp2, "`n`r`t ")
	FileAppend %login%`t%resp2%`n, %listAddr%.txt

	resp1 .= "[+] " listAddr " → " resp2 "`n`n"
    }
    return resp1
}
