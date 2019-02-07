;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

pathGroupsTsv = %A_ScriptDir%\depts-to-groups.tsv
ageLimGroupsTsv = 7

;https://docs.google.com/spreadsheets/d/1fKYii5YatmhjdI5QK3U8Tnm6X2tzGG08Eyx_Upb3aEQ/edit#gid=0
If (FileExist(pathGroupsTsv)) {
    FileGetTime timeGroupsTsv, %pathGroupsTsv%
    ageGroupsTsv=
    ageGroupsTsv -= timeGroupsTsv, Days
}

If (!ageGroupsTsv || ageGroupsTsv > ageLimGroupsTsv ) {
    FileReadLine urlGroupsTsv, %A_ScriptFullPath%.groups_url.txt, 1
    UrlDownloadToFile %urlGroupsTsv%, %pathGroupsTsv%
}

groups := {}
Loop Read, %pathGroupsTsv%
{
    grpdata := StrSplit(A_LoopReadLine, A_Tab)
    If (grpdata[1])
        groups[grpdata[1]] := grpdata[3]
}
grpdata := ""

FileCreateDir req
Rclone("move dropbox:Zapier-New-Accounts """ A_ScriptDir "\req"" --include *.txt")

Loop Files, %A_ScriptDir%\req\*.txt
{
    If (!FileExist(A_ScriptDir "\processed\" A_LoopFileName)) {
        Loop Read, %A_LoopFileFullPath%
        {
            varName := ["username", "fullname", "dept", "email", "domain", "alias", "mailgroups", "birthday", "phoneNo"][A_Index]
            If (varName)
                v%varName% := A_LoopReadLine
        }
        If (vusername) {
            If (vdept)
                srvGroup := groups[vdept]
            
            pathpwd = %A_ScriptDir%\pwd.efs\%vusername%.pwd
            pathScript = %A_ScriptDir%\..\ExecQueue\create user %vusername%.cmd
            TransactWrite(pathpwd, GenPassword())
            Run %comspec% /C ""%A_ScriptDir%\encrypt_new_user_password.cmd" "%vusername%" "%pathpwd%" >"d:\var\log\Auto Create New Accounts\encrypt_new_user_password.log" 2>&1"
            
            FileDelete %pathScript%
            FileAppend,
            (LTrim
                @(REM coding:CP866
                FOR /F "usebackq delims=" `%`%A IN ("%pathpwd%") DO @(
                    `%SystemRoot`%\System32\net.exe user "%vusername%" "`%`%A" /Add /FULLNAME:"%vfullname%" /USERCOMMENT:"%dept%" || EXIT /B
                    `%SystemRoot`%\System32\net.exe localgroup "%srvGroup%" "%vusername%" /Add || EXIT /B
                `)
                ECHO N|DEL "%pathpwd%"
                `)
            ), %pathScript%, CP866
            ;REM -- not available on win2k3 -- net user "%vusername%" /LOGONPASSWORDCHG:NO
            FileMove %A_LoopFileFullPath%, %A_ScriptDir%\processed\, 1
            scriptsCreated := 1
            
        }
    }
}

If (scriptsCreated)
    Run schtasks.exe /Run /TN ExecQueue

ExitApp

TransactWrite(path, data, encoding = "CP1") {
    If (IsObject(f := FileOpen(path ".tmp", 2, encoding))) {
        f.Write(data), f.Close()
    }
    FileMove %path%.tmp, %path%, 1
}

RClone(cmds*) {
    For i, cmd in cmds {
        RunWait "%A_ScriptDir%\..\..\Program Files\rclone\rclone.exe" %cmd%, %A_Temp%
        If (ErrorLevel)
            Throw Exception("Rclone error " ErrorLevel,, cmd)
    }
}

GenPassword() {
    AllowedChars := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_*.+="

    passwd=
    Loop 8
    {
        Random charNo, 1, % StrLen(AllowedChars)
        passwd .= SubStr(AllowedChars,charNo,1)
    }
    return passwd
}
