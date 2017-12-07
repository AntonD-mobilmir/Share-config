;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

;https://redbooth.com/a/#!/projects/59756/tasks/32350056
;https://drive.google.com/a/mobilmir.ru/file/d/0B6JDqImUdYmlejlIRTRWY0JCZjA/view?usp=sharing

#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

Tmp = %A_Temp%\%A_ScriptName%
PathSavedID = %A_AppDataCommon%\mobilmir.ru\trello-id.txt

boardDumpDirs := [ A_LineFile "\..\..\..\Inventory\collector-script\trello-accounting-board-dump"
	         , A_ScriptDir "\trello-accounting-board-dump"
	         , A_ScriptDir ]
argc=%0%
If (argc) {
    FileEncoding UTF-8
    query := CommandLineArgs_to_FindTrelloCardQuery()
    FileAppend % JSON.Dump(query) "`n", *, CP1
} Else {
    writeSavedID := 1
    If (FileExist(PathSavedID)) {
	lineVarNames := ["txtshortUrl", "txtID", "oldHostname"]
	Loop Read, %PathSavedID%
	    If (varName := lineVarNames[A_Index])
		%varName% := A_LoopReadLine
    }
    RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    RegRead NVHostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, NV Hostname
    regViewBak := A_RegView
    SetRegView 32
    RegRead TVID, HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1, ClientID
    SetRegView %regViewBak%

    hostnameAlts := {(Hostname): "Hostname"}
    For varName, varTitle in {A_ComputerName: "Computer Name", NVHostname: "NV Hostname", oldHostname: "hostname from trello-id.txt"}
	If (%varName% && Hostname != %varName%)
	    hostnameAlts[%varName%] := varTitle

    fp := GetFingerprint(textfp := "")
    query := FingerprintMACs_to_FindTrelloCardQuery(fp, {Hostname: hostnameAlts})
    If (txtshortUrl)
	query.URL := txtshortUrl
    If (TVID)
	query.TVID := TVID
}

For i, boardDumpDir in boardDumpDirs {
    If (!FileExist(boardDumpDir "\computer-accounting.json") && FileExist(boardDumpDir "\dump.7z") && (exe7z || exe7z := TryCallFunc("find7zexe") || exe7z := TryCallFunc("find7zaexe"))) {
	RunWait %exe7z% x -y -aoa -o"%tmp%" -- "%boardDumpDir%\dump.7z" "computer-accounting.json" "lists.json", %tmp%, Min UseErrorLevel
	boardDumpDir := tmp
    }
    FileRead jsonboard, %boardDumpDir%\computer-accounting.json
    FileRead jsonLists, %boardDumpDir%\lists.json
    If (jsonboard && IsObject(cards := JSON.Load(jsonboard)), jsonLists && (boardlists := JSON.Load(jsonLists)))
	break
}
If (!IsObject(cards))
    Throw Exception("Cards didn't load",, boardDumpDir)

jsonboard:=jsonLists:=""

If (IsObject(boardlists)) {
    lists := Object()
    For i, list in boardlists
	lists[list.id] := list.name
    boardlists :=
}

For i, match in lastMatch := FindTrelloCard(query, cards, nMatches := 0)
    FileAppend % "Сard " JSON.Dump(cards[i]) " matched with " JSON.Dump(match) "`n", *, CP1
If (!nMatches && IsObject(fp)) { ; по быстрым параметрам карточка не найдена и есть отпечаток
    While (!nMatches && A_Index <= 2) { ;  поиск по серийникам из отпечатка
	For i, match in lastMatch := FindTrelloCard("", cards, nMatches, FingerprintSNs_to_Regexes(fp, A_Index == 2)) ; первая попытка – с заголовками, вторая – без
	    FileAppend % "Сard " JSON.Dump(cards[i]) " regex-" A_Index " matched with " JSON.Dump(match) "`n", *, CP1
    }
}

If (writeSavedID && nMatches==1) {
    newtxtf := FileOpen(newPathSavedID := PathSavedID ".tmp", "w`n")
    newtxtf.WriteLine(cards[i].url
	       . "`n" (Hostname ? Hostname : ExtractHostnameFromCardName(cards[i].name))
	       . "`n" cards[i].name
	       . "`n" cards[i].id
	       . "`n" lists[cards[i].idList]
	     . "`n`n" JSON.Dump(cards[i]))
    newtxtf.Close()
    If (FileExist(PathSavedID)) {
	FileReadLine oldurl, %PathSavedID%, 1
	FileReadLine oldID, %PathSavedID%, 4
	;"shortLink":"6D5aO2qM"
	If (!(CutTrelloCardURL(oldurl, 1) == cards[i].shortLink && oldID == cards[i].id)) {
	    newcardname = %PathSavedID%.%A_Now%.txt
	    FileMove %newPathSavedID%, %newcardname%
	    Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%A_ProgramData%\mobilmir.ru" "Карточка, найденная для компьютера, отличается ссылкой или ID от уже сохранённой. Найденная карточка записана в %newcardname%, а файл %PathSavedID% остался без изменений."
	    ExitApp
	}
    }
    FileMove %newPathSavedID%, %PathSavedID%, 1
    Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk"
} Else {
    ffc := FileOpen(pathffc := A_Temp "\все найденные карточки " A_Now ".txt", "a`n")
    ffc.WriteLine("Найдено " nMatches " карточ" NumForm(nMatches,"ка","ки","ек") ".`nПараметры строгого поиска: " JSON.Dump(query) "`n" (extSearch ? "Параметры расширенного поиска: " JSON.Dump(extSearch) : "Расширенный поиск не выполнялся") "`n`nИнформация о системе:`n" GetFingerprint_Object_To_Text(fp) "`n`n---")
    For i, match in lastMatch
	ffc.WriteLine("`nУ карточки " cards[i].name " " cards[i].shortUrl "/" cards[i].idShort "`n`tсовпало " JSON.Dump(match) "`n`t" cards[i].desc)
    ffc.Close()
    Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%pathffc%" "Подходящих карточек: %nMatches% (когда всё в порядке, должна быть одна)"
}
; если nMatches = 1, найдена всего одна карточка, всё в порядке → выход без ошибок (код 0)
; если nMatches = 0, карточек не найдено → код ошибки 1
; если nMatches > 1, найдено больше 1 подходящей карточки → код ошибки = количеству найденных карточек
ExitApp nMatches==1 ? 0 : (nMatches==0 ? 1 : nMatches)

TryCallFunc(funcName, optns*) {
    Try return %funcName%(optns*)
}

#include <find7zexe>
#include <JSON>
#include <CutTrelloCardURL>
#include <EscapeRegex>
#include <FindTrelloCard>
