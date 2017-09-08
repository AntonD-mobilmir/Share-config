;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8
log = %A_ScriptFullPath%.log
GetTrelloAuthToken(,, "read", "mobilmir.ru Trello Backup AutoHotkey Script")
;TrelloAPI1(method, req, response, data)

queryOrgsBoards := queryMyBoards := 1
filter := ""
Loop %0%
{
    argv := %A_Index%
    If (argv = "/org")
	queryMyBoards := 0
    If (argv = "/my" || argv = "/me")
	queryOrgsBoards := 0
    Else If (!filter)
	filter := "?filter=" argv
    Else Throw Exception("Excess argument",, "(arg no. " A_Index ") " argv)
}

FormatTime today,, yyyy-MM-dd
batchdir := today
While FileExist(batchdir)
    batchdir := today . Format("#{:.2i}", A_Index)
FileCreateDir %batchdir%
FileAppend `n[·] %A_Now%`tStaring backup to %batchdir%`n, %log%

If (queryOrgsBoards) {
    FileAppend [→] %A_Now%`tGET /members/me/organizations`n, %log%
    For i,org in TrelloAPI1("GET", "/members/me/organizations", jsonOrgs := Object()) {
	QueueBackupBoards("/organizations/" org.id "/boards" filter)
    }
    TransactWrite(batchdir "\organizations.json", jsonOrgs)
}

If (queryMyBoards)
    QueueBackupBoards("/members/me/boards" filter)

ExitApp QueueBackupBoards()

QueueBackupBoards(ByRef query := "") {
    global log, batchdir
    static backupBoards := {}, oAllBoards := ""
    
    If (oAllBoards=="") {
	FileRead jsonOldBoards, boards.json
	If (jsonOldBoards) {
	    FileAppend [→] %A_Now%`tLoaded old board list from boards.json`n, %log%
	    oAllBoards := JSON.Load(jsonOldBoards)
	} Else {
	    FileAppend [.] %A_Now%`tOld board list (boards.json) is empty`n, %log%
	    oAllBoards := {}
	}
    }
    
    If (query) {
	If (curBoards := TrelloAPI1("GET", query, jsonBoards := Object())) {
	    For i,board in curBoards {
		If (board.dateLastActivity != oAllBoards[board.id].dateLastActivity) {
		    oAllBoards[board.id] := board
		    backupBoards[board.id] := ""
		}
	    }
	    FileAppend [→] %A_Now%`tFound %i% boards in %query%`n, %log%
	} Else {
	    Fail("GET " query, jsonBoards)
	}
	WriteoutBatch(batchdir "\boards*.json", jsonBoards)
	WriteoutBatch(batchdir "\boards*.txt", BoardsFormatTextReport(curBoards)[1])
    } Else {
	WriteoutBatch(batchdir "\*.json", oAllBoards)
	
	backupListHasContents := 0
	For boardid in backupBoards {
	    backupListHasContents := 1
	    WriteoutBatch(batchdir "\*.json", BatchRequest("/boards/" boardid "/cards/"))
	    WriteoutBatch(batchdir "\*.json", BatchRequest("/boards/" boardid "/actions/"))
	}
	WriteoutBatch(batchdir "\*.json", BatchRequest())
	TransactWrite(batchdir "\boards.txt", BoardsFormatTextReport(oAllBoards, backupBoards)[1])
	
	TransactWrite("boards.json", JSON.Dump(oAllBoards))
	TransactWrite("boards.txt", BoardsFormatTextReport(oAllBoards)[1])
    }
    return backupListHasContents
}

WriteoutBatch(ByRef dest, ByRef contents) {
    static ia := {}
    If (contents) {
	key := L64Hash(dest)
	If (!ia.HasKey(key))
	    ia[key] := 0
	return TransactWrite(StrReplace(dest, "*", Format("{:.4i}", ++ia[key])), contents)
    }
}

BatchRequest(ByRef req := "") {
    global log
    static urls := "", TrelloRequestsPerBatch := 10, leftRequests := 10 ; https://developers.trello.com/v1.0/reference#batch-1

    If (req) {
	urls .= (urls ? "," : "") . req
	If (--leftRequests > 0)
	    return
    }
    
    If (urls) {
	If (TrelloAPI1("GET", "/batch/?urls=" urls, resp)) {
	    FileAppend [→] %A_Now%`tGET /batch/?urls=%urls%`n, %log%
	    leftRequests := TrelloRequestsPerBatch
	} Else {
	    Fail(A_ThisFunc, urls " → " resp)
	}
	return "{""urls"":""" urls """ , ""response"": " resp "}", urls := ""
    }
}

BoardsFormatTextReport(ByRef ObjBoards, ByRef BackupBoards := "") {
    static TxtAttribs := ["shortUrl", "closed", "name", "starred", "id", "dateLastActivity", "idOrganization"]
    For i,v in TxtAttribs
	out .= v "`t"
    For i, objBoard in ObjBoards {
	If (!IsObject(BackupBoards) || BackupBoards.HasKey(objBoard.id)) {
	    out .= "`n"
	    For j,v in TxtAttribs
		out .= objBoard[v] "`t"
	}
    }
    
    return [out]
}

TransactWrite(ByRef path, ByRef contents) {
    global log
    If (file := FileOpen(path ".tmp", "w")) {
	file.Write(contents)
	file.Close()
	FileMove %path%.tmp, %path%, 1
	If (ErrorLevel)
	    FileAppend [!] Failed renaming "%path%.tmp" → "%path%"`n, %log%
	Else
	    FileAppend [↓] %A_Now%`tWrote %path%`n, %log%
    } Else {
	Fail("Cannot open file", path ".tmp")
	return 0
    }
    return !ErrorLevel
}

Fail(ByRef status, ByRef details := "") {
    global log
    FileAppend % "[!] " A_Now "`tFailed: " status . (details ? details : "") "`n", %log%
    ;MsgBox 0x10, %A_ScriptName%, %status%`n`n%details%
    Throw Exception(status,,details)
}

; hash functions by Laszlo
; taken from https://autohotkey.com/board/topic/14040-fast-64-and-128-bit-hash-functions/ and modified for AHK_L
;MsgBox % L64Hash("12345678")
;MsgBox % L128Hash("12345678")
L64Hash(x) {						; 64-bit generalized LFSR hash of string x
   ;Local i, R = 0
   R := 0
   LHASH := LHashInit()					  ; 1st time set LHASH0..LHAS256 global table
   Loop Parse, x
   {
	  i := (R >> 56) & 255
	  R := (R << 8) + Asc(A_LoopField) ^ LHASH[i]
   }
   Return Hex8(R>>32) . Hex8(R)
}

L128Hash(x) {					   ; 128-bit generalized LFSR hash of string x
   ;Local i, S = 0, R = -1
   S := 0, R := -1
   LHASH := LHashInit()					  ; 1st time set LHASH0..LHAS256 global table
   Loop Parse, x
   {
	  i := (R >> 56) & 255
	  R := (R << 8) + Asc(A_LoopField) ^ LHASH[i]
	  i := (S >> 56) & 255
	  S := (S << 8) + Asc(A_LoopField) - LHASH[i]
   }
   Return Hex8(R>>32) . Hex8(R) . Hex8(S>>32) . Hex8(S)
}

Hex8(i) {						   ; integer -> LS 8 hex digits
    return Format("{:08X}", i & 0xFFFFFFFF)
;   SetFormat Integer, Hex
;   i:= 0x100000000 | i & 0xFFFFFFFF ; mask LS word, set bit32 for leading 0's --> hex
;   SetFormat Integer, D
;   Return SubStr(i,-7)			  ; 8 LS digits = 32 unsigned bits
}

LHashInit() {					   ; build pseudorandom substitution table
    static LHASH := ""
    If (LHASH=="") {
	;local i, u := 0, v := 0
	u := 0, v := 0
	LHASH := {}
	Loop 256 {
	    TEA(u,v, 1,22,333,4444, 8) ; <- to be portable, no Random()
	    LHASH[A_Index - 1] := (u<<32) | v
	}
    }
    return LHASH
}
									; [y,z] = 64-bit I/0 block, [k0,k1,k2,k3] = 128-bit key
TEA(ByRef y,ByRef z, k0,k1,k2,k3, n = 32) { ; n = #Rounds
   s := 0, d := 0x9E3779B9
   Loop %n% {					   ; standard = 32, 8 for speed
	  k := "k" . s & 3			  ; indexing the key
	  y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
	  s := 0xFFFFFFFF & (s + d)	 ; simulate 32 bit operations
	  k := "k" . s >> 11 & 3
	  z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
}

#include %A_LineFile%\..\..\..\Backups\profiles$\Share\config\_Scripts\Lib\TrelloAPI1.ahk
