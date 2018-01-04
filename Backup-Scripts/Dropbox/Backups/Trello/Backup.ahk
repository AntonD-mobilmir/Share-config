;Командная строка:
;Backup.ahk [ключи]
;    ключи (в любом порядке):
;	/org	не запрашивать доски пользователя для добавления в список резервного копирования
;	/me	не запрашивать доски организации для добавления в список резервного копирования
;	    по умолчанию запрашиваются и те, и те, но каждая доска будет скопирована только один раз;
;	    если указать оба ключа, резервное копирование не будет выполняться
;	путь	папка, куда сохранять резервные копии, список досок и журнал. Должна существовать или должен быть указан путь с "\", иначе скрипт будет считать, что это доп. параметры запроса.
;	доп. параметры запроса	см. https://developers.trello.com/v1.0/reference#boards-nested-resource. Например, boards=open

; arrow mnemonics:
; 	trello  
; 	  ↓↑
; 	script ← → disk

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8
GetTrelloAuthToken(,, "read", "mobilmir.ru Trello Backup AutoHotkey Script")
;TrelloAPI1(method, req, response, data)

SetWorkingDir %A_ScriptDir%
FormatTime today,, yyyy-MM-dd
RegRead Hostname, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname

queryOrgsBoards := queryMyBoards := 0
destDir := filter := ""
Loop %0%
{
    argv := %A_Index%
    If (argv = "/org")
	queryOrgsBoards := 1
    If (argv = "/my" || argv = "/me")
	queryMyBoards := 1
    Else If (Instr(FileExist(argv), "D"))
	destDir := argv
    Else If (InStr(argv, "\")) {
	destDir := argv
	FileCreateDir %destDir%
    } Else If (!filter)
	filter := "?filter=" argv
    Else Throw Exception("Excess argument",, "(arg no. " A_Index ") " argv)
}

If (!destDir)
    destDir := A_ScriptDir "\"
Else If (SubStr(destDir, 0) != "\")
    destDir .= "\"

Log(destDir "\" A_ScriptName " " A_UserName "@" Hostname ".log", "*LogOpen")

baseBatchDir := destDir A_UserName "@" Hostname "\" today
Loop
    batchDir := baseBatchDir . (A_Index > 1 ? Format("#{:.2i}", A_Index) : "")
Until !FileExist(batchDir)
FileCreateDir %batchDir%

Log("Staring backup for" A_UserName " to " batchDir)

If (queryMyBoards >= queryOrgsBoards)
    QueueBackupBoards("/members/me/boards" filter)

If (queryOrgsBoards >= queryMyBoards) {
    Log("GET /members/me/organizations", 2)
    orgsBoardsBatch := ""
    For i,org in TrelloAPI1("GET", "/members/me/organizations", jsonOrgs := Object())
	QueueBackupBoards("/organizations/" org.id "/boards" filter)
    TransactWrite(batchDir "\organizations.json", jsonOrgs)
    
}

ExitApp QueueBackupBoards()

QueueBackupBoards(ByRef query := "") {
    global batchDir, destDir
    static backupBoards := {}, oAllBoards := "", boardFields := ""
    If (boardFields=="")
	For i, v in GetBoardFields()
	    boardFields .= (A_Index > 1 ? "," : "") . v
    
    If (oAllBoards=="") {
	FileRead jsonOldBoards, boards.json
	If (ErrorLevel || !IsObject(oAllBoards := JSON.Load(jsonOldBoards))) {
	    Log("Old board list (boards.json) not loaded", -1)
	    oAllBoards := {}
	} Else
	    Log("Loaded old board list from boards.json", 3)
    }
    
    If (query) {
	Log(query, 2)
	If (curBoards := TrelloAPI1("GET", tmpFullQuery := query . (InStr(query, "?") ? "&" : "?") . "board_fields=" boardFields , jsonBoards := Object())) {
	    For i,board in curBoards {
		If (board.dateLastActivity != oAllBoards[board.id].dateLastActivity) {
		    oAllBoards[board.id] := board
		    backupBoards[board.id] := ""
		}
	    }
	    Log("Found " i " boards via " query, 4)
	} Else {
	    Fail("GET " tmpFullQuery, jsonBoards)
	}
	WriteoutBatch(batchDir "\boards*.json", jsonBoards)
	WriteoutBatch(batchDir "\boards*.txt", BoardsFormatTextReport(curBoards))
    } Else {
	Log("Backing up all boards", 1)
	batchPath := batchDir "\*.json"
	WriteoutBatch(batchPath, oAllBoards)
	
	backupListHasContents := 0
	For boardid in backupBoards {
	    backupListHasContents := 1
	    WriteoutBatch(batchPath, ObjToNEJson(BatchRequest("/boards/" boardid)))
	    WriteoutBatch(batchPath, ObjToNEJson(BatchRequest("/boards/" boardid "/actions/")))
	    WriteoutBatch(batchPath, ObjToNEJson(BatchRequest("/boards/" boardid "/checklists/")))
	    ;Routes do not exist: /1/boards/577f529fbf5d7ba0ec804c7a/tags/ – WriteoutBatch(batchPath, ObjToNEJson(BatchRequest("/boards/" boardid "/tags/"))
	    WriteoutBatch(batchPath, ObjToNEJson(BatchRequest("/boards/" boardid "/labels/")))
	    WriteoutBatch(batchPath, ObjToNEJson(BatchRequest("/boards/" boardid "/lists/")))
	    WriteoutBatch(batchPath, ObjToNEJson(BatchRequest("/boards/" boardid "/members/")))
	    WriteoutBatch(batchPath, ObjToNEJson(BatchRequest("/boards/" boardid "/plugins?filter=enabled")))
	}
	WriteoutBatch(batchPath, ObjToNEJson(BatchRequest()))
	
	; backup Checklists
	
	TransactWrite(batchDir "\boards.txt", BoardsFormatTextReport(oAllBoards, backupBoards))
	
	TransactWrite(destDir "boards.json", JSON.Dump(oAllBoards))
	TransactWrite(destDir "boards.txt", BoardsFormatTextReport(oAllBoards))
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

ObjToNEJson(objOrVal) {
    If (IsObject(objOrVal)) {
	txt := ""
	For i,v in objOrVal
	    txt .= (A_Index > 1 ? ", " : "") . """" i """: " . ObjToNEJson(v)
	return "{" txt "}"
    } Else return objOrVal
}

BatchRequest(ByRef req := "") {
    static urls := ""
	 , TrelloRequestsPerBatch := 10
	 , leftRequests := 10 ; https://developers.trello.com/v1.0/reference#batch-1

    If (req) {
	urls .= (urls ? "," : "") . req
	If (--leftRequests > 0)
	    return
    }
    
    If (urls) {
	If (!TrelloAPI1("GET", "/batch/?urls=" urls, resp))
	    Fail(A_ThisFunc, "[↑] " urls " [↓] " resp)
	Log("GET /batch/?urls=" urls, 2)
	return {urls: urls, response: resp}, urls := "", leftRequests := TrelloRequestsPerBatch
    }
}

BoardsFormatTextReport(ByRef ObjBoards, ByRef BoardsToInclude := "") {
    For i,v in GetBoardFields()
	out .= v "`t"
    For i, objBoard in ObjBoards {
	If (!IsObject(BoardsToInclude) || BoardsToInclude.HasKey(objBoard.id)) {
	    out .= "`n"
	    For j,v in GetBoardFields()
		out .= objBoard[v] "`t"
	}
    }
    
    return [out]
}

GetBoardFields() {
    static BoardFields := ["shortUrl", "closed", "name", "starred", "id", "dateLastActivity", "idOrganization"]
    return BoardFields
}

TransactWrite(ByRef path, ByRef contents) {
    global log
    If (file := FileOpen(path ".tmp", "w")) {
	If (IsObject(contents)) {
	    For k,v in contents
		file.Write(v)
	} Else
	    file.Write(contents)
	file.Close()
	FileMove %path%.tmp, %path%, 1
	If (ErrorLevel)
	    Log("Failed renaming """ path ".tmp"" to """ path """", -1)
	Else
	    Log("Wrote " path, 5)
    } Else {
	Fail("Cannot open file", path ".tmp")
	return 0
    }
    return !ErrorLevel
}

Fail(ByRef status, ByRef details := "") {
    Log("Failure: " status . details, -1)
    ;MsgBox 0x10, %A_ScriptName%, %status%`n`n%details%
    Throw Exception(status,,details)
}


Log(text, status := 0) {
    static    lfo := ""
	    , statusChars := {1: "·", 2: "↓", 3: "←", 4: "🔍", 5: "→", -1: "!", -2: "?"}
	    , listStatusAuto := [{"^GET ": 2}, {"": -2}]
    If (status == "*LogOpen") {
	If (IsObject(lfo))
	    lfo.Close()
	FileGetSize logSize, %text%, M
	If (logSize)
	    FileMove %text%, %text%.bak, 1
	return IsObject(lfo := FileOpen(text, "a-w"))
    } Else If (status == "*LogClose") {
	lfo.Close()
    } Else {
	If (!IsObject(lfo))
	    lfo := FileOpen("*", "w", "CP1")
	If (status)
	    statusChar := (statusChars.HasKey(status) ? statusChars[status] : (StrLen(status) == 1 ? status : ("?", text := "(" status ") " text)))
	Else
	    For i, statusAutoObj in listStatusAuto
		For textSubstr, status in statusAutoObj
		    If (text ~= textSubstr)
			statusChar := statusChars[status]
	return lfo.WriteLine("[" statusChar "] " A_Now A_Tab (text == "" ? ObjectToText("LastError: " A_LastError ", ErrorLevel: " ErrorLevel) : text))
    }
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

#include *i \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\ObjectToText.ahk

;#include *i %A_ScriptDir%\..\..\Backups\profiles$\Share\config\_Scripts\Lib\JSON.ahk
#include *i \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\TrelloAPI1.ahk
