;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;#Warn
;#Warn LocalSameAsGlobal, OutputDebug

;arguments variants:
;addRetailTechAccounts.ahk <login> <FirstName>
;addRetailTechAccounts.ahk <logins-list-file>

;logins-list-file format:
;Login	FirstName

debug:=0
FileEncoding UTF-8

listpath=%1%
If (FileExist(listpath)) {
    Loop Read, %listpath%
    {
	If (RegExMatch(A_LoopReadLine, "^(?P<login>[^ \t]+)\t(?P<FirstName>[^\t]+)?(?P<leftovers>.*)$", m)) {
	    AddRetailDept(mlogin, mFirstName, mleftovers)
	} Else {
	    Throw Exception("Не удалось разобрать строку",,listpath " (" A_Index "):`n" A_LoopReadLine)
	}
    }
} Else {
    login=%1%
    firstName=%2%
    If (!login) {
	InputBox login, %A_ScriptName%, login
	If (ErrorLevel)
	    Exitapp
    }
    If (!firstName) {
	InputBox firstName, %A_ScriptName%, firstName
	If (ErrorLevel)
	    Exitapp
	If (!EndsWith(firstName, " " login "@"))
	    firstName .= " " login "@"
    }
    MsgBox % AddRetailDept(login, firstName)
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
