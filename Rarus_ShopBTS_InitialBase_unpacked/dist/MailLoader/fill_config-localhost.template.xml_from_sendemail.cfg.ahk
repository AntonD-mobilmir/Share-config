;writes config.xml for getmail.exe from plaintext (host`nlogin`npassword) file
;invocation:
;fill_config-localhost.template.xml_from_sendemail.cfg.ahk [configxml [sendemailcfg]]

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv


ExtFormsDir=d:\1S\Rarus\ShopBTS\ExtForms
configxml=%1%
If (!configxml)
    EnvGet configxml, configxml
If (configxml)
    configxml := Trim(configxml, """")
Else
    configxml=%A_ScriptDir%\config-localhost.xml
sendemailcfg=%2%
If (!sendemailcfg)
    sendemailcfg=%ExtFormsDir%\post\sendemail.cfg

If (IsObject(FileOpen(configxml, "r"))) {
    FileGetTime cfgtime, %sendemailcfg%
    FileGetTime xmltime, %configxml%
    If (xmltime >= cfgtime) {
	FileAppend %A_Now% "%configxml%" уже существует и актуален (%xmltime% ≥ %cfgtime% "%sendemailcfg%").`n, *, CP1
	ExitApp 1
    }
} Else {
    FileAppend %A_Now% "%configxml%" не открывается для чтения (ошибка Win %A_LastError% / Ahk %ErrorLevel%).`n, *, CP1
}

Try {
    FileMove %configxml%, %configxml%.%A_Now%, 1
    
    ;https://stackoverflow.com/a/1091953
    ;"   &quot;
    ;'   &apos;
    ;<   &lt;
    ;>   &gt;
    ;&   &amp;

    Loop Read, %sendemailcfg%
    {
	If (A_Index==1)
	    username:=A_LoopReadLine
	Else If (A_Index==2)
	    password:=StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(A_LoopReadLine, "&", "&amp;"),">","&gt;"),"<","&lt;"),"'","&apos;"),"""","&quot;")
	Else
	    break
    }
    
    If (!username)
	username:="{username}"
    If (!password)
	password:="{password}"
    
    FileAppend,
    (LTrim
    <?xml version="1.0" encoding="UTF-8"?>
    <ConfigData>
	    <Server>127.0.0.1</Server>
	    <Port>110</Port>
	    <Username>%username%</Username>
	    <Password>%password%</Password>
	    <DeleteFromServer>true</DeleteFromServer>
	    <OnlyDownloadOnce>false</OnlyDownloadOnce>
      <SaveMessagesDirectory>%ExtFormsDir%\MailLoader\received</SaveMessagesDirectory>
      <SaveAttachments>false</SaveAttachments>
      <SaveAttachmentsDirectory></SaveAttachmentsDirectory>
    </ConfigData>
    
    ), %configxml%, UTF-8-RAW
    exitErrLevel := ErrorLevel << 8
    If (!ErrorLevel && configxml != "d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\config-localhost.xml")
	FileDelete d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\config-localhost.xml
    ExitApp exitErrLevel
} catch e {
    ;MsgBox % "Exception! " e.Message "`nWhat: " e.What "`nExtra:" e.Extra
    FileAppend % A_Now " Exception @ " e.File "(" e.Line "): " e.Message "`n`tWhat: " e.What "`n`tExtra:" e.Extra "`n", **, CP1
    
    ExitApp e.Message << 8
}
