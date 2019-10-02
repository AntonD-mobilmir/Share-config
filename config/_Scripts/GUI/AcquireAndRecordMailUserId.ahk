;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    Try MailUserId := GetMailUserId(GetMailUserIdScript)
    If (!GetMailUserIdScript)
        Throw Exception("GetMailUserIdScript not defined",,"GetMailUserId.ahk did not return path to the script")
    GetMailUserIdFile := FileOpen(GetMailUserIdScript, 0x3) ; lock file file
    If (!IsObject(GetMailUserIdFile)) {
        If (A_IsAdmin)
            Throw Exception("Cannot lock GetMailUserIdScript",,"Error " A_LastError " opening " GetMailUserIdScript)
	Run % "*RunAs " . DllCall( "GetCommandLine", "Str" ),,UseErrorLevel  ; Requires v1.0.92.01+
	ExitApp
    }
    If (!MailUserId) {
	SplitPath GetMailUserIdScript,,GetMailUserIdScriptDir
        
	If (RegexMatch(A_ComputerName, "i).+-([0-9k]|nb)")) {
	    HostnamePrefix := Format("{:Ls}", SubStr(A_ComputerName,1,-2))
	    
	    MailIDToHostnameCSV := GetURL("https://docs.google.com/spreadsheets/d/e/2PACX-1vS3k-JEYNCOtmd4DWhKYrlu8hBNB1rOI5M__kCc9J322K0u_M7RKkaSSripNJWXinjM1Y3oYImT9uUJ/pub?gid=0&single=true&output=csv")
	    Loop Parse, MailIDToHostnameCSV, `n, `r
	    {
                line := []
                Loop Parse, A_LoopField, CSV
                    If (A_Index==2 || A_Index==3)
                        line[A_Index] := A_LoopField
                If (line[3] = HostnamePrefix)
                    MailUserId := line[2], prompt := ""
	    }
	    If (!MailUserId)
                MailUserId := HostnamePrefix, prompt := "email-ID не найден, указано предположительное значение, полученное из Hostname"
	} Else {
            prompt := "Имя компьютера " A_ComputerName " не соответствует шаблону имен компьютеров отделов"
	}
    } Else {
        prompt := "email-ID уже указан в " GetMailUserIdScript
    }
    
    If (prompt) {
        InputBox newMailUserId, email-ID отдела, %prompt%,,,,,,,, %MailUserId%
        If (ErrorLevel)
            ExitApp
        If (!newMailUserId && MailUserId) {
            MsgBox 0x34, %A_ScriptName%, Вы не указали ID`, но ранее был указан %MailUserId%. Удалить "%GetMailUserIdScript%"?
            IfMsgBox No
                ExitApp
        }
        MailUserId := newMailUserId
    }
    GetMailUserIdFile.Close()
    FileDelete %GetMailUserIdScript%
    If (MailUserId) {
        FileCreateDir %GetMailUserIdScriptDir%
        FileAppend (REM coding:CP866`nSET MailUserId=%MailUserId%`n)`n,%GetMailUserIdScript%,CP866
    }
    Exit
}

#include %A_LineFile%\..\..\Lib\GetMailUserId.ahk
#include %A_LineFile%\..\..\Lib\GetURL.ahk
