;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

previousDumpsMask = %A_ScriptDir%\..\old\board-dumps\*.json
currentDumpPath   = %A_ScriptDir%\..\trello-accounting\board-dump\computer-accounting.json

argc = %0%
If (argc) {
    logpath = %A_ScriptDir%\..\trello-accounting\change-monitoring\changes%A_Now%.txt
    vars := [previousDumpPath, currentDumpPath, logpath]
    Loop %argc%
    {
	varName := vars[A_Index]
	%varName% := %A_Index%
    }
    CompareBoards(LoadBoard(currentDumpPath), LoadBoard(previousDumpPath), logpath)
} Else {
    fileslist := ""
    Loop Files, %previousDumpsMask%
	filesList .= A_LoopFileName "`n" 
    filesList := SubStr(filesList, 1, -1)
    SplitPath previousDumpsMask,, dumpsDir
    Sort filesList, R
    
    newerCards := LoadBoard(currentDumpPath)
    Loop Parse, filesList, `n
    {
	;newerCards := olderCards
	olderCards := LoadBoard(dumpsDir "\" A_LoopField)
	CompareBoards(newerCards, olderCards, A_ScriptDir "\..\trello-accounting\change-monitoring\changes " A_LoopField " " A_Now ".txt")
    }
}
ExitApp

LoadBoard(ByRef path) {
    static boardsCache := {}, recentPaths := [], removalArray := []
    If (boardsCache.HasKey(path))
	return boardsCache[path]
    FileRead dump, %path%
    board := JSON.Load(dump)
    boardsCache[path] := board
    
    recentPaths.InsertAt(1, path)
    For i, p in recentPaths {
	If (i > 3) {
	    boardsCache.Delete(p)
	    removalArray[i] := ""
	}
    }
    For i in removalArray
	recentPaths.Delete(i)
    return board
}

CompareBoards(currCards, prvCards, ByRef logpath) {
    static lastCards, curCardIDsToIdx
    diffs := []
    If (currCards != lastCards) {
	curCardIDsToIdx := {}
	For i, card in currCards
	    curCardIDsToIdx[card.id] := i
    }

    For i, card in prvCards {
	cardid := card.id
	currCard := currCards[curCardIDsToIdx[cardid]]
	For field, oldV in card {
	    newV := currCard[field]
	    If (oldV != newV) {
		If (!IsObject(diffs[cardid]))
		    diffs[cardid] := Object()
		diffs[cardid][field] := FindRemovedInfo(oldV, newV)
	    }
	}
    }
    If ((diffsText := Trim(ObjectToText(diffs))) && logf := FileOpen(logpath, "a")) {
	logf.WriteLine(diffsText)
	logf.Close()
    }
}

FindRemovedInfo(ByRef oldt, ByRef newt) {
    removed := Object()
    Loop Parse, oldt, %A_Space%`n`r
	If (!InStr(newt, A_LoopField))
	    If ((rmvdTxt := Trim(A_LoopField, " `t`n`r")) != "")
		removed[A_Index] := rmvdTxt
    return removed.Length() ? removed : ""
}

#include <JSON>
