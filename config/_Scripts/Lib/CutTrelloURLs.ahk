;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

CutTrelloURLs(block) {
    foundSomething := false
    For i, args in [ [GetTrelloURLRegex("card"),  Func("CutTrelloCardURL") ]
                   , [GetTrelloURLRegex("board"), Func("CutTrelloBoardURL") ] ]
        block := RegexProcess(block, args*), foundSomething := foundSomething || !ErrorLevel, lastError := ErrorLevel ? ErrorLevel : lastError
    ErrorLevel := foundSomething ? 0 : lastError
    return block
}

GetTrelloURLRegex(type := "") {
    static TrelloURLRegex := {card: "`a)((?:https?://)?trello\.com/c/[^/\s>)\n]+)(/[^\s\>\)\n]*)?"
                            , board: "`a)((?:https?://)?trello\.com/b/[^/\s>)\n]+)(/[^\s\>\)\n]*)?"}
    If (type)
        return TrelloURLRegex[type]
    Else
        return TrelloURLRegex
}

CutTrelloBoardURL(ByRef url, ByRef trelloBoardURLRegex) {
    If (RegexMatch(url, trelloBoardURLRegex, m))
        return m1
    Else
        return url
}

#include %A_LineFile%\..\CutTrelloCardURL.ahk
#include %A_LineFile%\..\RegexProcess.ahk
