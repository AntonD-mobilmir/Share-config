;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

;https://redbooth.com/a/#!/projects/59756/tasks/32350056
;https://drive.google.com/a/mobilmir.ru/file/d/0B6JDqImUdYmlejlIRTRWY0JCZjA/view?usp=sharing

#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

pathTrelloIDtxt = %A_AppDataCommon%\mobilmir.ru\trello-id.txt
pathTrelloCardDesctxt = %A_AppDataCommon%\mobilmir.ru\trello-card.txt

pathTrelloID=%A_AppDataCommon%\mobilmir.ru\trello-id.txt
regpathAutorun=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
regKNAutorun=%A_ScriptName%

EnvGet envParams, Write-trello-id.ahk-params
; ToDo: save fingerprint on request to avoid double-fingerprinting in Inventory\collector-script\SaveJsonFingerprint.cmd
nag := A_Args[1]="/nag" || envParams="/nag"
If (A_Args.Length() && !nag) {
    query := CommandLineArgs_to_FindTrelloCardQuery()
    FileAppend % JSON.Dump(query) "`n", *, CP1
} Else {
    RegWrite REG_SZ, %regpathAutorun%, %regKNAutorun%, "%A_AhkPath%" "%A_ScriptFullPath%"
    writeSavedID := 1
    If (FileExist(pathTrelloIDtxt)) {
	lineVarNames := ["txtshortUrl", "txtID", "oldHostname"]
	Loop Read, %pathTrelloIDtxt%
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

cards := LoadComputerAccountingCards(lists := "")
lastMatch := ExtendedFindTrelloCard(query, cards, nMatches, fp, Func("CountSearchRuns"))

EnvGet Unattended, Unattended
If (!Unattended) {
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    Unattended := RunInteractiveInstalls=="0"
}

If (writeSavedID && nMatches==1) {
    For i, match in lastMatch {
        card := cards[i]
        SplitPath pathTrelloIDtxt,,OutDir
        FileCreateDir %OutDir%
	newtxtf := FileOpen(newpathTrelloIDtxt := pathTrelloIDtxt ".tmp", "w`n")
	If (!IsObject(newtxtf))
            Throw Exception(ErrorLevel ? ErrorLevel : A_LastError,, "Ошибка при открытии файла для записи: """ newpathTrelloIDtxt """")
	newtxtf.WriteLine(card.url								; 1
		   . "`n" (Hostname ? Hostname : ExtractHostnameFromCardName(card.name))	; 2
		   . "`n" card.name								; 3
		   . "`n" card.id								; 4
		   . "`n" lists[card.idList] )						; 5
		 ;. "`n`n" JSON.Dump(card)
	newtxtf.Close()
	If (FileExist(pathTrelloIDtxt)) {
	    FileReadLine oldurl, %pathTrelloIDtxt%, 1
	    FileReadLine oldID, %pathTrelloIDtxt%, 4
	    ;"shortLink":"6D5aO2qM"
	    If (!(CutTrelloCardURL(oldurl, 1) == card.shortLink && oldID == card.id)) {
		newcardname = %pathTrelloIDtxt%.%A_Now%.txt
		FileMove %newpathTrelloIDtxt%, %newcardname%
		If (!Unattended)
		    Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%A_AppDataCommon%\mobilmir.ru" "Карточка`, найденная для компьютера`, отличается ссылкой или ID от уже сохранённой. Найденная карточка записана в %newcardname%`, а файл %pathTrelloIDtxt% остался без изменений."
		ExitApp
	    }
	}
	FileMove %newpathTrelloIDtxt%, %pathTrelloIDtxt%, 1
	If (IsObject(fhDesc := FileOpen(pathTrelloCardDesctxt, "w"))) {
            fhDesc.WriteLine(card.desc "`n" ObjectToText(card))
            fhDesc.Close()
	}
        RegDelete %regpathAutorun%, %regKNAutorun%
	If (!Unattended)
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
    For i, match in lastMatch {
        card := cards[i]
	ffc.WriteLine("`nУ карточки " card.name " " card.shortUrl "/" card.idShort "`n`tсовпало " JSON.Dump(match) "`n`t" card.desc)
    }
    ffc.Close()
    If (!Unattended)
	Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%pathffc%" "Подходящих карточек: %nMatches% (когда всё в порядке`, должна быть одна)"
}
; если nMatches = 1, найдена всего одна карточка, всё в порядке → выход без ошибок (код 0)
; если nMatches = 0, карточек не найдено → код ошибки 1
; если nMatches > 1, найдено больше 1 подходящей карточки → код ошибки = количеству найденных карточек
ExitApp nMatches==1 ? 0 : (nMatches==0 ? 1 : nMatches)

CountSearchRuns(ByRef matches := "", ByRef cards := "", ByRef extSearch := "") {
    static timesInvoked := 0, extSearchMemory
    If (IsObject(cards)) {
	extSearchMemory := extSearch
	timesInvoked++
    }
    return {(timesInvoked): extSearchMemory}
}

#include <JSON>
#include <CutTrelloCardURL>
#include <EscapeRegex>
#include <FindTrelloCard>
#include <LoadComputerAccountingCards>
#include <CommandLineArgs_to_FindTrelloCardQuery>
