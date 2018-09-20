;by LogicDaemon (www.logicdaemon.ru). CC BY 4.0+ http://creativecommons.org/licenses/by/4.0/
#NoEnv
#SingleInstance force

platf_8_3_4	:=	"8.3.4.408"
platf_8_3_10	:=	"8.3.10.2753.1"

ServerPlaforms := { "Srv1S" : [platf_8_3_10, "1cv8.exe"]
		  , "Srv1S-B" : [platf_8_3_10, "1cv8s.exe"]
		  , "Srv1S-R" : [platf_8_3_10, "1cv8s.exe"] }
PlatformNames := { (platf_8_3_10) : "Все базы" }

global WinVer := GetWinVer()
     , LocalAppData := FindLocalAppData()
     , origTemp := A_Temp
     , SystemRoot
EnvGet SystemRoot, SystemRoot

menuCreated := 0

localPlatformCache := LocalAppData "\Programs\1C\PlatformCache"
If (FileExist(LocalAppData "\1C\PlatformCache"))
    FileMoveDir %LocalAppData%\1C\PlatformCache, %localPlatformCache%

For i, argv in A_Args {
    For serverName, platfData in ServerPlaforms
    {
        If (argv ~= "i)\/S" serverName "(?:\.office0\.mobilmir)?(?::\d+)?\\") {
	    PlatformVersionName := platfData[1]
            PlatformExecutiveRelativePath := "bin\" platfData[2]
            ;MsgBox PlatformVersionName: %PlatformVersionName%`nPlatformExecutiveRelativePath: %PlatformExecutiveRelativePath%
	    break
	}
    }
}

If (PlatformVersionName)
    GoTo SelectedPlatform

PlatformExecutiveRelativePath := "bin\1cv8s.exe"

Gui Add, Text, w500, У нас используются разные версии платформы для разных конфигураций 1С. Если попытаться запустить конфигурацию`, не соответствующую платформе`, 1С покажет ошибку и не запустится. Причем окно списка конфигураций показывает платформа`, так что выбрать`, какую запускать платформу`, надо до выбора конфигурации.
Gui Add, ListView, -Multi LV-E0x200 r3 w500 AltSubmit gSelectPlatform, Платформа|Примечание
Gui Add, Button, Default vbtnOK Section, OK
Gui Add, Button, ys gShowMenu vbtnMenu, ...

For platfVer, platfName in PlatformNames
    LV_Add("", platfVer, platfName)
GuiShowAgain:
    Gui Show,, Выбор платформы 1С
    ;GuiControl Choose, ControlID, 1
    ;Exit

SelectPlatform:
    If (selRow := LV_GetNext())
	GuiControl Enable, btnOK
    Else
	GuiControl Disable, btnOK
    If (!(A_GuiEvent=="DoubleClick"))
	return
ButtonOK:
    selRow := LV_GetNext()
    If (!selRow)
	return
    Gui Submit
    LV_GetText(PlatformVersionName, selRow)

SelectedPlatform:
    params := SubStr(CommandLine, InStr(CommandLine := DllCall( "GetCommandLine", "Str" ),A_ScriptName,1)+StrLen(A_ScriptName)+2)
    PlatformSource=%A_ScriptDir%\%PlatformVersionName%
    PlatformSourceArc=%A_ScriptDir%\%PlatformVersionName%.7z

    ProcIDStorage=%origTemp%\1sprocesses.ini

    Menu Tray, Icon, shell32.dll,25,0
    Menu Tray, Tip, Запуск 1С

    If (!GetKeyState("Shift", "P")) {
	IniRead PID1S, %ProcIDStorage%, %PlatformVersionName%, % L128Hash(params)
	GroupAdd 1s, ahk_pid %PID1S% ahk_exe 1cv8.exe
	GroupAdd 1s, ahk_pid %PID1S% ahk_exe 1cv8s.exe
	GroupAdd 1s, ahk_pid %PID1S% ahk_exe 1cv8l.exe

	If (WinExist("ahk_group 1s")) {
	    WinGet MinMaxState, MinMax
	    GroupAdd Running1S, ahk_pid %PID1S%
	    If (MinMax=-1)
		PostMessage 0x112, 0xF120 ; 0x112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE
    	    ;WinRestore
	    WinActivateBottom ahk_pid %PID1S%
	    WinActivate
	    ;WinGet PID1S, PID
	    TrayTip Активация запущенной 1С, Активирован экземпляр 1С`, запущенный с теми же параметрами`, что и вновь вызываемый.`n`nДля запуска нового`, при запуске удерживайте Shift.,,1
	    ToolTip Активирована ранее запущенная 1С. Для запуска новой`, удерживайте Shift при запуске.
	    Sleep 3000
	    ExitApp %PID1S%
	}
    }

    TrayTip Запуск 1С, Настройка временной папки…
    SetupTemp()
    TrayTip

    TrayTip Запуск 1С, Проверка локального кэша платформы...
    PlatformRunPath := CachePlatformLocally(PlatformVersionName) "\" PlatformExecutiveRelativePath
    TrayTip

    TrayTip Запуск 1С, Запуск нового процесса 1С
tryRunAgain:

    Loop %PlatformRunPath%,,1
	Try {
	    ;TrayTip Запуск "%A_LoopFileFullPath%" %params%, Запуск 1С
	    Run "%A_LoopFileFullPath%" %params%, %A_LoopFileDir%, UseErrorLevel, PID1S
	    break
	}

    RunTry:=0
    If (ErrorLevel="ERROR") {
	RunTry++
	If (A_LastError=5) {
	    If (RunTry=1) {
		TrayTip Ошибка запуска из кэша, Не удалось запустить 1С из кэша`, сейчас будут исправлены настройки доступа и выполнена повторная попытка.
		SetupLocalPlatformCachePermissions()
		GoTo tryRunAgain
	    } Else If (RunTry=2) {
		TrayTip Ошибка запуска из кэша, Не удалось запустить 1С из кэша`, вместо этого будет выполнена попытка запуска из сети.`nСообщите в службу ИТ!,,2
		PlatformRunPath = %PlatformSource%\%PlatformExecutiveRelativePath%
		Sleep 1000
		GoTo tryRunAgain
	    }
	}
	MsgBox 16, Не удалось запустить 1С., Код системной ошибки: %A_LastError%. Обратитесь в службу ИТ.
	ExitApp %A_LastError%
    } Else {
	IniWrite %PID1S%, %ProcIDStorage%, %PlatformVersionName%, % L128Hash(params)
    }

    ToolTip
    ToolTip Платформа 1С: Предприятие запущена`, ожидание появления окна
    Loop
    {
	WinWait ahk_pid %PID1S%,,3 ;WinWait WinTitle, WinText, Seconds
	If (ErrorLevel) {
	    Process Exist, %PID1S%
	    If (!ErrorLevel) {
		TrayTip Не удалось запустить 1C., Процесс 1С завершился до появления окна. Обратитесь в службу ИТ.,, 0x22
		Sleep 3000
		ExitApp 1
	    }
	}
    } Until !ErrorLevel
    ToolTip
    Sleep 3000

ExitApp
;-- Functions and procedures

GuiClose:
GuiEscape:
    ExitApp

ShowMenu:
    If (!menuCreated) {
        menuCreated := 1
        Menu ext, Add, Удалить кэши баз данных, remove1scaches
        Menu ext, Add, Удалить локальные копии платформы, removelocalplatform
    }
    Gui +LastFound
    GuiControlGet btnMenu, Pos
    CoordMode Menu, Client
    Menu ext, Show, % btnMenuX + btnMenuW, % btnMenuY + btnMenuH
return

remove1scaches:
    FileRemoveDir %LocalAppData%\1C\1cv8, 1
    return
removelocalplatform:
    FileRemoveDir %localPlatformCache%, 1
    return

CachePlatformLocally(PlatformVersionName) {
    global localPlatformCache, PlatformSource, PlatformSourceArc
    global BackupWorkingDir := A_WorkingDir

    If A_ComputerName contains Srv
	return PlatformSource
    SplitPath PlatformSource, , , , , PlatformSrсDrive
    If PlatformSrсDrive=\\%A_ComputerName%
	return PlatformSource
    If (SubStr(PlatformSrсDrive, 2)==":")
	return PlatformSource
    
    ; ToDo: Clean unused platform versions
    ;Loop %localPlatformCache%\*, 2
    ;    If (A_LoopFileName != PlatformVersionName && A_LoopFileName != platf_8_3_10 && A_LoopFileName != platf_8_3_4)
    ;	FileRemoveDir %A_LoopFileFullPath%, 1
    
    unarchive:=PlatformSourceArc && (!InStr(FileExist(PlatformSourceArc),"D")) ; if true, use 7-Zip instead of copying files
;    If (A_ComputerName=="ACERASPIRE7720G")
;	MsgBox %unarchive%
    ;Check local directory existence and set up permissons, if it's not
    If (!FileExist(localPlatformCache)) {
	Try {
	    ; Create cache directory for the first time. Set up permissions.
	    FileCreateDir %localPlatformCache%
	    RunHiddenConsole(SystemRoot "\System32\compact.exe", "/c /i " . (WinVer >= 6.4 ? "/exe:lzx " : "") . "/S:""" localPlatformCache """")
	    SetupLocalPlatformCachePermissions()
	} Catch e {
	    FileRemoveDir %localPlatformCache%
	    return ShowErrorLocalCaching("ошибка " e.Message " " e.Extra)
	}
    }
    ;localPlatformCache is appended with \%PlatformVersionName% after setting up permissions.
    localPlatformCache=%localPlatformCache%\%PlatformVersionName%
    If (!FileExist(localPlatformCache))
	FileCreateDir %localPlatformCache%
    SetWorkingDir %PlatformSource%
    
    ; Check local cache; find newest file to compare with archive time
    SplashTextOn 300,75,Проверка локального кэша, Выполняется сравнение файлов локального кэша и исходного дистрибутива
    TotalCopySize := 0
    NewestSrcTime := 0
    Try {
	Loop Files, *, R
	{
	    SrcName := A_LoopFileFullPath
	    SrcTime := A_LoopFileTimeModified
	    SrcSize := A_LoopFileSize
	    
	    If (NewestSrcTime < SrcTime)
		NewestSrcTime := SrcTime

	    If (FileExist(localPlatformCache "\" A_LoopFileFullPath)) {
		Loop Files, %localPlatformCache%\%A_LoopFileFullPath%
		    If ( SrcTime != A_LoopFileTimeModified || SrcSize != A_LoopFileSize ) {
			FileDelete %A_LoopFileFullPath%
			TotalCopySize += A_LoopFileSize
		    }
	    } Else
		TotalCopySize += A_LoopFileSize
	}
    } Catch e
	return ShowErrorLocalCaching("ошибка при сравнении локального кэша и платформы на сервере")
    SplashTextOff
    
    DriveSpaceFree FreeSpace, %localPlatformCache%
    TotalCopySizeMB := TotalCopySize//1000000 + 30
    If ( FreeSpace <= TotalCopySizeMB )
	return ShowErrorLocalCaching("Свободно " FreeSpace "МБ из требуемых " TotalCopySizeMB "МБ", "Для локального кэша недостаточно свободного места.")
    If ( unarchive ) {
	FileGetTime platformArcTime, %PlatformSourceArc%, M
	FileGetSize platformArcSize, %PlatformSourceArc%
	
	If (   NewestSrcTime <= platformArcTime		; if newest platform file is older than archive
	    && TotalCopySize >  platformArcSize ) {	; and total size of required files is greater than archive size
	    Try {
		exe7z:=find7zGUIorAny()
		RunWait "%exe7z%" x -aoa -o"%localPlatformCache%" -- "%PlatformSourceArc%", %localPlatformCache%, UseErrorLevel
	    } Catch {
		ErrorLevel:=1
	    }
	    If (ErrorLevel)				; if any errors when unarchiving, fall back to copying
		unarchive := False
	} Else {
	    unarchive := False
	}
    }
    
    If ( !unarchive ) { ; beware, it's not Else block, because unarchive var may be modified in body of prev loop!
	Try {
	    ; Copy differences
	    If TotalCopySize
	    {
		MultiplicatorLetters := "  кМГТ"
		HumanReadableSize:=TotalCopySize
		Loop 4
		{
		    If (HumanReadableSize > 1000)
			HumanReadableSize //= 1000
		    Else
			SizeUnit := SubStr(MultiplicatorLetters, A_Index, 1) "Б"
		}
		Progress A M R0-%TotalCopySize%, Копируемый объём: %HumanReadableSize% %SizeUnit%, Кэширование платформы 1С.`n(версия %PlatformVersionName%)`n`nЭто делается 1 раз для версии`, следующий запуск будет намного быстрее., Скрипт запуска 1С
		Sleep 0
		
		Loop *, 2, 1 ; Only directories, recursively
		{
		    FileCreateDir %localPlatformCache%\%A_LoopFileFullPath%
		    ;Copying files in the dir
		    CopyDirContents(A_LoopFileFullPath "\*", localPlatformCache, TotalCopySize)
		}
		CopyDirContents("*", localPlatformCache)
		If ErrorLevel
		    Throw {what: "Copying Error " ErrorLevel}
	    }
	} Catch e {
	    return ShowErrorLocalCaching(e.What)
	}
    }
    
    Progress Off
    SetWorkingDir %BackupWorkingDir%
    return localPlatformCache
}

ShowErrorLocalCaching(ByRef errt  := "неопределённая ошибка"
		    , ByRef msg   := "При попытке кэширования произошла"
		    , ByRef title := "Кэширование платформы 1С неудачно") {
    global PlatformSource, BackupWorkingDir
    SetWorkingDir %BackupWorkingDir%
    SplashTextOff
    Progress Off
    TrayTip %title%, %msg% %errt%`n1С будет запущена через сеть. Сообщите в службу ИТ!,,2
    Sleep 3000
    return PlatformSource
}

CopyDirContents(ByRef src, ByRef dst, TotalCopySize=400000000) {
    static StartTime, CopiedSize = 0
    SetFormat FloatFast, 0.0
    StartTime := StartTime ? StartTime : A_TickCount
    TotalTime := TotalCopySize // 5000 ; 5 MB/s = 5 kB/ms for LAN
    
    Loop %src%
    {
	; Copying only non-existing files, because previously all discrepant files have been removed
	IfNotExist %dst%\%A_LoopFileFullPath%
	{
	    FileCopy %A_LoopFileFullPath%, %dst%\%A_LoopFileDir%, 1
	    CopiedSize += A_LoopFileSize
	    CurrentTimeInterval := A_TickCount - StartTime
	    TotalTime := (TotalTime * 0.9) + (CurrentTimeInterval * (TotalCopySize / CopiedSize) * 0.1)
		
	    ETA := (TotalTime - CurrentTimeInterval) // 1000
	    ETA := ETA > 0 ? ETA : 0
	    If (ETA < 1)
		ETAForHumans = Готово
	    Else If (ETA < 60)
		ETAForHumans = Осталось меньше минуты
	    Else {
		ETAForHumansNum := ETA // 60
		ETAForHumansHundreds := Mod (ETAForHumansNum, 100)
		LastDigit := SubStr(ETAForHumansHundreds,0)
		SetFormat IntegerFast, D
		ETAForHumans = Осталось %ETAForHumansNum% минут
		If ETAForHumansHundreds not between 5 and 20
		{
		    If LastDigit=1
			ETAForHumans = Осталась %ETAForHumansNum% минута
		    Else If LastDigit between 2 and 4
			ETAForHumans = Осталось %ETAForHumansNum% минуты
		}
	    }
	    Progress %CopiedSize%, %ETAForHumans% (~%ETA% с.)
	    SetFormat FloatFast, 0.0
	}
    }
}

SetupLocalPlatformCachePermissions() {
    global localPlatformCache
    RunSetACL("-on . -ot file -actn ace -ace ""n:S-1-1-0;s:y;p:change;i:so,sc;m:set;w:dacl""", localPlatformCache)
}

SetupTemp() {
    titleTrayTip := "Временная папка не настроена"
    If (temp := CheckSetTemp(origTemp)) {
	Try {
	    RunSetACL("-on """ A_Temp """ -ot file -actn ace -ace ""n:" A_UserName ";s:n;p:change;i:so,sc;m:set;w:dacl""")
	    return temp ;success
	} Catch e {
	    TrayTip %titleTrayTip%, При попытке запуска SetACL возникли ошибки. Не удалось настроить параметры доступа к временной папке.`nСообщите системным администраторам!,,2
	    return 0
	}
    } Else {
	TrayTip %titleTrayTip%, Не удалось создать временную папку для 1С.`nСообщите системным администраторам!,,2
	return 0 ;failure
    }
}

RunSetACL(ByRef args, ByRef dir := "") {
    static exeSetACL := ""
    If (exeSetACL=="")
	For i, exeSetACL in [ "C:\SysUtils\SetACL.exe"
                            , "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Programs\SetACL.exe"
                            , "\\Srv0.office0.mobilmir\profiles$\Share\Programs\SetACL.exe"
                            , "" ]
	    If (FileExist(exeSetACL))
		break
    If (exeSetACL)
	RunHiddenConsole(exeSetACL, args, dir)
    Else
	Throw Exception("SetACL.exe not found")
}

RunHiddenConsole(ByRef exe, ByRef args := "", ByRef dir := "") {
    global runwaitPID
    SetTimer ShowrunwaitPID, -15000
    RunWait %exe% %args%, %dir%, Hide UseErrorLevel, runwaitPID
    runwaitError := ErrorLevel
    SetTimer ShowrunwaitPID, Off
    If (runwaitError)
	Throw Exception(ErrorLevel,, "RunWait " exe " " args)
}

ShowrunwaitPID() {
    global runwaitPID
    WinShow ahk_pid %runwaitPID%
}

CheckSetTemp(path) {
    IfExist %path%\.
	FileCreateDir %path%\1stemp
    IfExist %path%\1stemp
    {
	EnvSet temp, %path%\1stemp
	EnvSet tmp, %path%\1stemp
	return path "\1stemp" ;success
    }
    If (A_ComputerName = "ACERASPIRE7720G") {
	MsgBox Fail: %path%\1stemp`nFreeSpace: %FreeSpace%
    }
    return 0 ;failure
}

FindLocalAppData() {
    VarSetCapacity(LocalAppData,(A_IsUnicode ? 2 : 1)*1025) 
    r:=DllCall("Shell32\SHGetFolderPath", "int", 0 , "uint", 28 , "int", 0 , "uint", 0 , "str" , LocalAppData)
    If (r or ErrorLevel) {
	EnvGet USERPROFILE,USERPROFILE
	LocalAppData := if_Exist(USERPROFILE "\Local Settings\Application Data") || if_Exist(A_AppData "\..\Local") || origTemp
    }
    return LocalAppData
}

if_Exist(path) {
    IfExist %path%
	return path
    return false
}

;\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\find7zexe.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

find7zexe(exename="7z.exe", paths*) {
    ;key, value, flag "this is path to exe (only use directory)"
    regPaths := [["HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command",,1]
		,["HKEY_CURRENT_USER\Software\7-Zip", "Path"]
		,["HKEY_LOCAL_MACHINE\Software\7-Zip", "Path"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe", "Path"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe",,1]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "InstallLocation"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "UninstallString", 1] ]
    
    bakRegView := A_RegView
    For i,regpath in regPaths
    {
	SetRegView 64
	RegRead currpath, % regpath[1], % regpath[2]
	SetRegView %bakRegView%
	If (regpath[3]) 
	    SplitPath currpath,,currpath
	Try return Check7zDir(exename, Trim(currpath,""""))
    }
    
    findexefunc=findexe
    If(IsFunc(findexefunc)) {
	EnvGet ProgramFilesx86,ProgramFiles(x86)
	EnvGet SystemDrive,SystemDrive
	Try return %findexefunc%(exename, ProgramFiles "\7-Zip", ProgramFilesx86 "\7-Zip", SystemDrive "\Program Files\7-Zip", SystemDrive "\Arc\7-Zip")
	Try return %findexefunc%("7za.exe", SystemDrive "\Arc\7-Zip")
    }
    
    For i,path in paths {
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%exename%
	    IfExist %fullpath%
		return fullpath
	}
    }
    
    Throw exename " not found"
}

Check7zDir(exename,dir7z) {
    If(SubStr(dir7z,0)=="\")
	dir7z:=SubStr(dir7z,1,-1)
    exe7z=%dir7z%\%exename%
    IfNotExist %exe7z%
	Throw exename " not found in " dir7z
    return exe7z
}

find7zaexe(paths:="") {
    If(paths=="")
	paths := []
    paths.push("\Distributives\Soft\PreInstalled\utils", "D:\Distributives\Soft\PreInstalled\utils","W:\Distributives\Soft\PreInstalled\utils", "\\localhost\Distributives\Soft\PreInstalled\utils", "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils","\\192.168.1.80\Distributives\Soft\PreInstalled\utils")
    return find7zexe("7za.exe",paths*)
}

find7zGUIorAny() {
    Try	return find7zexe("7zg.exe")
    Try return find7zexe()
    return find7zaexe()
}

;\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\findexe.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

findexe(exe, paths*) {
    ; exe is name only or full path
    ; paths are additional full paths, dirs or path-masks to check for
    ; first check if executable is in %PATH%

    Loop Files, %exe%
	return A_LoopFileLongPath
    
    SplitPath exe, exename, , exeext
    If (exeext=="") {
	exe .= ".exe"
	exename .= ".exe"
    }
    
    Try return GetPathForFile(exe, paths*)
    
    Try {
	RegRead AppPath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exename%
	IfExist %AppPath%
	    return AppPath
    }
    
    Try {
	RegRead AppPath, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exename%
	IfExist %AppPath%
	    return AppPath
    }
    
    EnvGet Path,PATH
    Try return GetPathForFile(exe, StrSplit(Path,";")*)
    
    EnvGet utilsdir,utilsdir
    If (utilsdir)
	Try return GetPathForFile(exe, utilsdir)
    
    ;Look for registered apps
    Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\Applications\" exename)
    Loop Reg, HKEY_CLASSES_ROOT\, K
    {
	Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\" %A_LoopRegName%)
    }
    
    Try return GetPathForFile(exe, A_LineFile "..\..\..\..\..\..\Distributives\Soft\PreInstalled\utils" ; Srv0 only
				 , A_LineFile "..\..\..\..\Program Files" ; Srv0 only
				 , A_LineFile "..\..\..\..\Soft\PreInstalled\utils" ; in retail, when config and soft are in D:\Distributives
				 , A_LineFile "..\..\..\..\..\Distributives\Soft\PreInstalled\utils" ; in retail, for case when config is in some other dir
				 , "\Distributives\Soft\PreInstalled\utils" ; same
				 , "\\localhost\Distributives\Soft\PreInstalled\utils" ; sometimes Distributives are somewhere else but available on net
				 , "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils" ; almost last resort, only works in office0
				 , "\\Srv0.office0.mobilmir\profiles$\Share\Program Files" ) ; last resort, only works in office0

    EnvGet SystemDrive,SystemDrive
    Loop Files, %SystemDrive%\SysUtils\%exename%, R
    {
	Try return GetPathForFile(exe, A_LoopFileLongPath)
    }
    
    Throw { Message: "Requested execuable not found", What: A_ThisFunc, Extra: exe }
}

GetPathForFile(file, paths*) {
    For i,path in paths {
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%file%
	    IfExist %fullpath%
		return fullpath
	}
    }
    
    Throw
}

RemoveParameters(runStr) {
    QuotedFlag=0
    Loop Parse, runStr, %A_Space%
    {
	AppPathOnly .= A_LoopField
	IfInString A_LoopField, "
	    QuotedFlag:=!QuotedFlag
	If Not QuotedFlag
	    break
	AppPathOnly .= A_Space
    }
    return Trim(AppPathOnly, """")
}

GetAppPathFromRegShellKey(exename, regsubKeyShell) {
    regsubKey=%regsubKeyShell%\shell
    Loop Reg, %regsubKey%, K
    {
	RegRead regAppRun, %regsubKey%\%A_LoopRegName%\Command
	regpath := RemoveParameters(regAppRun)
	SplitPath regpath, regexe
	If (exename=regexe)
	    IfExist %regpath%
		return regpath
    }
    Throw
}

;-- Fast 64- and 128-bit hash functions
;http://www.autohotkey.com/board/topic/14040-fast-64-and-128-bit-hash-functions/

L64Hash(x) {						; 64-bit generalized LFSR hash of string x
   Local i, R = 0
   LHashInit()					  ; 1st time set LHASH0..LHAS256 global table
   Loop Parse, x
   {
	  i := (R >> 56) & 255		  ; dynamic vars are global
	  R := (R << 8) + Asc(A_LoopField) ^ LHASH%i%
   }
   Return Hex8(R>>32) . Hex8(R)
}

L128Hash(x) {					   ; 128-bit generalized LFSR hash of string x
   Local i, S = 0, R = -1
   LHashInit()					  ; 1st time set LHASH0..LHAS256 global table
   Loop Parse, x
   {
	  i := (R >> 56) & 255		  ; dynamic vars are global
	  R := (R << 8) + Asc(A_LoopField) ^ LHASH%i%
	  i := (S >> 56) & 255
	  S := (S << 8) + Asc(A_LoopField) - LHASH%i%
   }
   Return Hex8(R>>32) . Hex8(R) . Hex8(S>>32) . Hex8(S)
}

Hex8(i) {						   ; integer -> LS 8 hex digits
   SetFormat Integer, Hex
   i:= 0x100000000 | i & 0xFFFFFFFF ; mask LS word, set bit32 for leading 0's --> hex
   SetFormat IntegerFast, D
   Return SubStr(i,-7)			  ; 8 LS digits = 32 unsigned bits
}

LHashInit() {					   ; build pseudorandom substitution table
   Local i, u = 0, v = 0
   If LHASH0=
	  Loop 256 {
		 i := A_Index - 1
		 TEA(u,v, 1,22,333,4444, 8) ; <- to be portable, no Random()
		 LHASH%i% := (u<<32) | v
	  }
}
									; [y,z] = 64-bit I/0 block, [k0,k1,k2,k3] = 128-bit key
TEA(ByRef y,ByRef z, k0,k1,k2,k3, n = 32) { ; n = #Rounds
   s := 0, d := 0x9E3779B9
   Loop %n% {					   ; standard = 32, 8 for speed
	  k := "k" . s & 3			  ; indexing the key
	  y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
	  s := 0xFFFFFFFF & (s + d)	 ; simulate 32 bit operations
	  k := "k" . s >> 11 & 3
	  z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
}

GetWinVer() {
    return ((r := DllCall("GetVersion") & 0xFFFF) & 0xFF) "." (r >> 8)
}
