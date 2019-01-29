;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;global debug:=1

passFileName=%1%
If (!passFileName || !FileExist(passFileName)) {
    ExitApp 2
}

backupPath=%2%
If (!backupPath)
    SplitPath passFileName,,backupPath
Loop Files, %backupPath%\Backup *, D
{
    backupPath:=A_LoopFileFullPath
    break
}

SplitPath backupPath, backupName, backupDir
SplitPath backupDir, backupHostname, backupBaseDir

FileEncoding CP866
Loop Read, %passFileName%
{
	;error 9009 changing password, will try to reset
	;Install	1234-5678	25.01.2017 14:25:46,27 @Ctrlrevdept-04 Resetting user password
    If (A_LoopReadLine) {
	;Команда выполнена успешно.
	If(RegexMatch(A_LoopReadLine, "SO)(?P<UserName>[^\t]+)\t(?P<Password>[^\t]+)\t(?P<Datetime>[^@]+)\s@(?P<Hostname>[\S]+)(?:\s(?P<Action>.*))?" , match)) {
	    m := match
	    prevStatus:=multilineStatus
	    multilineStatus=
	} Else {
	    multilineStatus .= "`n" . A_LoopReadLine
	}
    }
}

If (backupHostname != m.Hostname) {
    Hostname := backupHostname " (" m.Hostname ")"
    backupName .= " @ " backupDir
} Else {
    Hostname := m.Hostname
}

statusText := m.Datetime . " " . m.Action . " → " . Trim(multilineStatus, "`r`n")
; . " (prev: " . Trim(prevStatus, "`r`n") . ")"
;MsgBox % Hostname "`n" m.UserName "`n" m.Password "`n" backupName "`n" statusText

formData := { "entry.1427319477"	: Hostname
	    , "entry.1727019064"	: m.UserName
	    , "entry.1602906221"	: m.Password
	    , "entry.854965881"		: backupName
	    , "entry.1625305818"	: statusText
	    , "entry.1342070748" 	: {CutTrelloCardURL: "", TrelloCardName: "", "":"-"} }
FileReadLine URL, %A_LineFile%\..\..\pseudo-secrets\%A_ScriptName%.txt, 1
ExitApp !PostGoogleFormWithPostID(URL, formData)

#include %A_LineFile%\..\..\Lib\PostGoogleFormWithPostID.ahk
