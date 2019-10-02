; Запуск UserBenchmark и сбор результатов в форму
; Результаты в https://docs.google.com/a/mobilmir.ru/spreadsheets/d/1lIaYa5gDp9asnHjAcoExh0z6HVaYlepJJ8vBwbOJdyM

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#InstallKeybdHook
#InstallMouseHook
;#SingleInstance ignore - breaks /WaitAndPostResults
#SingleInstance force
If A_OSVersion in WIN_2003,WIN_XP,WIN_2000
    ExitApp 1
EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server

Arg1 = %1%
If (Arg1="/PostURLFromBrowser" || Arg1="-PostURLFromBrowser" || Arg1="-PostURLFromBrowser.lnk") {
    sendModes := {0: "Play", 1: "Input", 2: "Event"}
    
    SetTitleMatchMode 2 ; A window's title can contain WinTitle anywhere inside it to be a match
    actnList := "_;^f;_;Copy results{Esc};_;{Enter};_4;-+;-1;{Esc}^l;_2;-0;--"
    wantUserIdle := 10000 ; ms

    KL_NAMELENGTH = 9
    LANG_ENG := "00000409"
    ;LANG_RUS := "00000419"
    VarSetCapacity(layoutName, (KL_NAMELENGTH+1) * (A_IsUnicode+1)) ; +1 for '\0'
    
    i := 0
    OnClipboardChange("ClipHook")
    Loop
    {
	;MsgBox ResultsURL: %ResultsURL%`nA_Index: %i%
	If (ResultsURL && (IsObject(perfResultsObj) || i > 100) )
	    ExitApp !PostResults(ResultsURL, perfResultsObj)
	
	WinWait Performance Results - UserBenchmark,,3
	If (ErrorLevel) ; ToDo: отлавливать сообщения об ошибках и попытаться найти окно выбора браузера
	    continue
	
	; Else [If (!ErrorLevel)]
	sendModeName := SendModes[Mod(i++, 3)]
	Menu Tray, Tip, %A_ScriptName%: Cycle %i%`, SendMode %sendModeName%
	SendMode %sendModeName%
	Loop Parse, actnList, `;
	{
	    Sleep 250
	    If (A_TimeIdlePhysical < wantUserIdle) {
		TrayTip,, Скопируйте результаты теста и ссылку на результаты в буфер обмена (в любом порядке)
		While (A_TimeIdlePhysical < wantUserIdle && !(ResultsURL && IsObject(perfResultsObj))) {
		    If (A_Index==1) {
			Progress Off
			Progress R0-%wantUserIdle% M, `n, Ожидание бездействия пользователя
		    }
		    Progress %A_TimeIdlePhysical%
		    Sleep 100
		}
		Progress Off
		break
	    }
	    WinActivate
	    actn := SubStr(A_LoopField,1,1)
	    If (actn=="_") { 		; wait
		Sleep (1000 + (SubStr(A_LoopField,2) * 1000))
	    } Else If (actn=="-") { 	; clipboard
		subActn := SubStr(A_LoopField,2)
		Try {
		    If (subActn=="+") {
			clipBak := ClipboardAll
		    } Else If (subActn=="-") {
			Clipboard := clipBak
		    } Else {
			WinActivate
			Send ^{Ins}
			Sleep 25
			WinActivate
			Send ^{vk43} ;^c, {vk43}=c
			ClipWait 10
		    }
		}
	    } Else { ; just send
		;GetKeyboardLayoutName https://msdn.microsoft.com/en-us/library/windows/desktop/ms646298.aspx
		If (DllCall(SystemRoot . "\System32\User32.dll\GetKeyboardLayoutName", "Str", layoutName)
			&& layoutName != LANG_ENG) { ; if language is not english,
		    Loop
		    {
			If (A_Index > 1)
			    Send {Tab}
			ControlGetFocus,ctl
		    } Until !ErrorLevel || A_Index > 10
		    SendMessage 0x50,0,HKL,%ctl%,A ;WM_INPUTLANGCHANGEREQUEST - change locale
		}
		Send %A_LoopField%
	    }
	}
	
	Sleep 1000
    }
    Progress Off
    Sleep 1000
    ExitApp
}

ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
If (!A_IsAdmin) {
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    ExitApp
}

If (!FileExist(A_AppDataCommon "\mobilmir.ru\trello-id.txt"))
    Run "%A_AhkPath%" %AutoHotkeyExe% "%A_LineFile%\..\..\Write-trello-id.ahk"

UBMzipURL := "http://www.userbenchmark.com/resources/download/UserBenchMark.zip"
TempDir := A_Temp . "\UserBenchMark-DL"
archiveName := TempDir . "\UserBenchMark.zip"
exeName := TempDir . "\UserBenchMark.exe"

ResetProgress()
While (!FileExist(exeName)) {
    FileDelete %archiveName%

    FileCreateDir %TempDir%
    global dlDir:=GetKnownFolder("Downloads")
    If Not dlDir
	dlDir = %A_MyDocuments%\Downloads

    delay := 45
    While !FileExist(archiveName) {
	IfExist %dlDir%\UserBenchMark.zip
	{
	    FileMove %dlDir%\UserBenchMark.zip, %archiveName%
	    break
	}

	Notify("Скачивается " . UBMzipURL)
	UrlDownloadToFile %UBMzipURL%, %archiveName%
	If (FileExist(archiveName))
	    break

	If (A_Index>1) {
	    MsgBox 22, %A_ScriptName%, %UBMzipURL% не скачался., 300
	    IfMsgBox Continue
		break
	    IfMsgBox Cancel
		ExitApp
	}
	
	; If a new browser is installed, Win8+ will show app selection window instead of launching default one
	; because of that, launching specific browser is much more safe
	If (A_OSVersion != "WIN_7" && browserexe := FindBrowserExe())
	    runUBMDL := browserexe . A_Space . UBMzipURL
	Else
	    runUBMDL := UBMzipURL
	Run %runUBMDL%
	If (browserexe) {
	    MsgBox Нажмите OK`, затем Выберите браузер по умолчанию (поставьте галочку)`, иначе UserBenchmark не сможет открыть страницу результатов.
	    Run http://
	}
	
	MsgBox 0x2040, %A_ScriptName%, Для загрузки %UBMzipURL% запущен браузер. Пауза %delay% секунд., %delay%
	delay := delay * 2
    }

    Loop Files, %archiveName%
    {
	Notify("Распаковка UserBenchMark.zip…")
	oShell := ComObjCreate("Shell.Application")
	oDir := oShell.NameSpace(TempDir)
	oZip := oShell.NameSpace(A_LoopFileFullPath)
	If (oZip && oDir) {
	    oDir.CopyHere(oZip.Items, 4)
	} Else {
	    MsgBox 16, %A_ScriptName%, unzip error., 15
	}
	oShell := oDir := oZip := ""
    }
}
If (!FileExist(exeName)) {
    RunWait %SystemRoot%\explorer.exe /select`,"%archiveName%"
    MsgBox 16, %A_ScriptName%, Не удалось распаковать UserBenchmark.exe из %archiveName%.`nРаспакуйте вручную`, файл должен называться %exeName%., 60
}

Notify("Ожидание простоя…")
WaitCPUIdle()
ResetProgress()
FileAppend %A_Now% Текущее время бездействия пользователя: %A_TimeIdlePhysical%, *

Notify("Запуск " . exeName)

Run "%exeName%" /S, %TempDir%, UseErrorLevel, pidUBM
If (ErrorLevel=="ERROR") {
    MsgBox 16, %A_ScriptName%, Запуск не удался., 15
    ExitApp
}

; ToDo: (someday) register own handler for http so UBM launches script and we don't have to Ctrl+C the URL from browser UI
; https://stackoverflow.com/questions/13559915/registering-a-protocol-handler-in-windows-8

FillGroups()

Loop
{
    Sleep 300
    ; If unspecified, TitleMatchMode defaults to 1 and fast.
    For title, actnOrBtn in { "ahk_group ErrorMessagesEN": "OK"
                            , "ahk_group ErrorMessagesRU": "ОК"
                            , "https://www.userbenchmark.com/UserRun/": ["SaveTitleAsURL", "click OK"] } {
        If (WinExist(title)) {
            If (IsObject(actnOrBtn)) {
                For i, actn in actnOrBtn {
                    If (actn=="SaveTitleAsURL") {
                        WinGetTitle ResultsURL
                        FileAppend [InternetShortcut]`nURL=%ResultsURL%`n, %A_Desktop%\UserBenchmark could open browser %A_Now%.URL, UTF-16
                        Run %browserexe% %ResultsURL%
                    } Else If (actn=="click OK") {
                        ControlClick Button1 ; a guess, not verified
                        ControlClick ОК ; Ru
                        ControlClick OK ; En
                    }
                }
            } Else {
                ControlClick %actnOrBtn%
            }
        }
    }
    Process Exist, %pidUBM%
} Until (ErrorLevel!=pidUBM)

; Cleanup after drive speed tests
DriveGet drivers, List
Loop Parse, drivers
{
    IfExist %A_LoopField%:\UserBenchmark
    {
	FileDelete %A_LoopField%:\UserBenchmark\UserBenchmark.dat
	FileRemoveDir %A_LoopField%:\UserBenchmark
    }
}

FileAppend %A_Now% Запуск ожидания прявления результатов в отдельном процессе…`n,*,CP866
Run %ScriptRunCommand% /PostURLFromBrowser, %A_ScriptDir%

ExitApp

FindBrowserExe() {
    regRoots := ["HKEY_LOCAL_MACHINE", "HKEY_CLASSES_ROOT"]
    ;regPaths: [[regkey, regvalname, remove %1?], …]
    regPaths := [["ChromeHTML\shell\open\command",, 1]
		,["SOFTWARE\Classes\Applications\chrome.exe\shell\open\command",, 1]
		,["SOFTWARE\Clients\StartMenuInternet\Google Chrome\shell\open\command"]
		,["SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe"]
		,["Software\Classes\ActivatableClasses\Package\DefaultBrowser_NOPUBLISHERID\Server\DefaultBrowserServer", "ExePath"]
		,["HKEY_CLASSES_ROOT\Applications\iexplore.exe\shell\open\command",, 1]
		,["HKEY_CLASSES_ROOT\IE.HTTP\shell\open\command",, 1]]
    If (A_Is64bitOS)
	SetRegView 64
    Loop % (1 + A_Is64bitOS)
    {
	If (A_Index > 1)
	    SetRegView 32
	For rri, regRoot in regRoots {
	    For rpi, regPathObj in regPaths {
		RegRead v, % regRoot "\" regPathObj[1], % regPathObj[2]
		If (!ErrorLevel && v)
		    If (regPathObj[3]==1)
			return RemovePercent1(v)
		    Else
			return v
	    }
	}
	return
    }
}

RemovePercent1(str) {
    return StrReplace(StrReplace(str, """%1""", ""), "%1", "")
}

ClipHook(cliptype) {
    global perfResultsObj, ResultsURL
    static requiredURLprefix := "^https?:\/\/www\.userbenchmark\.com\/UserRun\/"
    
    If (cliptype == 1) {
	Try {
	    clipContents := Clipboard
	} Catch e {
	    TrayTip Error reading clipboard, % Error e.Message . "`n" . e.Extra
	    return
	}
    
    	If ( clipContents ~= requiredURLprefix ) {
	    TrayTip Найден URL, %ResultsURL%
	    ResultsURL := clipContents
	} Else If ( IsObject(perfResultsObjNew := ParsePerfResults(clipContents)) ) {
	    perfResultsObj := perfResultsObjNew
	    perfResultsObjNew := ""
	    TrayTip Найден текст с результатами теста, % perfResultsObj.ResultsText
	    ;MsgBox % perfResultsObj.Desktop . "`n" . 	    perfResultsObj.CPU . "`n" . 	    perfResultsObj.CPUModel . "`n" . 	    perfResultsObj.HDD . "`n" . 	    perfResultsObj.HDDModel . "`n" . 	    perfResultsObj.SSD . "`n" . 	    perfResultsObj.SSDModel
	} Else {
	    TrayTip Скопированный текст не подходит, Текст не похож ни на URL`, ни на результаты.`nОжидается либо URL подходящий к маске %requiredURLprefix%`, либо текст результатов.
	    return
	}
    } Else {
	TrayTip Скопирован не текст, Ожидается либо текст результатов`, либо ссылка на них
	return
    }
}

ParsePerfResults(txt) {
    If (!txt)
	return
    results := Object()
    results.ResultsText := Trim(txt)
    
    ;UserBenchmarks: Desk 20%, Game 11%, Work 14%
    ;CPU: Intel Core2 Duo T7500 - 18%
    ;GPU: Nvidia GeForce 8600M GT - 1.4%
    ;HDD: WD Blue 2.5" 1TB (2004) - 39.8%
    ;MBD: Acer Aspire 7720
    If (RegexMatch(txt, "Desk ([0-9]+)%", sc)) {
	results.Desktop := sc1 . "%"
    }
    
    If (RegexMatch(txt, "CPU: ([^%]+) - ([0-9\.]+)%", cpu)) {
	results.CPU := cpu2 . "%"
	results.CPUModel := cpu1
    }
    If (RegexMatch(txt, "HDD: ([^%]+) - ([0-9\.]+)%", hdd)) {
	results.HDD := hdd2 . "%"
	results.HDDModel := hdd1
    }
    If (RegexMatch(txt, "SSD: ([^%]+) - ([0-9\.]+)%", ssd)) {
	results.SSD := ssd2 . "%"
	results.SSDModel := ssd1
    }
    
    If (results.CPU) ; бывает, HDD не поддается тестированию: http://www.userbenchmark.com/UserRun/5849147 -- && (results.HDD || results.SSD)
	return results
    Else
	return
}

PostResults(ByRef ResultsURL, perfResultsObj:="") {
    static stageTitle := "Запись результатов в таблицу"
	 , extIP := 0
	 , Hostname

    If (!Hostname)
	RegRead Hostname, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    ;RegRead Domain, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain

    Notify(stageTitle . "`nПроверка дубликатов…")
    Try resList := GetURL("https://docs.google.com/spreadsheets/d/e/2PACX-1vSCtCE_IBuSaHQcTs0pNZEGq2PbbiTotNr1Br75Lrhu9Y-SfdDCuB7gTRrSLNixNxmlB_z2GU-uxhjh/pub?gid=178521167&single=true&output=tsv")
    If (!resList)
	dupcheckerr=Список предыдущих результатов не загрузился`, не получится проверить на дубликаты.`n`nОтправить всё равно?
    Else If (InStr(resList, "`n" ResultsURL A_Tab Hostname))
	dupcheckerr=Эта ссылка уже есть в таблице. Отправить повторно?
    Else
	dupcheckerr=
    Progress Off
    If (dupcheckerr) {
	MsgBox 0x124, %stageTitle%, %dupcheckerr%, 300
	IfMsgBox No
	    return
	IfMsgBox Timeout
	    return
    }

    If (!extIP) {
	Notify(stageTitle . "`nОпределение внешнего IP…")
	Try extIP := GetURL("https://api.ipify.org")
    }
    
    Notify(stageTitle . "`nЧтение trello-id.txt…")
    readvars := ["trelloURL", "", "trelloCardName"]
    Loop Read, %A_AppDataCommon%\mobilmir.ru\trello-id.txt
    {
	If (varName := readvars[A_Index])
	    %varName% := A_LoopReadLine
    } Until A_Index > readvars.Length()
    nameShtnr = CutTrelloCardURL
    If (IsFunc(nameShtnr))
	trelloURL := %nameShtnr%(trelloURL)
    
    POSTDATA :="entry.781637524=" 	. UriEncode(Hostname)
	    . "&entry.1905065751="	. UriEncode(A_UserName)
	    . "&entry.293033176="	. UriEncode(trelloURL)
	    . "&entry.56786602="	. UriEncode(trelloCardName)
	    . "&entry.157476182="	. UriEncode(Trim(extIP, " `t`n`r"))
	    . "&entry.1781068882="	. UriEncode(ResultsURL)
	    . ( IsObject(perfResultsObj)
		? ( "&entry.1510085348=" . UriEncode(perfResultsObj.Desktop)
		  . "&entry.223703596="  . UriEncode(perfResultsObj.CPU)
		  . "&entry.1405465926=" . UriEncode(perfResultsObj.CPUModel)
		  . "&entry.1620286468=" . UriEncode(perfResultsObj.HDD)
		  . "&entry.1701865591=" . UriEncode(perfResultsObj.HDDModel)
		  . "&entry.854695461="  . UriEncode(perfResultsObj.SSD)
		  . "&entry.1010033023=" . UriEncode(perfResultsObj.SSDModel)
		  . "&entry.685726891="  . UriEncode(Trim(perfResultsObj.ResultsText, " `t`n`r")) )
		  : "" )

    Notify(stageTitle . "`nОтправка формы…")
    stageDetails := "Запись ссылки " . ResultsURL . (IsObject(perfResultsObj) ? " и текста результатов" : "") . " в таблицу результатов"
    ;Results posted to https://docs.google.com/a/mobilmir.ru/forms/d/1O6UrS9qArvi8r7Pi9LeL79KfrZNIv9eDBVGfCI9zCUo
    Menu Tray, Tip, %stageDetails%`n
    FileAppend %A_Now% %stageDetails%`n,*,CP866
    
    While (!HTTPReq("POST", "https://docs.google.com/a/mobilmir.ru/forms/d/1O6UrS9qArvi8r7Pi9LeL79KfrZNIv9eDBVGfCI9zCUo/formResponse", POSTDATA)) {
	Progress Off
	errText = При отправке произошла ошибка`, HTTP-код %statusHTTP%
	FileAppend %A_Now% %errText%`n,*,CP866
	MsgBox 53, %stageTitle%, %errText%.`n`n[Попытка %A_Index%`, автоповтор – 5 минут], 300
	IfMsgBox Cancel
	{
	    FileAppend % ResultsURL "`n" POSTDATA "`n",%A_Desktop%\UserBenchmark unposted %A_Now%.txt, UTF-8
	    return 0
	}
    }
    
    return 1
}

ResetProgress() {
    Progress Off
    Progress A M ZH0 W600 Hide,, `n%exeName%
    Menu Tray, Tip
}

Notify(txt, appendlog := 1) {
    Menu Tray, Tip, %txt%
    Progress Show
    Progress 0,, %txt%
    If (appendlog)
	FileAppend %A_Now% %txt%`n,*,CP866
}

;GuiClose:
;GuiEscape:
;    ExitApp

WaitCPUIdle() {
    SetFormat FloatFast, 3.2
    
    cycle:=0
    cyclesLimit:=10
    measurementTime:=1000
    measurementTime_s:=measurementTime // 1000
    idleLimit:=0.95
    idleLimitPct:=Round(idleLimit * 100,2)
    
    FileAppend %A_Now% Проверка нагрузки на процессор / ожидание освобождения ресурсов`n, *
    GetIdleTime()
    Progress Off
    Progress A M R0-%cyclesLimit%, `n, % "Ожидание " . idleLimitPct . "% простоя процессора в течение " . cyclesLimit . " секунд"
    Loop
    {
	Sleep %measurementTime%
	If (( idle := GetIdleTime() ) > idleLimit) {
	    cycle++
	} Else {
	    cycle := 0
	}
	Progress %cycle%, % "Текущий процент простоя: " . idle*100
    } Until cycle > cyclesLimit
    Progress Off
}

;http://www.autohotkey.com/board/topic/11910-cpu-usage/
GetIdleTime()    ;idle time fraction
{
    Static oldIdleTime, oldKrnlTime, oldUserTime
    Static newIdleTime, newKrnlTime, newUserTime

    oldIdleTime := newIdleTime
    oldKrnlTime := newKrnlTime
    oldUserTime := newUserTime

    DllCall("GetSystemTimes", "int64P", newIdleTime, "int64P", newKrnlTime, "int64P", newUserTime)
    Return (newIdleTime-oldIdleTime)/(newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)
}

FillGroups() {
    For i, winTitle in [ "ahk_exe POM.exe"
                       , "FLOCK ahk_exe FLOCK.exe"
                       , "Shadow ahk_exe SHADOW.exe"
                       , "http:// ahk_class #32770"] {
	GroupAdd ErrorMessagesEN, %winTitle%, OK
	GroupAdd ErrorMessagesRU, %winTitle%, ОК
    }
}

;FLOCK ahk_exe FLOCK.exe ahk_class #32770
;
;>>>>>>>>>>>>( Mouse Position )<<<<<<<<<<<<<
;On Screen:	584, 205  (less often used)
;In Active Window:	116, -127
;
;>>>>>>>>>( Now Under Mouse Cursor )<<<<<<<<
;
;Color:	0xC0C0C0  (Blue=C0 Green=C0 Red=C0)
;
;>>>>>>>>>>( Active Window Position )<<<<<<<<<<
;left: 468     top: 332     width: 435     height: 119
;
;>>>>>>>>>>>( Status Bar Text )<<<<<<<<<<
;
;>>>>>>>>>>>( Visible Window Text )<<<<<<<<<<<
;ОК
;Could not initialize Direct3D 10. This application requires a Direct3D 10 class
;device (hardware or reference rasterizer) running on Windows Vista (or later).

#include %A_LineFile%\..\..\Lib\HTTPReq.ahk
#include %A_LineFile%\..\..\Lib\GetURL.ahk
#include %A_LineFile%\..\..\Lib\URIEncodeDecode.ahk
#include %A_LineFile%\..\..\Lib\CutTrelloCardURL.ahk
#include %A_LineFile%\..\..\Lib\GetKnownFolder.ahk
