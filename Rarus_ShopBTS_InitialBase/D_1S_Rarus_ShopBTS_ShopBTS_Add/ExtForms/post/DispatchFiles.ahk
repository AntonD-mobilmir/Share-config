;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore
#NoTrayIcon
StringCaseSense On
FileEncoding CP1251

Global sendemailexe, tailexe, ReturnError, logfile, localcfg, arcDir

ShopBTS_Add_install := "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\D_1S_Rarus_ShopBTS\ShopBTS_Add.install.ahk"
verFName=%A_ScriptDir%\ShopBTS_Add_ver.txt

FileGetTime timeVerCheck, %verFName%
ageVerCheck=
EnvSub ageVerCheck, timeVerCheck, Days
If (ageVerCheck) { ; если последняя проверка больше дня назад, проверить дату архива на сервере.
    FileGetTime timeArchShopBTSAdd, \\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\D_1S_Rarus_ShopBTS\ShopBTS_Add.7z
    If (timeArchShopBTSAdd) {
	FileRead timeLocShopBTSAdd, %A_ScriptDir%\ShopBTS_Add_ver.txt
	If (timeArchShopBTSAdd != timeLocShopBTSAdd) { ; если дата на сервере != локальной, запустить ShopBTS_Add.install.ahk
	    Run "%A_AhkPath%" "%ShopBTS_Add_install%" /autoupdate
	    ; После обновления скриптов, ShopBTS_Add.install.ahk обновляет дату
	} Else {
	    ; Обновление даты проверки
	    FileAppend,, %verFName%
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

logfile=%A_ScriptFullPath%.log
OutgoingFilesQueueDir=%A_ScriptDir%\OutgoingFiles
OutgoingTextsQueueDir=%A_ScriptDir%\OutgoingText
arcDir=%A_ScriptDir%\Arc

FileGetTime logfileDate,%logfile%
If (logfileDate) {
    logfileAge -= logfileDate, Seconds
    If (logfileAge < 60) {
	CheckTrayIcon(" Последний раз отправка выполнялась менее минуты назад`, поэтому данный запуск будет пропущен.", "Отправка файлов отложена")
	Sleep 1500
	ExitApp
    }
}

FileGetSize logfileSize, %logfile%, M
If (logfileSize > 5) ; megabytes
    FileMove %logfile%, %logfile%.bak, 1

If (!InStr(FileExist(A_ScriptDir "\Arc"), "D")) {
    FileMove %arcDir%, %arcDir%.bak, 1
} Else {
    FileGetTime timeArcCreation, %arcDir%, C
    ageArcCreation -= %timeArcCreation%, Days
    If (ageArcCreation > 365) {
	Loop Files, %arcDir%-bak.*, D
	    FileRemoveDir %A_LoopFileFullPath%, 1
	FileMoveDir %arcDir%, %arcDir%-bak.%A_Now%, R
    }
}
FileCreateDir %arcDir%

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
    encSubj := EncodeWrapBase64UTF8(note)
    CheckTrayIcon(trayMsgText " (""" nameExtToSend """)", "Отправка выгрузки", 15, 0x31)
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
    RunWait %sendemailexe% -f "%emailUserName%" -t "gl@k.mobilmir.ru" -u "%encSubj%" -s "smtp.k.mobilmir.ru:587" -xu "%emailUserName%" -xp "%emailPassword%" -l "%logfile%" -o "message-charset=cp-1251" -o "timeout=3" -m "%EmailBody%" -a "%pathFileToSend%",%A_Temp%,Hide UseErrorLevel, pidSendEmail
    SetTimer killSendEmail, Off
    If (ErrorLevel || killedSendEmail) {
	CheckTrayIcon(trayMsgText "`n" note " (""" nameExtToSend """) неудачна", "Ошибка при попытке отправки выгрузки", 30, 0x23)
	If (killedSendEmail) {
	    ReturnError:=-1
	} Else {
	    ReturnError:=ErrorLevel
	}
	FileRemoveDir %A_Temp%\perl, 1
	Loop Files, %A_Temp%\pdk*, D
	    FileRemoveDir %A_LoopFileFullPath%, 1
    } Else {
	CheckTrayIcon(trayMsgText "`n" note " (""" nameExtToSend """) успешна", "Выгрузка отправлена", 5, 0x31)
	;FileDelete %pathFileToSend%
	;FileDelete %pathNote%
	FileMove %pathFileToSend%, %arcDir%, 1
	FileMove %pathNote%, %arcDir%, 1
    }
}

DeliverOneEmail(EmailFileName) {
    ;файлы в текстовом (CP1251) виде следующего формата:
    ;Любая строка до заголовка, начинающаяся с "Reply-To: " – обратный адрес
    ;первая строчка без названия заголовка - кому, можно несколько через запятую; кавычки, если есть, должны быть парными
    ;вторая строчка без названия заголовка - тема
    ;всё, что далее - текст письма
    
    ; {"line from text file" : {(parse as recipied address ? true : false): "command line option"}}
    LinePrefixesToOptions := {"Reply-To:": {1: "-o reply-to="}}

    static smtpServer, smtpLogin, smtpPassword, encodedFrom
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
	encodedFrom := "=?UTF-8?B?0J7Qv9C+0LLQtdGJ0LXQvdC40Y8gMdChLdCg0LDRgNGD0YEgKNCw0LLRgtC+0LzQsNGC0LjRh9C10YHQutCw0Y8g0L7RgtC/0YDQsNCy0LrQsCk=?= <" . smtpLogin . ">"
    }
    If (!(smtpServer && smtpLogin && smtpPassword))
	Throw Exception("Отправка уведомлений из 1С-Рарус не работает, немедленно свяжитесь со службой ИТ!", "Из файла DispatchFiles-NotificationsAccount.pwd не прочитались сервер или реквизиты учётной записи")
    
    replyToHeader = -o "replies@rarus.robots.mobilmir.ru"
    bccHeader=-bcc "rarus-emails-bcc2_status-mobilmir-ru@googlegroups.com"
	
    tempDir := SetupTemp()
    If (!IsObject(fBody := FileOpen(bodyFName := A_Temp "\" A_Now ".txt", "w`n", "UTF-8")))
	Throw Exception("Не удалось открыть временный файл для записи тела сообщения",,bodyFName)
    headers := 1
    Loop Read, %EmailFileName% ; стандартная кодировка – CP1251
    {
	If (headers) {
	    curLine := Trim(A_LoopReadLine)
	    If (curLine) {
		lineRecognized := 0
		For prefix, options in LinePrefixesToOptions {
		    If (StartsWith(curLine, prefix)) {
			lineRecognized := 1
			optnVal := Trim(SubStr(curLine, StrLen(prefix) + 1))
			For htype, cmdlOptn in options {
			    If (htype=1)
				optnVal := FilterRecipients(optnVal)
			    parsedHeaders .= cmdlOptn . """" . StrReplace(optnVal, """", "''") . """ "
			}
		    }
		}
	    }
	    If (!lineRecognized) {
		If (!addrlistTo) { ; первая строка без префикса
		    StringReplace curLine,curLine,`",'',All
		    addrlistTo := FilterRecipients(curLine, removedAddresses)[1]
		    If (removedAddresses)
			fBody.WriteLine("Удалены получатели: " removedAddresses)
		} Else { ; вторая строка без префикса
		    encSubj := EncodeWrapBase64UTF8(plainSubj := curLine)
		    headers := 0 ; остановиться сразу после заголовков
		}
	    }
	} Else
	    fBody.WriteLine(A_LoopReadLine)
    }
    
    SplitPath EmailFileName,,EmailFileDir,,EmailFileNameNoExt
    If(!EmailFileDir)
	Throw Exception("Отправка уведомлений из 1С-Рарус не работает, немедленно свяжитесь со службой ИТ!",, "В пути к файлу письма не указана папка: «" EmailFileName "»")
    dirAttachments=%EmailFileDir%\%EmailFileNameNoExt%
    Loop Files, %dirAttachments%\*.*
	Attachments = %Attachments% "%A_LoopFileFullPath%"
    If (Attachments)
    {
	fBody.WriteLine("`nВложения: " Attachments)
	Attachments=-a %Attachments%
    }
    fBody.Close()
    
    CheckTrayIcon("Тема: " plainSubj "`nКому: " addrlistTo, "Отправка письма")
    tempDir := SetupTemp()
    RunWait %sendemailexe% -o message-file="%bodyFName%" -f "%encodedFrom%" -t "%addrlistTo%" %replyToHeader% -u "%encSubj%" -s "%smtpServer%" -xu "%smtpLogin%" -xp "%smtpPassword%" -o message-charset=utf-8 -o timeout=3 %bccHeader% -l "%logfile%" %Attachments%,,Hide UseErrorLevel
    If (sendemailErr := ErrorLevel)
	sendemailLastErr := A_LastError
    FileDelete %bodyFName%
    
    If (sendemailErr) {
	CheckTrayIcon("Тема: " plainSubj "`nКому: " addrlistTo "`nОшибка: " sendemailErr " / " sendemailLastErr, "Ошибка при отправке", 30, 0x23)
	return sendemailErr
    }
    
    CheckTrayIcon("Тема: " plainSubj "`nКому: " addrlistTo, "Письмо отправлено", 5, 0x31)
    ;FileDelete %EmailFileName%
    ;FileRemoveDir %dirAttachments%, 1
    FileMove %EmailFileName%, %arcDir%, 1
    Loop Files, %dirAttachments%, D
	FileMoveDir %A_LoopFileLongPath%, %arcDir%\%A_LoopFileName%, 1
}

FilterRecipients(ByRef rcptList, ByRef filteredOut := "", ByRef allowedRegex := 0) {
    dfltRegex := "@(rarus.robots.mobilmir.ru|googlegroups.com)$"
    fallbackAddr := "fallback-rcpt@rarus.robots.mobilmir.ru"
    If (allowedRegex==0)
	allowedRegex := dfltRegex
    Loop Parse, rcptList, `,, %A_Space%%A_Tab%
	If (A_LoopField) {
	    ;RegexMatch(A_LoopField, "<([^>]+@[^>]+\.[^>]+)>[^<>]*$", mTo))
	    If (A_LoopField ~= allowedRegex) { ; A_LoopField → addrTo
		addrlistTo .= A_LoopField ","
	    } Else {
		filteredOut .= A_LoopField ","
		If (fallbackAddr) {
		    addrlistTo .= fallbackAddr ","
		    fallbackAddr := ""
		}
	    }
	}
    
    return [RTrim(addrlistTo, ","), filteredOut := RTrim(filteredOut, ",")]
}

StartsWith(longstr, shortstr) {
    return SubStr(longstr, 1, StrLen(shortstr)) = shortstr
}

EndsWith(longstr,shortstr) {
    return shortstr=SubStr(longstr, 1-StrLen(shortstr))
}

EncodeWrapBase64UTF8(textline) {
    textlineInUTF8Lenght:=StrPut(textline, "UTF-8")
    VarSetCapacity(textlineInUTF8,textlineInUTF8Lenght,0)
    StrPut(textline,&textlineInUTF8,"UTF-8")
    return "=?UTF-8?B?" . Base64Encode(textlineInUTF8,textlineInUTF8Lenght-1) . "?="
}

killSendEmail:
    If (pidSendEmail) {
        Process Exist, pidSendEmail
        If (ErrorLevel == pidSendEmail) {
	    Process Close, %pidSendEmail%
	    killedSendEmail := 1
        }
    }
return

SetupTemp() {
    static tempDir
    If (!tempDir) {
	tempDir = %A_Temp%\perl
	FileCreateDir %tempDir%
	RunWait "c:\SysUtils\SetACL.exe" -on . -ot file -actn ace -ace "n:S-1-1-0;s:y;p:change;i:so`,sc;m:set;w:dacl",%tempDir%, Hide UseErrorLevel
	EnvSet Temp, %tempDir%
	EnvSet Tmp, %tempDir%
    }
    return tempDir
}

CheckTrayIcon(text, ByRef title:="", timeout:=0, options := 0x10) {
    If (A_IconHidden)
	SetTrayIcon()
    TrayTip %text%, %title%, %timeout%, %options%
    Menu Tray, Tip, %text%
    If (timeout)
	SetTimer ResetTrayTip, % timeout*1000
}

ResetTrayTip() {
    TrayTip
    Menu Tray, NoIcon
    ;If (A_IconHidden)
    SetTrayIcon()
    Menu Tray, Tip, Отправка выгрузок и уведомлений из 1С-Рарус
}

SetTrayIcon() {
    Menu Tray, Icon, %A_WinDir%\system32\shell32.dll,69,0
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
