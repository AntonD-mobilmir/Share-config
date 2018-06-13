;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8
;boardID := "5732cc3d0a8bee805cab7f11" ; Учёт системных блоков
EnvGet RunInteractiveInstalls, RunInteractiveInstalls
RunInteractiveInstalls:=RunInteractiveInstalls!="0"

Try {
    query=
    argc = %0%
    If (argc) {
        query := CommandLineArgs_to_FindTrelloCardQuery(options := Object())
        If (options.HasKey("log"))
            options.log := Expand(options.log)
        If (options.HasKey("silent"))
            RunInteractiveInstalls := !options.silent
        Else
            RunInteractiveInstalls := options.interactive
    }

    EnvSet RunInteractiveInstalls,RunInteractiveInstalls
    
    argLog := options.log ? "/log """ options.log """" : ""
    RunWait "%A_AhkPath%" /ErrorStdOut "%A_ScriptDir%\DumpBoard.ahk" 
    FileRead jsoncards, %A_ScriptDir%\..\trello-accounting\board-dump\computer-accounting.json
    cards := JSON.Load(jsoncards)

    If (!options.HasKey("fp") && IsObject(query)) {
        c := 0
        For i in query
            c++
        If (!c)
            query := ""
    }

    ExitApp (IsObject(query) || options.HasKey("fp")) ? FillInCard(query, options) : (ProcessDir(A_ScriptDir "\..\trello-accounting\update-queue", "\\Srv0.office0.mobilmir\profiles$\Share\Inventory\trello-accounting\update-queue"))
} Catch e {
    ShowError(ObjectToText(e))
}
ExitApp -1

ProcessDir(ByRef srcDirs*) {
    static SuffixesToQueries := {".json": "fp", ".txt": "", " TVID.txt": {1: "TVID"}, " trello-id.txt": {1: "URL", 4: "id"}}
    
    hostNames := {}
    For i, nameRegex in [ "S)^(?P<Hostname>[^ ]+) (?P<DateTime>\d{4}(-\d\d){2}\s{1,2}\d+(\.\d+)?)(?P<Suffix>.*)"
                        , "S)^(?P<Hostname>[^ .]+)(?P<Suffix>.*)" ] {
        For i, srcDir in srcDirs
            Loop Files, %srcDir%\*.json
                If (RegexMatch(A_LoopFileName, nameRegex, m))
                    If (!hostNames.HasKey(mHostname) || hostNames[mHostname] < mDateTime)
                        hostNames[mHostname] := mDateTime
    }
    
    For Hostname, mDateTime in hostNames {
        query := {Hostname: Hostname}, options := {log: srcDirs[1] "\" Hostname ".log"}
        commonsuffix := "\" Hostname . (mDateTime ? " " mDateTime : "")
        For i, srcDir in srcDirs {
            For fnamesuffix, qParam in SuffixesToQueries {
                Loop Files, %srcDir%%commonsuffix%%fnamesuffix%
                    If (IsObject(qParam)) {
                        lastLine := qParam.MaxIndex()
                        Loop Read, %A_LoopFileFullPath%
                            If (qParam.HasKey(A_Index))
                                query[qParam[A_Index]] := A_LoopReadLine
                        Until A_Index >= lastLine
                    } Else
                        options[qParam] := A_LoopFileFullPath
            }
        }
        ;MsgBox % A_ThisFunc "`noptions: " ObjectToText(options) "`n`nquery: " ObjectToText(query)
        FileAppend %A_Now% Processing %commonsuffix%`n, % options.log
        If (FillInCard(query, options) == 1) {
            For i, srcDir in srcDirs
                Try {
                    FileDelete %srcDir%\%Hostname% *
                    FileDelete %srcDir%\%Hostname%.*
                } Catch e {
                    LogError(e, options.log)
                }
        } Else
            Throw Exception("FillInCard returned fail")
    }
}

FillInCard(ByRef query, ByRef options := "", ByRef fp := "") {
    global cards
    static blockCheckRegexp := ""
    ;MsgBox % A_ThisFunc "`n" ObjectToText({query: query, options: options, fp: fp})
    If (!IsObject(fp) && pathjsonfp := options.fp) {
        FileRead jsonfp, %pathjsonfp%
        fp := JSON.Load(jsonfp)
    }
    If (cID := options.id) {
        ;"idShort":330
        If (cID ~= "^[0-9a-f]{24}$") ; "id":"578e28a308fa5fd1a2cbfaea"
            cardID := cID
        Else If (FileExist(cID))
            FileReadLine cardID, %cID%, 4
        Else If (cID ~= "^[^ ]{8}$") ; "shortLink":"bbUOOuFD"
            query.shortLink := cID
        Else If (cID ~= "^https://trello.com/c/[^ /]{8}$") ; "shortUrl":"https://trello.com/c/bbUOOuFD"
            query.shortUrl := cID
        Else If (cID ~= "^https://trello.com/c/[^ /]{8}/") ; "url":"https://trello.com/c/bbUOOuFD/330-s1151-2-3-%D0%B2-%D0%B1%D1%83-%D0%BA%D0%BE%D1%80%D0%BF%D1%83%D1%81%D0%B5-mitx-reserve-mitx2"
            query.url := cID
    }
    If (options.log)
        logFile := options.log, logEncoding := ""
    Else
        logfile := "*", logEncoding := "CP1"
    If (!IsObject(lfo := FileOpen(logfile, "a", logEncoding)))
        Throw Exception("Не открылся файл журнала",, logfile)
    lfo.WriteLine(ObjectToText({query: query, Fingerprint: fp}))
    lastMatch := ExtendedFindTrelloCard(query, cards, nMatches := 0, fp)
    lfo.WriteLine("lastMatch: " ObjectToText(lastMatch))

    If (nMatches==1) {
        For i in lastMatch {
            card := TrelloAPI1("GET", "/cards/" cards[i].id, respTrelloAPI := Object()) ; card := cards[i] to save API calls
            cardID := card.id 
            If (!cardID)
                Throw Exception("Карточка без ID получена от Trello", A_LineFile ":" A_ThisFunc ":" A_LineNumber, ObjectToText({query: "/cards/" cards[i].id, response: respTrelloAPI, lastMatch: lastMatch}))
            cardDesc := card.desc
            lfo.WriteLine("Найдена карточка " card.name " <" card.shortUrl "> #" cardID "`n" cardDesc)
            textfp=
            If (pathtextfp := options.txt)
                FileRead textfp, %pathtextfp%
            If (!textfp) { ; txt option is not specified, or file is empty or can't be read
                If (IsObject(fp))
                    textfp := GetFingerprint_Object_To_Text(fp)
                Else
                    Throw Exception("Текст отпечатка для " card.name " <" card.shortUrl "> не определен, нечего добавлять в карточку.",,ObjectToText(lastMatch))
            }
            
            lfo.WriteLine("Текст отпечатка: " textfp)
            Loop Parse, textfp, `n
            {
                ; Если любой из строк %textfp% нет в карточке, найти блок ````nCPU: …`nSystem: …`n``` , сравнить с %textfp%, отсутствующие в новом %textfp% строки добавить в комментарий и заменить на новый %textfp%
                trimmedfpline := Trim(A_LoopField)
                If (trimmedfpline && !InStr(cardDesc, trimmedfpline)) {
                    lfo.WriteLine("`tВ карточке не найдена строка " trimmedfpline " из отпечатка. Описание карточки будет изменено.")
                    
                    If (blockCheckRegexp=="") {
                        For s in GetWMIQueryParametersforFingerprint()
                            blockCheckRegexp .= (A_Index == 1 ? "" : "|") . s ; варианты начала строк
                        blockCheckRegexp := "(\n+|^)``````\n+(?P<text>((" . blockCheckRegexp . "):[^\n]+\n+)+)``````\n*"
                    }
                    
                    If (startCardDescFP := RegexMatch(cardDesc, blockCheckRegexp, cardDescFP)) {
                        newDesc := Trim(SubStr(cardDesc, 1, startCardDescFP - 1) "`n" SubStr(cardDesc, startCardDescFP + StrLen(cardDescFP)), "`n`r")
                        
                        tokenizingSeparators = `n`r%A_Space%%A_Tab%`,
                        commentText =
                        currentPos := 0
                        Loop Parse, cardDescFPtext, %tokenizingSeparators%
                        {
                            currentPos += StrLen(A_LoopField) + 1
                            If (!InStr(textfp, Trim(A_LoopField)))
                                commentText .= A_LoopField SubStr(cardDescFPtext, currentPos, 1)
                        }
                        commentText := Trim(commentText, tokenizingSeparators)
                        lfo.WriteLine("`tК карточке будет добавлен комментарий: " commentText)
                        If (commentText)
                            If (!TrelloAPI1("POST", "/cards/" cardID "/actions/comments?text=" UriEncode("Из отпечатка удалены строки:`n`n```````n" Trim(commentText, "`n") "`n``````"), r := ""))
                                Throw Exception("Ошибка при добавлении комментария",,r)
                    } Else {
                        ; ToDo: удалять описание в других форматах (например, отдельностоящая строка с MAC-адресом)
                        newDesc := cardDesc
                    }
                    newDesc .= "`n`n```````n" Trim(textfp, "`r`n`t ") "`n``````"
                    lfo.WriteLine("`tНовое описание карточки: " newDesc)
                    If (!TrelloAPI1("PUT", "/cards/" cardID "?desc=" UriEncode(newDesc), r := ""))
                        Throw Exception("Ошибка при изменении описания карточки",,r)
                    break
                }
            } ; runs until first line of textfp missing from cardDesc
            ;otherwise, all lines from textfp are already in card, nothing to add/update
        }
        lfo.Close()
        return 1
    } Else {
        Throw Exception("Количество подходящих карточек не равно 1",, nMatches ? ObjectToText(lastMatch) : nMatches)
    }
}

ShowError(ByRef text) {
    global RunInteractiveInstalls
    LogError(text)
    
    If (RunInteractiveInstalls)
	MsgBox %text%
    ExitApp 0x100
}

LogError(ByRef msg, ByRef morepaths*) {
    static ferrlog, stderr
    pathCommonErrorLog := A_ScriptDir "\..\trello-accounting\update-queue\errors.log"
             , logTime := A_Now
             , text    := IsObject(msg) ? ObjectToText(msg) : msg

    Try {
        If (!IsObject(stderr))
            stderr := FileOpen("**", "w", "CP1")
        stderr.WriteLine(logTime " " A_UserName "@" A_ComputerName A_Tab text)
    }
    If (!IsObject(ferrlog)) {
        Try FileGetSize logsize, %pathCommonErrorLog%, M
        If (logsize>1)
            Try FileMove %pathCommonErrorLog%, %pathCommonErrorLog%.bak, 1
        ferrlog := FileOpen(pathCommonErrorLog, "a")
    }
    ferrlog.WriteLine(logTime " " text)
    For i, path in morepaths
        Try FileAppend %logTime% %text%`n, %path%
}

#include %A_ScriptDir%\..\..\config\_Scripts\Lib\FindTrelloCard.ahk
#include %A_ScriptDir%\..\..\config\_Scripts\Lib\ObjectToText.ahk
#include %A_ScriptDir%\..\..\config\_Scripts\Lib\TrelloAPI1.ahk
#include %A_ScriptDir%\..\..\config\_Scripts\Lib\GetFingerprint.ahk
#include %A_ScriptDir%\..\..\config\_Scripts\Lib\Expand.ahk
