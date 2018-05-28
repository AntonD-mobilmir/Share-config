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

boardDumpDirs := [ A_LineFile "\..\..\..\Inventory\trello-accounting\board-dump"
	         , A_ScriptDir "\board-dump"
	         , A_ScriptDir
	         , "\\Srv1S-B.office0.mobilmir\profiles$\Share\Inventory\trello-accounting\board-dump"
	         , "\\Srv0.office0.mobilmir\profiles$\Share\Inventory\trello-accounting\board-dump" ]

pathTrelloID=%A_AppDataCommon%\mobilmir.ru\trello-id.txt
regpathAutorun=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
regKNAutorun=%A_ScriptName%

EnvGet envParams, Write-trello-id.ahk-params
; ToDo: save fingerprint on request to avoid double-fingerprinting in Inventory\collector-script\SaveJsonFingerprint.cmd
argc=%0%
arg1=%1%
nag := arg1="/nag" || envParams="/nag"
If (argc && !nag) {
    query := CommandLineArgs_to_FindTrelloCardQuery()
    FileAppend % JSON.Dump(query) "`n", *, CP1
} Else {
    RegWrite REG_SZ, %regpathAutorun%, %regKNAutorun%, "%A_AhkPath%" "%A_ScriptFullPath%"
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

lastMatch := ExtendedFindTrelloCard(query, cards, nMatches, fp, Func("CountSearchRuns"))

EnvGet RunInteractiveInstalls, RunInteractiveInstalls
If (writeSavedID && nMatches==1) {
    For i, match in lastMatch {
	newtxtf := FileOpen(newPathSavedID := PathSavedID ".tmp", "w`n")
	newtxtf.WriteLine(cards[i].url								; 1
		   . "`n" (Hostname ? Hostname : ExtractHostnameFromCardName(cards[i].name))	; 2
		   . "`n" cards[i].name								; 3
		   . "`n" cards[i].id								; 4
		   . "`n" lists[cards[i].idList] )						; 5
		 ;. "`n`n" JSON.Dump(cards[i])
	newtxtf.Close()
	If (FileExist(PathSavedID)) {
	    FileReadLine oldurl, %PathSavedID%, 1
	    FileReadLine oldID, %PathSavedID%, 4
	    ;"shortLink":"6D5aO2qM"
	    If (!(CutTrelloCardURL(oldurl, 1) == cards[i].shortLink && oldID == cards[i].id)) {
		newcardname = %PathSavedID%.%A_Now%.txt
		FileMove %newPathSavedID%, %newcardname%
		If (!(RunInteractiveInstalls == "0"))
		    Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%A_AppDataCommon%\mobilmir.ru" "Карточка`, найденная для компьютера`, отличается ссылкой или ID от уже сохранённой. Найденная карточка записана в %newcardname%`, а файл %PathSavedID% остался без изменений."
		ExitApp
	    }
	}
	FileMove %newPathSavedID%, %PathSavedID%, 1
        RegDelete %regpathAutorun%, %regKNAutorun%
	If (!(RunInteractiveInstalls == "0"))
	    Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk"
    }
} Else {
    stageTitles := ["Строгий поиск", "Идентификаторы с заголовками полей", "Идентификаторы без заголовков (только значения)"]
    ffc := FileOpen(pathffc := A_Temp "\все найденные карточки " A_Now ".txt", "a`n")
    For searchStage, extSearchQuery in CountSearchRuns()
	ffc.WriteLine( "Найдено " nMatches " карточ" NumForm(nMatches,"ка","ки","ек")
		     . "`nПараметры строгого поиска: " JSON.Dump(query)
		     . "`nПоследный выполненный способ поиска: " stageTitles[searchStage]
		     . (searchStage > 1 ? "`n`tИспользованные регулярные выражения: " JSON.Dump(extSearchQuery) : "")
		     . "`n`nИнформация о системе:`n" GetFingerprint_Object_To_Text(fp) "`n`n---")
    For i, match in lastMatch
	ffc.WriteLine("`nУ карточки " cards[i].name " " cards[i].shortUrl "/" cards[i].idShort "`n`tсовпало " JSON.Dump(match) "`n`t" cards[i].desc)
    ffc.Close()
    If (!(RunInteractiveInstalls == "0"))
	Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%pathffc%" "Подходящих карточек: %nMatches% (когда всё в порядке`, должна быть одна)"
}
; если nMatches = 1, найдена всего одна карточка, всё в порядке → выход без ошибок (код 0)
; если nMatches = 0, карточек не найдено → код ошибки 1
; если nMatches > 1, найдено больше 1 подходящей карточки → код ошибки = количеству найденных карточек
ExitApp nMatches==1 ? 0 : (nMatches==0 ? 1 : nMatches)

TryCallFunc(funcName, optns*) {
    Try return %funcName%(optns*)
}

CountSearchRuns(ByRef matches := "", ByRef cards := "", ByRef extSearch := "") {
    static timesInvoked := 0, extSearchMemory
    If (IsObject(cards)) {
	extSearchMemory := extSearch
	timesInvoked++
    }
    return {(timesInvoked): extSearchMemory}
}

#include <find7zexe>
#include <JSON>
#include <CutTrelloCardURL>
#include <EscapeRegex>
#include <FindTrelloCard>
