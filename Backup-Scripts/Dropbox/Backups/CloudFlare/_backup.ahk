;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

FormatTime currTime, yyyy-MM-dd HH-mm-ss
SetWorkingDir %A_ScriptDir%

EnvGet LocalAppData,LOCALAPPDATA
FileRead API_Key,*m0xFF %LocalAppData%\_sec\cf.txt

headers := { "X-Auth-Key": API_Key
	    ,"X-Auth-Email": "admin@mobilmir.ru"
	    ,"Content-Type": "application/json"}

FileRead bakjsonZones, _zones.json
If (jsonZones := XMLHTTP("https://api.cloudflare.com/client/v4/zones/", "GET", headers)) {
    bakztimes := Object()
    bakzones := JSON.Load(bakjsonZones)
    For i,zone in bakzones.result
	bakztimes[zone.id] := zone.modified_on

    zones := JSON.Load(jsonZones)
    If (zones.result_info.total_pages > 1) {
	;ToDo: pagination
	Throw "to many zones, pagination not implemented"
    }
    
    For i,zone in zones.result {
	;MsgBox % "i: " i "`nzone: " zone.name "`nzone.modified_on: " zone.modified_on
	If (!ErrorLevel) {
	    If (zone.modified_on == bakztimes[zone.id])
		continue
	    FileMove % zone.name . ".json", % zone.name . "." . bakztimes[zone.id] . ".json"
	}
	
	;global debug := Object()
	per_page := 100
	Loop
	{
	    r:=""
	    page := XMLHTTP("https://api.cloudflare.com/client/v4/zones/" . zone.id . "/dns_records?per_page=" . per_page . "&page=" . A_Index, "GET", headers, "", r)
	    If (!page) {
		ListVars
		WinWaitActive % "ahk_pid " . DllCall("GetCurrentProcessId")
		ControlSetText Edit1, % "`r`nWhat" debug.What "`r`nMessage" debug.Message "`r`nExtra" debug.Extra "`r`nstatus:" r.status "`r`nheaders: " r.headers "`r`n" r.headers "`r`ntext: " r.responseText
		WinWaitClose
		return		
	    }
	    ;?page=3&per_page=20&order=type&direction=asc
	    FileAppend %page%`n, % zone.name . ".json"
	    page := JSON.Load(page)
	    ;MsgBox % "A_Index * per_page: " A_Index * per_page "`npage.result_info.total_count: " page.result_info.total_count
	} Until A_Index * per_page >= page.result_info.total_count
    }

    FileMove _zones.json, _zones.backup.json, 1
    FileAppend %jsonZones%, _zones.json
} Else {
    Throw "Error getting zones list"
}
ExitApp

XMLHTTP(URL, req:="GET", headers:="", reqData:="", ByRef response="") {
    XMLHttpRequest := ComObjCreate("Microsoft.XMLHTTP") ; https://msdn.microsoft.com/en-us/library/ms535874.aspx
    ;XMLHttpRequest.open(bstrMethod, bstrUrl, varAsync, varUser, varPassword);
    XMLHttpRequest.open(req, URL, false)
    If (IsObject(headers)) {
	For n,v in headers
	    XMLHttpRequest.setRequestHeader(n,v)
    }
    Try {
	XMLHttpRequest.send(reqData)
	resp := XMLHttpRequest.responseText
	st := XMLHttpRequest.Status
	If (IsObject(resp))
	    response := {status: st, headers: XMLHttpRequest.getAllResponseHeaders, responseText: resp}
	    ;status can be 200, 404 etc., including proxy responses
	If (st >= 200 && st < 300) {
	    If (resp)
		return resp
	    Else
		return st
	} Else {
	    return false
	}
    } catch e {
	If (IsObject(debug)) {
	    debug.What:=e.What
	    debug.Message:=e.Message
	    debug.Extra:=e.Extra
	}
	Throw e
    } Finally {
	XMLHttpRequest := ""
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

#include <JSON>

; https://api.cloudflare.com/#getting-started-endpoints

; Auth-Email cURL (example)
; curl -X GET "https://api.cloudflare.com/client/v4/zones/cd7d0123e3012345da9420df9514dad0" \
;      -H "Content-Type:application/json" \
;      -H "X-Auth-Key:1234567893feefc5f0q5000bfo0c38d90bbeb" \
;      -H "X-Auth-Email:example@example.com"

; User-Service cURL (example)
; curl -X GET "https://api.cloudflare.com/client/v4/zones/cd7d0123e3012345da9420df9514dad0" \
;      -H "Content-Type:application/json" \
;      -H "X-Auth-User-Service-Key:v1.0-e24fd090c02efcfecb4de8f4ff246fd5c75b48946fdf0ce26c59f91d0d90797b-cfa33fe60e8e34073c149323454383fc9005d25c9b4c502c2f063457ef65322eade065975001a0b4b4c591c5e1bd36a6e8f7e2d4fa8a9ec01c64c041e99530c2-07b9efe0acd78c82c8d9c690aacb8656d81c369246d7f996a205fe3c18e9254a"`

; Pagination cURL (example)
; GET /zones/:zone_identifier/dns_records
; curl -X GET "https://api.cloudflare.com/client/v4/zones/cd7d068de3012345da9420df9514dad0/dns_records?page=3&per_page=20&order=type&direction=asc" \
;      -H "Content-Type:application/json" \
;      -H "X-Auth-Key:1234567893feefc5f0q5000bfo0c38d90bbeb" \
;      -H "X-Auth-Email:example@example.com"

; https://api.cloudflare.com/#dns-records-for-a-zone-list-dns-records
; GET /zones/:zone_identifier/dns_records

;cURL (example)
;curl -X GET "https://api.cloudflare.com/client/v4/zones/023e105f4ecef8ad9ca31a8372d0c353/dns_records?type=A&name=example.com&content=127.0.0.1&page=1&per_page=20&order=type&direction=desc&match=all" \
;     -H "X-Auth-Email: user@example.com" \
;     -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
;     -H "Content-Type: application/json"

