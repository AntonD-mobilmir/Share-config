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
    
    SetTitleMatchMode 2
    actnList := "_;^f;_;Copy results{Esc};_;{Enter};_4;-+;-1;{Esc}^l;_2;-0;--"
    wantUserIdle := 10000 ; ms

    KL_NAMELENGTH = 9
    LANG_ENG := "00000409"
    ;LANG_RUS := "00000419"
    VarSetCapacity(layoutName, (KL_NAMELENGTH+1) * (A_IsUnicode+1)) ; +1 for '\0'
    
    OnClipboardChange("ClipHook")
    Loop
    {
	;MsgBox ResultsURL: %ResultsURL%`nA_Index: %A_Index%
	If (ResultsURL && (IsObject(perfResultsObj) || A_Index > 100) ) {
	    ExitApp !PostResults(ResultsURL, perfResultsObj)
	} Else {
	    sendModeName := SendModes[Mod(A_Index, 3)]
	    SendMode %sendModeName%
	    Menu Tray, Tip, %A_ScriptName%: Cycle %A_Index%`, SendMode %sendModeName%

	    If (WinExist("Performance Results - UserBenchmark")) {
		Loop Parse, actnList, `;
		{
		    Sleep 250
		    If (A_TimeIdlePhysical < wantUserIdle) {
			TrayTip,, Скопируйте результаты теста и ссылку на результаты в буфер обмена (в любом порядке)
			While (A_TimeIdlePhysical < wantUserIdle && !(ResultsURL && IsObject(perfResultsObj))) {
			    If (A_Index==1) {
				Progress Off
				Progress R0-%wantUserIdle%, `n, Ожидание бездействия пользователя
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
	    }
	    
	    Sleep 1000
	}
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

    delay := 15
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
	
	If (A_Index>1) {
	    MsgBox 22, %A_ScriptName%, %UBMzipURL% не скачался., 300
	    IfMsgBox Continue
		break
	    IfMsgBox Cancel
		ExitApp
	}
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

FillGroups()

Loop
{
    Sleep 300
    IfWinExist ahk_group ErrorMessagesEN
	ControlClick OK
    IfWinExist ahk_group ErrorMessagesRU
	ControlClick ОК

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
    static requiredURLprefix := "http://www.userbenchmark.com/UserRun/"
	 , WrongContentsErrText := "Ожидается либо URL с префиксом " requiredURLprefix ", либо текст результатов."
    
    If (cliptype == 1) {
	Try {
	    clipContents := Clipboard
	} Catch e {
	    TrayTip Error reading clipboard, % Error e.Message . "`n" . e.Extra
	    return
	}
    
    	If ( SubStr(clipContents,1,StrLen(requiredURLprefix)) == requiredURLprefix ) {
	    TrayTip Найден URL, %ResultsURL%
	    ResultsURL := clipContents
	} Else If ( IsObject(perfResultsObjNew := ParsePerfResults(clipContents)) ) {
	    perfResultsObj := perfResultsObjNew
	    perfResultsObjNew := ""
	    TrayTip Найден текст с результатами теста, % perfResultsObj.ResultsText
	    ;MsgBox % perfResultsObj.Desktop . "`n" . 	    perfResultsObj.CPU . "`n" . 	    perfResultsObj.CPUModel . "`n" . 	    perfResultsObj.HDD . "`n" . 	    perfResultsObj.HDDModel . "`n" . 	    perfResultsObj.SSD . "`n" . 	    perfResultsObj.SSDModel
	} Else {
	    TrayTip Скопированный текст не подходит, Текст не похож ни на URL`, ни на результаты:`n%WrongContentsErrText%
	    return
	}
    } Else {
	TrayTip Скопирован не текст, %WrongContentsErrText%
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
	 , geoLocation := 0
	 , Hostname

    If (!Hostname)
	RegRead Hostname, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    ;RegRead Domain, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain

    Notify(stageTitle . "`nПроверка дубликатов…")
    If (InStr(res := GetURL("https://docs.google.com/spreadsheets/d/e/2PACX-1vSCtCE_IBuSaHQcTs0pNZEGq2PbbiTotNr1Br75Lrhu9Y-SfdDCuB7gTRrSLNixNxmlB_z2GU-uxhjh/pub?gid=178521167&single=true&output=tsv")
	    , "`n" ResultsURL A_Tab Hostname)) {
	Progress Off    
	MsgBox 0x124, %stageTitle%, Эта ссылка уже есть в таблице. Отправить повторно?, 300
	IfMsgBox No
	    return
	IfMsgBox Timeout
	    return
    }

    Notify(stageTitle . "`nПолучение GeoIP…")
    If (!geoLocation) {
	;API The HTTP API takes GET requests in the following schema:
	;freegeoip.net/{format}/{IP_or_hostname}
	;Supported formats are: csv, xml, json and jsonp. If no IP or hostname is provided, then your own IP is looked up.
	;Examples: CSV freegeoip.net/csv/8.8.8.8	XML freegeoip.net/xml/4.2.2.2	JSON freegeoip.net/json/github.com
	XMLHTTP_Request("GET", "http://freegeoip.net/json/", , geoLocation)
    }
    
    FileReadLine trelloURL, %A_AppDataCommon%\mobilmir.ru\trello-id.txt, 1
    FileReadLine trelloCardName, %A_AppDataCommon%\mobilmir.ru\trello-id.txt, 3
    nameShtnr = CutTrelloCardURL
    If (IsFunc(nameShtnr))
	trelloURL := %nameShtnr%(trelloURL)
    
    POSTDATA :="entry.781637524=" 	. UriEncode(Hostname)
	    . "&entry.1905065751="	. UriEncode(A_UserName)
	    . "&entry.293033176="	. UriEncode(trelloURL)
	    . "&entry.56786602="	. UriEncode(trelloCardName)
	    . "&entry.157476182="	. UriEncode(Trim(geoLocation, " `t`n`r"))
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
    stageDetails := "Запись ссылки " . ResultsURL . (IsObject(perfResultsObj) ? " и текста результатов" ) . " в таблицу результатов"
    ;Results posted to https://docs.google.com/a/mobilmir.ru/forms/d/1O6UrS9qArvi8r7Pi9LeL79KfrZNIv9eDBVGfCI9zCUo
    Menu Tray, Tip, %stageDetails%`n
    FileAppend %A_Now% %stageDetails%`n,*,CP866
    
    While (!XMLHTTP_Post("https://docs.google.com/a/mobilmir.ru/forms/d/1O6UrS9qArvi8r7Pi9LeL79KfrZNIv9eDBVGfCI9zCUo/formResponse", POSTDATA)) {
	Progress Off
	MsgBox 53, %stageTitle%, При отправке произошла ошибка`, HTTP-код %statusHTTP%.`n`n[Попытка %A_Index%`, автоповтор – 5 минут], 300
	IfMsgBox Cancel
	    return
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
    Progress A R0-%cyclesLimit%, `n, % "Ожидание " . idleLimitPct . "% простоя процессора в течение " . cyclesLimit . " секунд"
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

#include %A_LineFile%\..\..\Lib\XMLHTTP_Request.ahk
#include %A_LineFile%\..\..\Lib\PostGoogleForm.ahk
#include %A_LineFile%\..\..\Lib\CutTrelloCardURL.ahk

GetKnownFolder(FolderName) { ;http://www.autohotkey.com/forum/viewtopic.php?t=68194 
    If !RegExMatch(folderdata(),"im`a)^" . foldername . ".+$",line) 
	return 0, ErrorLevel := -2 ;FolderName not found 
    StringSplit,data,line,`, 
    VarSetCapacity(mypath,(A_IsUnicode ? 2 : 1)*1025) 
    
    If A_OSVersion in WIN_2003,WIN_XP,WIN_2000
    {
	If !data3 
	    return 0, ErrorLevel := -1  ;No corresponding CSILD value 
	r := DllCall("Shell32\SHGetFolderPath", "int", 0 , "uint", data3 , "int", 0 , "uint", 0 , "str" , mypath) 
	return (r or ErrorLevel) ? 0 : mypath 
    } Else {
	If !data2
	    return 0, ErrorLevel := -1  ;No corresponding FOLDERID value 
	SetGUID(rfid, data2)
	r := DllCall("Shell32\SHGetKnownFolderPath", "UInt", &rfid, "UInt", 0, "UInt", 0, "UIntP", mypath)
	return (r or ErrorLevel) ? 0 : StrGet(mypath,1025,"UTF-16") 
    }
} 

SetGUID(ByRef GUID, String) { 
    VarSetCapacity(GUID, 16, 0) 
    StringReplace,String,String,-,,All 
    NumPut("0x" . SubStr(String, 2,  8), GUID, 0,  "UInt")   ; DWORD Data1 
    NumPut("0x" . SubStr(String, 10, 4), GUID, 4,  "UShort") ; WORD  Data2 
    NumPut("0x" . SubStr(String, 14, 4), GUID, 6,  "UShort") ; WORD  Data3 
    Loop, 8 
	NumPut("0x" . SubStr(String, 16+(A_Index*2), 2), GUID, 7+A_Index,  "UChar")  ; BYTE  Data4[A_Index] 
} 

folderdata() { 
folderdata =  ;structure is Name,GUID,CSIDL 
( 
AdminTools,{724EF170-A42D-4FEF-9F26-B60E846FBA4F},48 
CDBurning,{9E52AB10-F80D-49DF-ACB8-4330F5687855},59 
CommonAdminTools,{D0384E7D-BAC3-4797-8F14-CBA229B392B5},47 
CommonOEMLinks,{C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D},58 
CommonPrograms,{0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8},23 
CommonStartMenu,{A4115719-D62E-491D-AA7C-E74B8BE3B067},22 
CommonStartup,{82A5EA35-D9CD-47C5-9629-E15D2F714E6E},24 
CommonTemplates,{B94237E7-57AC-4347-9151-B08C6C32D1F7},45 
Contacts,{56784854-C6CB-462b-8169-88E350ACB882}, 
Cookies,{2B0F765D-C0E9-4171-908E-08A611B84FF6},33 
Desktop,{B4BFCC3A-DB2C-424C-B029-7FE99A87C641},0 
DeviceMetadataStore,{5CE4A5E9-E4EB-479D-B89F-130C02886155}, 
DocumentsLibrary,{7B0DB17D-9CD2-4A93-9733-46CC89022E7C}, 
Downloads,{374DE290-123F-4565-9164-39C4925E467B}, 
Favorites,{1777F761-68AD-4D8A-87BD-30B759FA33DD},6 
Fonts,{FD228CB7-AE11-4AE3-864C-16F3910AB8FE},20 
GameTasks,{054FAE61-4DD8-4787-80B6-090220C4B700}, 
History,{D9DC8A3B-B784-432E-A781-5A1130A75963},34 
ImplicitAppShortcuts,{BCB5256F-79F6-4CEE-B725-DC34E402FD46}, 
InternetCache,{352481E8-33BE-4251-BA85-6007CAEDCF9D},32 
Libraries,{1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}, 
Links,{bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968}, 
LocalAppData,{F1B32785-6FBA-4FCF-9D55-7B8E7F157091},28 
LocalAppDataLow,{A520A1A4-1780-4FF6-BD18-167343C5AF16}, 
LocalizedResourcesDir,{2A00375E-224C-49DE-B8D1-440DF7EF3DDC},57 
Music,{4BD8D571-6D19-48D3-BE97-422220080E43}, 
MusicLibrary,{2112AB0A-C86A-4FFE-A368-0DE96E47012E}, 
NetHood,{C5ABBF53-E17F-4121-8900-86626FC2C973},19 
OriginalImages,{2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39}, 
PhotoAlbums,{69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}, 
Pictures,{33E28130-4E1E-4676-835A-98395C3BC3BB},39 
PicturesLibrary,{A990AE9F-A03B-4E80-94BC-9912D7504104}, 
Playlists,{DE92C1C7-837F-4F69-A3BB-86E631204A23}, 
PrintHood,{9274BD8D-CFD1-41C3-B35E-B13F55A758F4},27 
Profile,{5E6C858F-0E22-4760-9AFE-EA3317B67173},40 
ProgramData,{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97},35 
ProgramFiles,{905e63b6-c1bf-494e-b29c-65b732d3d21a},38 
ProgramFilesCommon,{F7F1ED05-9F6D-47A2-AAAE-29D317C6F066},43 
ProgramFilesCommonX64,{6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}, 
ProgramFilesCommonX86,{DE974D24-D9C6-4D3E-BF91-F4455120B917},44 
ProgramFilesX64,{6D809377-6AF0-444b-8957-A3773F02200E}, 
ProgramFilesX86,{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E},42 
Programs,{A77F5D77-2E2B-44C3-A6A2-ABA601054A51},2 
Public,{DFDF76A2-C82A-4D63-906A-5644AC457385}, 
PublicDesktop,{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25},25 
PublicDocuments,{ED4824AF-DCE4-45A8-81E2-FC7965083634},46 
PublicDownloads,{3D644C9B-1FB8-4f30-9B45-F670235F79C0}, 
PublicGameTasks,{DEBF2536-E1A8-4c59-B6A2-414586476AEA}, 
PublicLibraries,{48DAF80B-E6CF-4F4E-B800-0E69D84EE384}, 
PublicMusic,{3214FAB5-9757-4298-BB61-92A9DEAA44FF},53 
PublicPictures,{B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5},54 
PublicRingtones,{E555AB60-153B-4D17-9F04-A5FE99FC15EC}, 
PublicVideos,{2400183A-6185-49FB-A2D8-4A392A602BA3},55 
QuickLaunch,{52a4f021-7b75-48a9-9f6b-4b87a210bc8f}, 
Recent,{AE50C081-EBD2-438A-8655-8A092E34987A},8 
RecordedTVLibrary,{1A6FDBA2-F42D-4358-A798-B74D745926C5}, 
ResourceDir,{8AD10C31-2ADB-4296-A8F7-E4701232C972},56 
Ringtones,{C870044B-F49E-4126-A9C3-B52A1FF411E8}, 
RoamingAppData,{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D},26 
SampleMusic,{B250C668-F57D-4EE1-A63C-290EE7D1AA1F}, 
SamplePictures,{C4900540-2379-4C75-844B-64E6FAF8716B}, 
SamplePlaylists,{15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}, 
SampleVideos,{859EAD94-2E85-48AD-A71A-0969CB56A6CD}, 
SavedGames,{4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4}, 
SavedSearches,{7d1d3a04-debb-4115-95cf-2f29da2920da}, 
SendTo,{8983036C-27C0-404B-8F08-102D10DCFD74},9 
SidebarDefaultParts,{7B396E54-9EC5-4300-BE0A-2482EBAE1A26}, 
SidebarParts,{A75D362E-50FC-4fb7-AC2C-A8BEAA314493}, 
StartMenu,{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19},11 
Startup,{B97D20BB-F46A-4C97-BA10-5E3608430854},7 
System,{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7},37 
SystemX86,{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27},41 
Templates,{A63293E8-664E-48DB-A079-DF759E0509F7},21 
UserPinned,{9E3995AB-1F9C-4F13-B827-48B24B6C7174}, 
UserProfiles,{0762D272-C50A-4BB0-A382-697DCD729B80}, 
UserProgramFiles,{5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}, 
UserProgramFilesCommon,{BCBD3057-CA5C-4622-B42D-BC56DB0AE516}, 
Videos,{18989B1D-99B5-455B-841C-AB7C74E4DDFC}, 
VideosLibrary,{491E922F-5643-4AF4-A7EB-4E7A138D8174}, 
Windows,{F38BF404-1D43-42F2-9305-67DE0B28FC23},36 
ALTSTARTUP,,29 
COMMON_ALTSTARTUP,,30 
COMMON_FAVORITES,,31 
COMPUTERSNEARME,,61 
DESKTOPDIRECTORY,,16 
PERSONAL,,5 
) 
return folderdata 
}

FillGroups() {
    WindowList =
	( LTrim %
	ahk_exe POM.exe
	FLOCK ahk_exe FLOCK.exe
	Shadow ahk_exe SHADOW.exe
	http:// ahk_class #32770
	)

    Loop Parse, WindowList, `n, `r
    {
	GroupAdd ErrorMessagesEN, %A_LoopField%, OK
	GroupAdd ErrorMessagesRU, %A_LoopField%, ОК
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
