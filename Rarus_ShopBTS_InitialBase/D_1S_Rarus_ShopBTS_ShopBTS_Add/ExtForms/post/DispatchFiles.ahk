#NoEnv
#SingleInstance ignore
#NoTrayIcon
StringCaseSense On
FileEncoding CP1251

Global sendemailexe, tailexe, ReturnError, logfile, localcfg

ShopBTS_Add_install := "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\D_1S_Rarus_ShopBTS\ShopBTS_Add.install.ahk"

FileGetTime timeVerCheck, %A_ScriptDir%\ShopBTS_Add_ver.txt
ageVerCheck=
EnvSub ageVerCheck, timeVerCheck, Days
If (ageVerCheck) { ; если последняя проверка больше дня назад, проверить дату архива на сервере.
    FileGetTime timeArchShopBTSAdd, \\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\D_1S_Rarus_ShopBTS\ShopBTS_Add.7z
    If (timeArchShopBTSAdd) {
	FileRead timeLocShopBTSAdd, %A_ScriptDir%\ShopBTS_Add_ver.txt
	If (timeArchShopBTSAdd != timeLocShopBTSAdd) { ; если дата на сервере != локальной, запустить ShopBTS_Add.install.ahk
	    Run "%A_AhkPath%" "%ShopBTS_Add_install%" /autoupdate
	    ; После обновления скриптов, ShopBTS_Add.install.ahk обновляет дату
	}
    }
}

sendemailexe := FirstExisting("c:\SysUtils\sendEmail.exe", A_ScriptDir . "\..\..\sendEmail.exe")
tailexe := FirstExisting("c:\SysUtils\UnxUtils\tail.exe", A_ScriptDir . "\..\..\tail.exe")
If (!sendemailexe || !tailexe) {
    If (FileExist(ShopBTS_Add_install)) {
	SplashTextOn,300,150, Отправка выгрузок и уведомлений Рарус не работает, Не удалось найти утилиту отправки писем.`n`nБудет запущен скрипт установки утилиты отправки с сервера в офисе`, после чего скрипт отправки выгрузок перезапустится.
	RunWait "%A_AhkPath%" "%ShopBTS_Add_install%" /autoupdate
	Reload
    }
    MsgBox 5, Отправка выгрузок и уведомлений Рарус не работает, Не удалось найти утилиту отправки писем.`nПожалуйста`, сообщите об этом технической поддержке!`n`nЕсли подключть VPN`, при повторной проверке утилита будет автоматически распакована с севера в офисе.
    IfMsgBox Cancel
	Exit
    Reload
}

If Not logfile
    logfile=%A_Temp%\%A_ScriptName%.log
OutgoingFilesQueueDir=%A_ScriptDir%\OutgoingFiles
OutgoingTextsQueueDir=%A_ScriptDir%\OutgoingText

FileGetTime logfileDate,%logfile%
If (logfileDate) {
    logfileAge -= logfileDate, Seconds
    If (logfileAge < 60) {
	TrayTip Отправка файлов отложена, Последний раз отправка выполнялась менее минуты назад`, поэтому данный запуск будет пропущен.
	Sleep 3000
	Exit
    }
}

If %0%
{
    Loop %0%
	DispatchSingleFile(%A_Index%)
} Else {
    Loop %OutgoingFilesQueueDir%\*.7z
	DispatchSingleFile(A_LoopFileFullPath)
    Loop %OutgoingTextsQueueDir%\*.txt
	DeliverOneEmail(A_LoopFileFullPath)
}

Sleep 3000
Exit %ReturnError%

DispatchSingleFile(pathFileToSend) {
    global killedSendEmail, pidSendEmail
    CheckTrayIcon()
    SplitPath pathFileToSend, nameExtToSend, dirFileToSend, , nameOnlyToSend
    pathNote = %dirFileToSend%\%nameOnlyToSend%.txt
    FileRead note, *P65001 %pathNote% ; *P65001 = Unicode (UTF-8)
    
    If (SubStr(note, 1, 2) = "ST") {
	trayMsgText := "Отправка выгрузки " . note
	EmailBody := "Архив с выгрузкой из 1С-Рарус (7.7, МБТСС 2.5)"
    } Else {
	trayMsgText := "Отправка произвольного файла " . note
	EmailBody := "во вложении файл " . note
    }
    subject := EncodeWrapBase64UTF8(note)
    TrayTip %trayMsgText%, %note% [%nameExtToSend%], 15
    Loop Read, %A_ScriptDir%\sendemail.cfg
    {
	If (A_Index==1)
	    emailUserName=%A_LoopReadLine%
	Else If (A_Index==2)
	    emailPassword=%A_LoopReadLine%
	Else
	    Break
    }
    If (!emailUserName || !emailPassword) {
	MsgBox 5, Отправка выгрузок и уведомлений Рарус не работает, Не настроена отправка выгрзок по почте.`nПожалуйста`, сообщите об этом технической поддержке!`n`nЕсли подключть VPN`, выгрузки будут автоматически перемещены на сервер.
	ExitApp
    }
    SetupTemp()
    killedSendEmail := pidSendEmail := 0
    SetTimer killSendEmail, % -60000 * 10
    RunWait %sendemailexe% -f "%emailUserName%" -t "gl@k.mobilmir.ru" -u "%subject%" -s "smtp.k.mobilmir.ru:587" -xu "%emailUserName%" -xp "%emailPassword%" -l "%logfile%" -o "message-charset=cp-1251" -o "timeout=3" -m "%EmailBody%" -a "%pathFileToSend%",,Hide UseErrorLevel, pidSendEmail
    SetTimer killSendEmail, Off
    If (ErrorLevel || killedSendEmail) {
	TrayTip Ошибка при попытке отправки, %trayMsgText% %note% [%nameExtToSend%] неудачна, 30, 3
	If (killedSendEmail) {
	    ReturnError:=-1
	} Else {
	    ReturnError:=ErrorLevel
	}
    } Else {
	FileDelete %pathFileToSend%
	FileDelete %pathNote%
	TrayTip Отправка удалась, %trayMsgText% %note% [%nameExtToSend%] успешна, 5, 1
    }
}

DeliverOneEmail(EmailFileName) {
    ;файлы в текстовом (CP1251) виде следующего формата:
    ;Любая строка до заголовка, начинающаяся с "Reply-To: " – обратный адрес
    ;первая строчка без названия заголовка - кому, можно несколько через запятую; кавычки, если есть, должны быть парными
    ;вторая строчка без названия заголовка - тема
    ;всё, что далее - текст письма

    CheckTrayIcon()
    
    static encodedFrom:="=?UTF-8?B?0J7Qv9C+0LLQtdGJ0LXQvdC40Y8gMdChLdCg0LDRgNGD0YEgKNCw0LLRgtC+0LzQsNGC0LjRh9C10YHQutCw0Y8g0L7RgtC/0YDQsNCy0LrQsCk=?= <rarus-emails@status.mobilmir.ru>"
	 , bcc:="rarus-emails-replies_status-mobilmir-ru@googlegroups.com"
         , smtpServer, smtpLogin, smtpPassword
    If (!smtpServer) {
	Loop Read, %A_ScriptDir%\DispatchFiles-NotificationsAccount.pwd
	{
	    If (A_Index == 1) {
		smtpServer := A_LoopReadLine
	    } Else If (A_Index == 2) {
		smtpLogin := A_LoopReadLine
	    } Else If (A_Index == 3) {
		smtpPassword := A_LoopReadLine
		break
	    }
	}
    }
    If (!smtpServer || !smtpLogin || !smtpPassword)
	Throw Exception("Отправка уведомлений из 1С-Рарус не работает, немедленно свяжитесь со службой ИТ!", "Из файла DispatchFiles-NotificationsAccount.pwd не прочитались сервер или реквизиты учётной записи")
    
    replyToHeader = -o "reply-to=rarus-emails-replies@status.mobilmir.ru"
    
    FileRead emailFileText, %EmailFileName%
    textStart:=1
    Loop Parse, emailFileText, `n
    {
	textStart += StrLen(A_LoopField) + 1
	curLine := Trim(A_LoopField,"`r")
	If (StartsWith(curLine, "Reply-To: ")) {
	    replyToHeader := "-o reply-to=""" . StrReplace(SubStr(curLine, StrLen("Reply-To: ") + 1), """", "''") . """"
	} Else If (!HeaderTo) { ; first non-recognized line
	    StringReplace HeaderTo,curLine,`",'',All
	} Else { ; second non-recognized line
	    Subject := curLine
	    HeaderSubject := EncodeWrapBase64UTF8(Subject)
	    Break
	}
    }
    
    SplitPath EmailFileName,,EmailFileDir,,EmailFileNameNoExt
    If(!EmailFileDir)
	Throw Exception("Отправка уведомлений из 1С-Рарус не работает, немедленно свяжитесь со службой ИТ!", "Не удалось определить путь к файлу письма из полного пути", EmailFileName)
    dirAttachments=%EmailFileDir%\%EmailFileNameNoExt%
    Loop %dirAttachments%\*.*
	Attachments = %Attachments% "%A_LoopFileFullPath%"
    If Attachments
	Attachments=-a %Attachments%
    
    TrayTip Отправка письма, Тема: %Subject%`nКому: %HeaderTo%, 3
    tempDir := SetupTemp()
    mailBodyFileName = %tempDir%\%A_Now%.txt
    FileDelete %mailBodyFileName%
    FileAppend % SubStr(emailFileText, textStart), %mailBodyFileName%, UTF-8
    RunWait %sendemailexe% -o message-file="%mailBodyFileName%" -f "%encodedFrom%" -t "%HeaderTo%" %replyToHeader% -u "%HeaderSubject%" -s "%smtpServer%" -xu "%smtpLogin%" -xp "%smtpPassword%" -o message-charset=utf-8 -o timeout=3 -bcc "%bcc%" -l "%logfile%" %Attachments%",,Hide UseErrorLevel
    FileDelete %mailBodyFileName%
    
    If (ErrorLevel) {
	TrayTip Ошибка при отправке, Тема: %Subject%`nКому: %HeaderTo%`n`nОшибка: %ErrorLevel%, 30, 3
	return ErrorLevel
    }
    
    TrayTip Письмо отправлено, Тема: %Subject%`nКому: %HeaderTo%, 5, 1
    FileDelete %EmailFileName%
    FileRemoveDir %dirAttachments%, 1
}

StartsWith(longstr, shortstr) {
    return SubStr(longstr, 1, StrLen(shortstr)) = shortstr
}

EncodeWrapBase64UTF8(textline) {
    textlineInUTF8Lenght:=StrPut(textline, "UTF-8")
    VarSetCapacity(textlineInUTF8,textlineInUTF8Lenght,0)
    StrPut(textline,&textlineInUTF8,"UTF-8")
    return "=?UTF-8?B?" . Base64Encode(textlineInUTF8,textlineInUTF8Lenght-1) . "?="
}

killSendEmail:
    If (!pidSendEmail) {
        Process Exist, pidSendEmail
        If (ErrorLevel == pidSendEmail) {
	    Process Close, %pidSendEmail%
	    killedSendEmail := 1
        }
    }
return

SetupTemp() {
    tempDir = %A_Temp%\perl
    FileCreateDir %tempDir%
    RunWait "c:\SysUtils\SetACL.exe" -on . -ot file -actn ace -ace "n:S-1-1-0;s:y;p:change;i:so`,sc;m:set;w:dacl",%tempDir%, Hide UseErrorLevel
    EnvSet Temp, %tempDir%
    EnvSet Tmp, %tempDir%
    return tempDir
}

CheckTrayIcon() {
    If (A_IconHidden) {
	Menu Tray, Icon, %A_WinDir%\system32\shell32.dll,69,0
	Menu Tray, Tip, Отправка выгрузок и писем-уведомлений 1С-Рарус
    }
}

FirstExisting(paths*) {
    for index,path in paths
    {
	IfExist %path%
	    return path
    }
    
    return ""
}

Base64Encode(ByRef bin, n=0) {
   m := VarSetCapacity(bin)
   Loop % n<1 || n>m ? m : n
      A := *(&bin+A_Index-1)
     ,m := Mod(A_Index,3)
     ,b := m=1 ? A << 16 : m=2 ? b+(A<<8) : b+A
     ,out .= m ? "" : Code(b>>18) Code(b>>12) Code(b>>6) Code(b)
   Return out (m ? Code(b>>18) Code(b>>12) (m=1 ? "==" : Code(b>>6) "=") : "")
}
Code(i) {   ; <== Chars[i & 63], 0-base index
   Static Chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   Return SubStr(Chars,(i&63)+1,1)
}

Base64Decode(ByRef bin, code) {
   Static Chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   StringReplace code, code, =,, All
   VarSetCapacity(bin, 3*StrLen(code)//4, 0)
   pos = 0
   Loop Parse, code
      m := A_Index&3, d := InStr(Chars,A_LoopField,1) - 1
     ,b := m ? (m=1 ? d<<18 : b+(d<<24-6*m)) : b+d
     ,Append(bin, pos, 3*!m, b>>16, 255 & b>>8, 255 & b)
   Append(bin, pos, !!m+(m&1), b>>16, 255 & b>>8, 0)
}

Append(ByRef bin, ByRef pos, k, c1,c2,c3) {
   Loop %k%
      DllCall("RtlFillMemory",UInt,&bin+pos++, UInt,1, UChar,c%A_Index%)
}
