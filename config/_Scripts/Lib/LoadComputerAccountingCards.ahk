;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

LoadComputerAccountingCards(ByRef lists := "") {
    global exe7z
    static boardDumpDirs := [ A_LineFile "\..\..\..\Inventory\trello-accounting\board-dump"
                            , A_ScriptDir "\board-dump"
                            , A_ScriptDir
                            , "\\Srv1S-B.office0.mobilmir\profiles$\Share\Inventory\trello-accounting\board-dump" ]
    
    For i, boardDumpDir in boardDumpDirs {
        If (!FileExist(boardDumpDir "\computer-accounting.json") && FileExist(boardDumpDir "\dump.7z")
            && (exe7z || IsFunc("find7zexe") && (exe7z := Func("find7zexe").Call())
                      || IsFunc("find7zaexe") && exe7z := Func("find7zaexe").Call())) {
            dirTmp := A_Temp "\" A_ScriptName "." A_Now ".tmp"
            RunWait %exe7z% x -y -aoa -o"%dirTmp%" -- "%boardDumpDir%\dump.7z" "computer-accounting.json" "lists.json", %dirTmp%, Min UseErrorLevel
            boardDumpDir := dirTmp
        }
        FileRead jsonboard, %boardDumpDir%\computer-accounting.json
        If (dirTmp)
            FileRemoveDir %dirTmp%, 1
        jsonLists := ""
        If (IsByRef(lists))
            FileRead jsonLists, %boardDumpDir%\lists.json
        If (jsonboard && IsObject(cards := JSON.Load(jsonboard)), jsonLists && (boardlists := JSON.Load(jsonLists)))
            break
    }
    
    If (!IsObject(cards))
        Throw Exception("Cards didn't load",, boardDumpDir)
    
    If (IsObject(boardlists)) {
        lists := Object()
        For i, list in boardlists
            lists[list.id] := list.name
        boardlists :=
    }
    return cards
}

#include %A_LineFile%\..\JSON.ahk
#include *i %A_LineFile%\..\find7zexe.ahk
