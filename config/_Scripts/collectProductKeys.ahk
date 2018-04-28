;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

if (!A_IsAdmin) {
    Run % "*RunAs " . DllCall( "GetCommandLine", "Str" )
    ExitApp
}

reportdir = %A_Temp%\collectProductKeys.ahk\
FileCreateDir %reportdir%
reportpath = %reportdir%\ProduKey-report.tsv

configIsRead := false
For i, path in [ A_ScriptFullPath ".txt"
               , A_ScriptDir "\pseudo-secrets\collectProductKeys.ahk.txt"
               , "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\pseudo-secrets\collectProductKeys.ahk.txt" ] {
    Try {
        ;FileReadLine URL, %path%, 1
        FileRead configtext, %path%
        configLines := StrSplit(configtext, "`n", "`r")
        
        If (configLines.Length() > 5) {
            configIsRead := true
            break
        }
    }
}
If (!configIsRead)
    Throw Exception("Не удалось прочитать адрес формы")

GetFingerprint(fingerprintText)
fingerprintText := Trim(fingerprintText, " `r`n`t")

staticEntriesValues := [ ""
                       , {"TrelloList": ""} ; Подразделение
                       , {"HostnameDomain": "", "TrelloCardName": "", "CutTrelloCardURL": "", "": " "}
                       , A_UserName ; Пользователь
                       , fingerprintText ]
staticEntries := {}
For i, v in staticEntriesValues
    If (v != "")
        staticEntries[FirstToken(configLines[i])] := v
;		   Name			ID		  Key		     InstallPath	SP		Computer Name	Modified Time
;reportColToFormField := ["entry.1514838880", "entry.638214669", "entry.999816026", "entry.174911211", "entry.174911211", "", 	"entry.174911211"]
reportColToFormField := []
curColumn := 0
cfgLine := staticEntriesValues.Length()
Loop % configLines.Length() - staticEntriesValues.Length()
{
    cfgLine++
    If (!curColumn && Trim(configLines[cfgLine]) == "")
        continue
    reportColToFormField[++curColumn] := FirstToken(configLines[cfgLine])
}

StatusUpdate("Выполняется nirsoft ProduKey.exe")
RunWait "%A_ScriptDir%\ProduKey.exe" /nosavereg /nosort /stab "%reportpath%", %A_ScriptDir%, UseErrorLevel

StatusUpdate("Чтение отчета")
keys := {}
i := 0
fpAdded := 1
Loop Read, %reportpath%
{
    fields := StrSplit(A_LoopReadLine, A_Tab) ; StrSplit() [v1.1.13+]
    key := fields[3]
    If (key == "Product key was not found")
	continue
    
    If (!keys.HasKey(key)) {
	keys[key] := staticEntries.Clone()
        If (fpAdded) { ; для второго ключа и дальше, убрать отпечаток. URL в отдельном поле.
            staticEntries.Delete(FirstToken(configLines[5]))
            fpAdded := 0
        }
    }
    
    For i, v in fields {
	name := reportColToFormField[i]
	If (name && keys[key][name] != v)
	    If (keys[key].HasKey(name))
		keys[key][name] .= " " v
	    Else
		keys[key][name] := v
    }
}

For key, prod in keys {
    For i, v in prod
	If (!IsObject(v))
	    prod[i] := Trim(v, " `t`n`r")
    StatusUpdate("Запись информации о " prod["entry.1514838880"])
    success := (PostGoogleFormWithPostID(configLines[1], prod) || StatusUpdate("Ошибка при отправке " ObjectToText(prod), 3)) && success ; успех только если все отправки выполнены
}

If (success) {
    StatusUpdate("Готово")
    FileDelete %reportpath%
    FileRemoveDir %reportdir%
} Else {
    StatusUpdate("При отправке формы были ошибки", 3)
}
Sleep 1000
ExitApp !success

StatusUpdate(ByRef text, icon := 1) {
    If (text) {
        Menu Tray, Tip, %text%
        TrayTip
        TrayTip Сбор ключей продкутов, %text%,, %icon%
        Sleep (icon-1) * 1000
    } Else {
        Menu Tray, Tip
        TrayTip
    }
}

FirstToken(ByRef line, delims := " `t") {
    Loop Parse, line, %delims%
        return A_LoopField
}

#include %A_ScriptDir%\Lib\ObjectToText.ahk
#include %A_ScriptDir%\Lib\PostGoogleFormWithPostID.ahk
#include %A_ScriptDir%\Lib\GetFingerprint.ahk
#include %A_ScriptDir%\Lib\ObjectToText.ahk
