;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If (!InStr(FileExist("d:\1S\Утилиты Вики-Принт"), "D"))
    ExitApp 0

Unpack(A_Temp "\Утилиты.7z"
      , "https://www.dropbox.com/s/xlfn1cgi9g5ntgt/%D0%A3%D1%82%D0%B8%D0%BB%D0%B8%D1%82%D1%8B.7z?dl=1"
      , "d:\1S\Утилиты Вики-Принт")

ExitApp

StatusUpdate(ByRef status) {
    static MailUserId := GetMailUserId()
    PostGoogleForm("https://docs.google.com/forms/d/e/1FAIpQLSfQgqOnBbEXLEA6SXZtCOn4SLBlacx9uaJJx8gg4OXVIbpezw/formResponse"
                  , { "entry.893808397": MailUserId
                    , "entry.497437733": status })
}

Unpack(ByRef arcfname, ByRef URL, ByRef destDir) {
    static exe7z := find7zGUIorAny()
    
    While (!FileExist(arcfname)) {
        If (FileExist(absarcfname := A_ScriptDir "\" arcfname))
            arcfname := absarcfname
        Else
            Download(arcfname, URL)
    }
    RunWait %exe7z% x -aoa -y -o"%destDir%" -- "%arcfname%",, Hide, cmdPID
    If (ErrorLevel)
        StatusUpdate("[!] Error " ErrorLevel " unpacking " arcfname " → " destDir)
}

Download(ByRef arcfname, ByRef URL) {
    Random rnd, 0, 9999
    tmpDir := A_Temp "\" A_ScriptName A_Now rnd
    FileCreateDir %tmpDir%
    
    StatusUpdate("[.] wget " URL " → " arcfname)
    RunWait C:\SysUtils\wget.exe -N %URL%, %tmpDir%, Hide UseErrorLevel, cmdPID
    If (ErrorLevel) {
        StatusUpdate("[!] Error " ErrorLevel " wget " URL " → " arcfname ", trying UrlDownloadToFile")
        UrlDownloadToFile %URL%, %arcfname%.tmp
        If (ErrorLevel) {
            StatusUpdate("[!] Error " ErrorLevel " UrlDownloadToFile " URL " → " arcfname)
        } Else {
            StatusUpdate("[OK] UrlDownloadToFile " URL " → " arcfname)
            FileMove %arcfname%.tmp, %arcfname%, 1
        }
    } Else {
        Loop Files, %tmpDir%\*.*
            If (A_Index > 1)
                Throw Exception("Во временной папке загрузок больше одного файла",, tmpDir)
            Else
                FileMove %A_LoopFileFullPath%, %arcfname%
    }
    FileRemoveDir %tmpDir%, 1
}

PostGoogleForm(URL, ByRef kv, tries:=20, retryDelay:=20000) {
    If (!IsObject(kv))
	Throw Exception("Keys and Values should be passed as an object", A_ThisFunc, kv)
    
    ;url looks like: "https://docs.google.com/a/mobilmir.ru/forms/d/e/***/formResponse"
    ;expected post data format: "entry.615879702=test&entry.67493091=dept&entry.1721746842=ver&fvv=1&draftResponse=%5B%2C%2C%227974343457504139194%22%5D%0D%0A&pageHistory=0&fbzx=7974343457504139194",
    
    For k,v in kv
	POSTDATA .= k . "=" . UriEncode(v) . "&"
    POSTDATA := SubStr(POSTDATA,1,-1)
    
    While !(lastResult := XMLHTTP_Post(URL, POSTDATA)) && tries--
	Sleep retryDelay
    return lastResult
}

XMLHTTP_Post(ByRef URL, ByRef POSTDATA, ByRef response:=0, ByRef reqmoreHeaders:=0) {
    If (IsObject(reqmoreHeaders)) {
	If (reqmoreHeaders.HasKey("Content-Type")) {
	    moreHeaders := reqmoreHeaders
	} Else {
	    moreHeaders := reqmoreHeaders.Clone()
	    moreHeaders["Content-Type"] := "application/x-www-form-urlencoded"
	}
    } Else {
	moreHeaders := {"Content-Type": "application/x-www-form-urlencoded"}
    }
    return XMLHTTP_Request("POST", URL, POSTDATA, response, moreHeaders)
}

XMLHTTP_Request(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0) {
    global debug
    static useObjName:=""
    ;Error at line 13 in #include file "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\XMLHTTP_Post.ahk".

    ;Line Text: local xhr := ComObjCreate(useObjName)
    ;Error: Local variables must not be declared in this function.

    ;The program will exit.
    ;local i, objName, hName, hVal, k, v
    
    If (IsObject(debug)) {
	If (moreHeaders)
	    For i, v in moreHeaders
		txtHeaders .= "`t" i ": " v "`n"
	FileAppend % method " " URL . (POSTDATA ? " ← " POSTDATA : "") ( moreHeaders ? "`n`tHeaders:`n" txtHeaders : "") "`n", **
    }
    If (useObjName) {
	xhr := ComObjCreate(useObjName)
    } Else {
	errLog=
	objNames := [ "Msxml2.XMLHTTP.6.0", "Msxml2.XMLHTTP.3.0", "Msxml2.XMLHTTP", "Microsoft.XMLHTTP" ]
	For i, objName in objNames {
	    ;xhr=XMLHttpRequest
	    If (IsObject(debug))
		FileAppend `tTrying to create object %objName%…
		
	    xhr := ComObjCreate(objName) ; https://msdn.microsoft.com/en-us/library/ms535874.aspx
	    If (IsObject(xhr)) {
		useObjName := objName
		If (IsObject(debug))
		    FileAppend Done!`n, **
		break
	    } Else {
		errLog .= objName ": " A_LastError "`n"
	    }
	    If (IsObject(debug))
		FileAppend nope`n, **
	}
	If (!useObjName)
	    Throw Exception("Не удалось создать объект XMLHTTP", A_ThisFunc, SubStr(errLog, 1, -1))
    }
    ;xhr.open(bstrMethod, bstrUrl, varAsync, varUser, varPassword);
    xhr.open(method, URL, false)
    ;xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    
    If (IsObject(moreHeaders))
	For hName, hVal in moreHeaders
	    xhr.setRequestHeader(hName, hVal)
    
    Try {
	xhr.send(POSTDATA)
	If (IsObject(response))
	    response := {status: xhr.status, headers: xhr.getAllResponseHeaders, responseText: xhr.responseText}
	Else If (IsByRef(response))
	    response := xhr.responseText
	If (IsObject(debug)) {
	    debug.Headers := xhr.getAllResponseHeaders
	    debug.Response := xhr.responseText
	    debug.Status := xhr.status	;can be 200, 404 etc., including proxy responses
	}
	return xhr.Status >= 200 && xhr.Status < 300
    } catch e {
	If (IsObject(debug)) {
	    debug.What:=e.What
	    debug.Message:=e.Message
	    debug.Extra:=e.Extra
	}
	return
    } Finally {
	xhr := ""
	If (IsObject(debug)) {
	    ;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
	    ;static document
	    ;Gui Add, ActiveX, w750 h550 vdocument, % "MSHTML:" . debug.Response
	    ;Gui Show
	    For k,v in debug
		FileAppend %k%: %v%`n, **
	}
    }
}

CutTrelloCardURLFromTrelloIdObject() {
    return CutTrelloCardURL(Cache_TrelloIdFromTxt().url)
}

CutTrelloCardURL(ByRef url, mode := 0) {
    If (mode && RegexMatch(url, "^.*?/c/([^/]+)/\d+", shn))
	return shn1
    Else
	If (RegexMatch(url, "^.*?/c/[^/]+/\d+", shn))
	    return shn
}

Cache_TrelloIdFromTxt() {
    static trelloIdObj := ""
    If (!IsObject(trelloIdObj))
	trelloIdObj := ReadTrelloIdFromTxt()
    return trelloIdObj
}

ReadTrelloIdFromTxt(ByRef verifyHostname := "") {
    pathTrelloID := A_AppDataCommon "\mobilmir.ru\trello-id.txt"
    , trelloidlines := ["url", "Hostname", "name", "id", "List"]
    
    TrelloIdTxt := {}
    Loop Read, %A_AppDataCommon%\mobilmir.ru\trello-id.txt
	If (A_LoopReadLine && varName := trelloidlines[A_Index])
	    TrelloIdTxt[varName] := A_LoopReadLine
    Until A_Index > trelloidlines.Length()
    
    If (verifyHostname && outObject.trelloHostname && outObject.trelloHostname != verifyHostname)
	verifyHostname .= " (trello-id.txt: " outObject.trelloHostname ")"

    return TrelloIdTxt
}

ObjectToText(ByRef obj) {
    return IsObject(obj) ? ObjectToText_nocheck(obj) : obj
}

ObjectToText_nocheck(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText_nocheck(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}

;#include <getDefaultConfig>
#include <find7zexe>
#include <URIEncodeDecode>
#include <GetMailUserId>
