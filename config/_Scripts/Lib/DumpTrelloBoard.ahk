;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

If (A_ScriptFullPath == A_LineFile) {
    boardID = %1%
    dumpFName = %2%
    arcName = %3%
    If (!dumpFName)
	dumpFName = %boardID%.json
    If (!arcName)
	arcName = %dumpFName%.7z
    Try {
	ExitApp DumpTrelloBoard(boardID, dumpFName, arcName)
    } Catch e
	Throw % e ? (IsObject(e) ? JSON.Dump(e) : e ) : (A_LastError ? A_LastError : -1)
    
}

DumpTrelloBoard(ByRef boardID, ByRef dumpFName, ByRef arcName) {
    global exe7z
    dumpTmp = %dumpFName%.tmp
    If (trelloReq := TrelloAPI1("GET", "/boards/" . boardID . "/cards", boardDump) && (IsObject(fout := FileOpen(dumpTmp, "w")) && fout.Write(boardDump), fout.Close())) {
	FileMove %dumpTmp%, %dumpFName%, 1
	
	If (arcName) {
	    If (!exe7z)
		EnvGet exe7z, exe7z
	    If (!exe7z)
		TryInvokeFunc_in_DumpTrelloBoard("find7zexe","find7zaexe")

	    RunWait %exe7z% a -mx=9 "%arcName%.new" "%dumpFName%",,Min UseErrorLevel
	    If (!ErrorLevel)
		FileMove %arcName%.new, %arcName%, 1
	}
	return %ErrorLevel%
    } Else
	Throw Exception(trelloReq ? "TrelloAPI1()" : "Writing " dumpTmp " failed",, "Last error: " A_LastError)
}

TryInvokeFunc_in_DumpTrelloBoard(fnNames*) {
    local i,fnName,rv
    For i,fnName in fnNames
	If(IsFunc(fnName))
	    Try
		If (rv:=%fnName%())
		    return rv
    return
}

#include *i %A_LineFile%\..\find7zexe.ahk
#include *i %A_LineFile%\..\TrelloAPI1.ahk
