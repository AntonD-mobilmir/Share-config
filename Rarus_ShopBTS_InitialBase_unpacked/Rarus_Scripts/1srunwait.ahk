#NoEnv
#SingleInstance force
Menu Tray, Icon, shell32.dll,25,0
Menu Tray, Tip, Запуск 1С-Рарус

global	run1sexe:="1cv7s.exe"
      , ExcessArcTimeLim:=5*60 ; s
      , WaitArchivingStartTimeout := A_TickCount + 5*60*1000 ; ms
      , lProgramFiles
      , run1sDir
      , params := ParseCommandLine()
      , rarusWinTitle := "1С:Предприятие"

DailyArchiveFName = ShopBTS_%A_Year%-%A_MM%-%A_DD%.7z
MonthlyArchiveFName = ShopBTS_%A_Year%-%A_MM%.7z
zpaqFName = %A_YYYY%.zpaq

EnvGet lProgramFiles, ProgramFiles(x86)
If (!lProgramFiles)
    lProgramFiles=%A_ProgramFiles%

For i, v in ["D:\1S\1Cv77\BIN", lProgramFiles "\1Cv77\BIN"]
    If (FileExist(v "\" run1sexe))
	run1sDir := v
If (!run1sDir)
    Throw Exception("Не найдена папка с исполняемым файлом 1С-Рарус",,v "\" run1sexe)

If (WinExist(rarusWinTitle " ahk_exe " run1sexe)) {
    WinRestore
    WinActivate
    TRAYTIP_ICON_INFO := 1
    TRAYTIP_NO_SOUND := 16
    TRAYTIP_LARGEICON := 32
    TrayTip 1C-Рарус уже запущен, Скрипт попытался активировать окно 1С`, но защита от перехвата фокуса Windows иногда не позволяет это сделать. В таком случае самостоятельно найдите 1C на панели задач и разверните окно., 3, TRAYTIP_ICON_INFO+TRAYTIP_NO_SOUND+TRAYTIP_LARGEICON
    Sleep 3000
    ExitApp
}

If (!(rarusbackupflag := ReadSetVarFromBatchFile(A_ScriptDir . "\_rarus_backup_get_files.cmd", "rarusbackupflag"))) {
    MailWarning("Не удалось прочитать расположение флага архивации")
    MsgBox 0x24, Ошибка при выполнении скрипта запуска 1С, Не удалось получить размещение флага архивации`, поэтому невозможно определить`, идет ли архивация.`nЗапустить 1С`, игнорируя возможный процесс архивации?`n`n`(если 1С запустить во время архивации`, в работе как 1С`, так и архиватора может произойти сбой), 300
    IfMsgBox Timeout
	ExitApp
    IfMsgBox Yes
	Run1S()
    Exit
}
backupsDir := ReadSetVarFromBatchFile(A_ScriptDir . "\_rarus_backup_get_files.cmd", "destdir")

;проверить наличие и дату флага резервной копии
Loop Files, %rarusbackupflag%
{
    t_UpTime := A_TickCount // 1000                     ; Количество секунд, прошедших с загрузки Windows
    t_StartTime :=                                      ; Если к пустой переменной прибавить промежуток времени, получается время на указанную длительность больше текущего
    t_StartTime += -t_UpTime, Seconds                   ; если длительность указана с минусом, получается время меньше текущего
    If  ( A_LoopFileTimeCreated < t_StartTime ) {       ; Флаг создан до перезагрузки?
	FileDelete %rarusbackupflag%			;	удалить
	MailWarning("При запуске обнаружен флаг архивации, созданный до перезагрузки", "Время загрузки: " . t_StartTime "`nВремя создания флага: " . A_LoopFileTimeCreated )	;	отправлять уведомление о такой ситуации, поскольку это значит, что компьютер перезагрузили в процессе создания копии
    }
}

If (A_TickCount < WaitArchivingStartTimeout                    			; soon after script start
	&& !(  FileExist(rarusbackupflag)  		    			; and no: flag
	    || FileExist(backupsDir . "\" . zpaqFName)  		    	; 	or zpaq archive
	    || FileExist(backupsDir . "\" . DailyArchiveFName) 			; 	or daily backup
	    || FileCreatedAfterBoot(backupsDir . "\" . DailyArchiveFName . ".tmp")	; 	or daily backup temp exist
	    || FileCreatedAfterBoot(backupsDir . "\" . MonthlyArchiveFName . ".tmp")	; 	or temporary file of monthly archive exist
	    || FileCreatedAfterBoot(backupsDir . "\" . MonthlyArchiveFName) ) ) { 	;	or monthly backup created after last boot (e.g. just now) - because if it's created before last boot, we should wait daily archive instead
    ResetProgress(WaitArchivingStartTimeout, A_TickCount)
    Loop {
	Notify("Архивация должна запускаться каждый день при первом включении компьютера, но ещё не запустилась.", A_TickCount, A_TickCount//1000 . " / " . WaitArchivingStartTimeout//1000)
	Sleep 100
    } Until (A_TickCount > WaitArchivingStartTimeout || FileExist(rarusbackupflag))
    Sleep 1000
}

Process WaitClose, %run1sexe%, 8
If (ErrorLevel) {
    MsgBox 0x24, Процесс 1С существует, Процесс %run1sexe% существует (запущен)`, но не имеет окна.`n`nОстановить текущий процесс?`nУбедитесь`, что окна 1С действительно нет на экране`, прежде чем соглашаться., 300
    IfMsgBox TIMEOUT
	ExitApp
    IfMsgBox Yes
    {
	Loop
	{
	    Process Close, %run1sexe%
	    Process Exist, %run1sexe%
	} Until !ErrorLevel
    }
}

If (FileExist(backupsDir . "\*.zpaq")) { ; есть архивы zpaq
    ; ToDo: рассчитать время создания архива по значениям в %rarusbackuplogfile%
    If (!FileExist(backupsDir . "\" . zpaqFName)) { ; но нет архива за текущий год
	avgArchivingTime := 600
	If (!WaitFile(rarusbackupflag, backupsDir . "\" . zpaqFName, WaitArchivingStartTimeout))
	    BackupAppearanceTimeout("Вышло время ожидания появления архива zpaq (" avgArchivingTime " с)")
    } Else {
	avgArchivingTime := 300
    }
} Else If ( !FileExist(backupsDir . "\" . MonthlyArchiveFName) ; если ежемесячного архива нет
	 || FileCreatedAfterBoot(backupsDir . "\" . MonthlyArchiveFName . ".tmp") ; или есть временный файл ежемесячного архива
	 || FileCreatedAfterBoot(backupsDir . "\" . MonthlyArchiveFName) ) { ;или ежемесяный архив уже существует и создан после загрузки (ежедневного архива не будет до следующей перезагрузки)
    ; то ожидание ежемесячного архива
    ; Ежемесячный архив может создаваться долго: 1-2 минуты перед появлением файла, и ещё 2-3 до создания архива. При этом r:\rarus-backup-start.log будет пустой с актуальной датой.
    If ( WaitFile(rarusbackupflag, [backupsDir . "\" . MonthlyArchiveFName, backupsDir . "\" . MonthlyArchiveFName . ".tmp"], WaitArchivingStartTimeout) ) {
	avgArchivingTime := CalcAvgWritingTime(backupsDir . "\ShopBTS_????-??.7z")
    } Else {
	BackupAppearanceTimeout("Вышло время ожидания ежемесячного архива (" avgArchivingTime " с)")
    }
} Else { ; ежесмесячный архив есть. Если архивация работает, будет создан ежедневный
    If ( WaitFile(rarusbackupflag, [backupsDir . "\" . DailyArchiveFName, backupsDir . "\" . DailyArchiveFName . ".tmp"], WaitArchivingStartTimeout) ) {
	If (A_MM==1) {
	    prevMonth := A_Year-1 . "-12"
	} Else {
	    prevMonth := A_Year . "-" . SubStr("0" . A_MM-1, -1)
	}
	avgArchivingTime := CalcAvgWritingTime(backupsDir . "\ShopBTS_" . prevMonth . "-??.7z", backupsDir . "\ShopBTS_" . A_Year . "-" . A_MM . "-??.7z")
    } Else {
	BackupAppearanceTimeout("Вышло время ожидания ежедневного архива (" avgArchivingTime " с)")
    }
}
If (avgArchivingTime<30)
    avgArchivingTime:=180

ResetProgress(avgArchivingTime)

initTime := A_TickCount
While FileExist(rarusbackupflag) {
    Sleep 1000-Mod(A_TickCount, 1000)
    
    timeWaiting := (A_TickCount-initTime)//1000
    If (moreThanAvg) {
	If (timeWaiting > avgArchivingTime+ExcessArcTimeLim) {
	    Run1S()
	    
	    MailWarning("Резервные копии создаются очень долго", "Ожидание остановлено после " . timeWaiting . " с.`nРасчётное среднее время архивации: " . avgArchivingTime)
	    ExitApp
	}
	Notify("Резеревное копирование выполняется дольше обычного.`n1C-Рарус запустится через " . ExcessArcTimeLim//60 . " мин., даже если резервное копирование не завершится", timeWaiting, timeWaiting . " с / " . avgArchivingTime+ExcessArcTimeLim . " с")
    } Else {
	If (timeWaiting > avgArchivingTime) {
	    moreThanAvg:=1
	    ResetProgress(avgArchivingTime+ExcessArcTimeLim)
	}
	Notify("Пожалуйста подождите, выполняется резервное копирование.`nКак только оно завершится, Рарус будет запущен.", timeWaiting, timeWaiting . " с. / " . avgArchivingTime . " c.")
    }
}

ResetProgress()
Notify("Резервное копирование завершено. Выполняется запуск 1C-Рарус.")
Run1S()

ExitApp

BackupAppearanceTimeout(t:="") {
    ; Проверить, когда выполнена загрузка – если не сегодня, создание архива не запускалось автоматически
    secSinceBoot := A_TickCount//1000
    bootTime += -%secSinceBoot%, Seconds
    MailWarning("Не создаются резервные копии 1С-Рарус`nuptime: " . secSinceBoot . ", bootTime: " . bootTime . "`n" . t)

    ;YYYYMMDDHH24MISS
    ;↑↑↑↑↑↑↑↑ (8 char)
    If (SubStr(bootTime, 1, 8) != A_YYYY . A_MM . A_DD) {
	FormatTime bootTimeLong, %bootTime%
	uptimeHours := secSinceBoot // (60*60)
	MsgBox 0x34, Компьютер загружался не сегодня, Компьютер включен с %bootTimeLong% (%uptimeHours% час.).`nДля создания резервной копии 1С-Рарус требуется перезагрузка. Перезагрузить сейчас?`n`n(если ответите нет – перезагрузите сами при первой возможности), 60
	IfMsgBox Yes
	{
	    Shutdown 2
	    ExitApp
	}
    } Else {
	MsgBox 0x116, Резервные копии 1С-Рарус не создаются, %t%`nРезервные копии должны создаваться каждый день при первом включении компьютера`, но cкрипт запуска 1С-Рарус не дождался появления резервной копии.`n`nМожно`n→отменить запуск 1С-Рарус`,`n→повторить проверку резервной копии или `n→продолжить запуск 1С-Рарус несмотря на ошибку., 300
	;Cancel/Try Again/Continue
	IfMsgBox Timeout
	    ReloadScript()
	IfMsgBox TryAgain
	    ReloadScript()
	IfMsgBox Continue
	    Run1S()
	ExitApp
    }
}

Run1S() {
    global run1sexe, params, run1sDir
    ResetProgress()
    Run %run1sexe% ENTERPRISE %params%, %run1sDir%, UseErrorLevel, PID1S
    If ErrorLevel
    {
	ResetProgress()
	MsgBox 0x10,Ошибка при запуске 1С,Не удалось запустить %run1sDir%\%run1sexe%.`nСообщите об этом технической поддержке.
	ExitApp
    }

    WinWait ahk_pid %PID1S%,,15
    ; ErrorLevel is set to 1 if the command timed out or 0 otherwise. 
    If (ErrorLevel)
	MsgBox 0x10, Ошибка при выполнении скрипта запуска 1С, Не обнаружена заставка 1С-Рарус`, появляющаяся при запуске. Либо 1С не запустилась`, либо в работе скрипта возникли ошибки.`n`nСообщите об этом технической поддержке., 60

    waitDelay := 20
    winMsgbox1S := "1С:Предприятие ahk_class #32770 ahk_pid " . PID1S
    Loop 3
    {
	WinWait %winMsgbox1S%,,%waitDelay%
	waitDelay := 20
	If (ErrorLevel) {
	    break
	} Else {
	    Menu Tray, Tip, Ответ на глупые вопросы 1С-Рарус
	    IfWinExist %winMsgbox1S%, Выполнить открытие периода ?
		ControlClick Button1 ;&Да
	    Else IfWinExist %winMsgbox1S%, Переиндексировать таблицы базы данных?
	    {
		ControlClick Button1 ;&Да
		waitDelay := 120
	    } Else IfWinExist %winMsgbox1S%, Не найден ключ защиты программы.
		ControlClick Button1 ;&Да
	    Else { ; неизвестное сообщение
		notificationFileName = %A_Temp%\1srunwait - new msgboxes.txt
		ControlGetText textWin
		FileAppend `n%A_Now%: New unknown message box appeared after starting 1cv7`nWindow text: %textWin%`n,%notificationFileName%
		WinGet controlNamesList, ControlList
		Loop Parse, controlNamesList, `n
		{
		    ControlGetText controlText, %A_LoopField%
		    FileAppend Control "%A_LoopField%" text: %controlText%`n,%notificationFileName%
		}
		TRAYTIP_ICON_INFO := 1
		TRAYTIP_NO_SOUND := 16
		TRAYTIP_LARGEICON := 32
		TrayTip Новое окно сообщений 1C, При запуске 1С обнаружно окно сообщений`, появление которого не предусмотрено в скрипте запуска. Записан журнал. Пожалуйста`, сообщите об этом в службу ИТ!, 30, TRAYTIP_ICON_INFO+TRAYTIP_NO_SOUND+TRAYTIP_LARGEICON
		break
	    }
	}
    }
}

CalcAvgWritingTime(paths*) {
    For i,path in paths {
	Loop Files, %path%
	{
	    ArchivingTime := A_LoopFileTimeModified
	    ArchivingTime -= A_LoopFileTimeCreated, Seconds
	    If (ArchivingTime > 0 && ArchivingTime < 1000) { ; в Звёздном 2016-02 создан 12.02 в 18:15, изменён 12.02 в 14:17 (раньше)
		SumArcTime += ArchivingTime
		countArchives ++
		;MsgBox Время архивации %A_LoopFileName%: %ArchivingTime%`nСуммарное время архивации %countArchives% архивов: %SumArcTime%
	    }
	}
    }

    If (countArchives)
	return Round(SumArcTime // countArchives * 1.1)
    Else
	return -1
}

WaitFile(flag, paths, timeout, note:="") {
    If (!IsObject(paths))
	paths := [paths]
    If (!note)
	note := "Ожидание появления файла " . path
    ResetProgress(timeout >> 8)
    endTime := A_TickCount + timeout
    While (flag && FileExist(flag)) {
	If (path := FirstExisting(paths))
	    return path
	If (A_TickCount > endTime) {
	    Progress Off
	    return
	}
	Notify(note, (endTime - A_TickCount) >> 8)
	Sleep 250
    }
    return FirstExisting(paths)
}

FirstExisting(paths) {
    For i,path in paths
	If (FileExist(path))
	    return path
}

ResetProgress(pRange := 0, pInit := 0) {
    Progress Off
    If (pRange)
	progressBarRange:=" R" pInit "-" . pRange
    Else
	progressBarHeight:=" ZH0"
    Progress A M%progressBarHeight%%progressBarRange% Hide, %A_Space%, `n`n`n`n`n, Запуск 1С-Рарус
    Menu Tray, Tip
}
Notify(txt, p:=0, progressText:="") {
    Menu Tray, Tip, %txt%
    Progress Show
    Progress %p%, %progressText%, %txt%
}

MailWarning(mailtitle, mailtext:="") {
    global backupsDir
    outgoingEmailAttDir=d:\1S\Rarus\ShopBTS\ExtForms\post\OutgoingText\nobackupwarning
    outgoingEmailFile=%outgoingEmailAttDir%.txt

    Try deptID := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_SharedMailUserId.cmd", "MailUserId")
    If (!deptID)
	FileReadLine deptID, d:\1S\Rarus\ShopBTS\ExtForms\post\sendemail.cfg, 1
    
    FileCreateDir %outgoingEmailAttDir%
    RunWait %comspec% /C "DIR /A /O /S "%backupsDir%" >>"%outgoingEmailAttDir%\dir.txt" 2>&1",%backupsDir%,UseErrorLevel

    Try exe7z := find7zexe()
    If (!exe7z)
	Try exe7z := find7zaexe()
    If (exe7z) {
	RunWait "%exe7z%" a "%outgoingEmailAttDir%\logs.7z" r:\*.log, R:\, Hide UseErrorLevel
    } Else {
	FileCopy r:\Rarus_backup.log,%outgoingEmailAttDir%
	FileCopy r:\rarus-backup-start.log,%outgoingEmailAttDir%
    }
    FileAppend rarus-nobackups-warning@rarus.robots.mobilmir.ru`n%deptID% (%A_ComputerName%): %mailtitle%`n%mailtext%,%outgoingEmailFile%,CP1251
    
    Run "%A_AhkPath%" "d:\1S\Rarus\ShopBTS\ExtForms\post\DispatchFiles.ahk",d:\1S\Rarus\ShopBTS\ExtForms\post
}

ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	trimmedReadLine:=Trim(A_LoopReadLine)
	If (SubStr(trimmedReadLine, 1, 4) = "SET ") {
	    splitter := InStr(trimmedReadLine, "=")
	    If (splitter && Trim(SubStr(trimmedReadLine, 5, splitter-5), """`t ") = varname) {
		return Trim(SubStr(trimmedReadLine, splitter+1), """`t ")
	    }
	}
    }
}

ReloadScript() {
    CommandLine := DllCall( "GetCommandLine", "Str" )
    RunWait %CommandLine%
    ListLines
    MsgBox 0x10, Ошибка при перезапуске скрипта запуска 1С, При перезапуске скрипта запуска 1С старая копия должна автоматически выгружаться из памяти. Но это сообщение выводится из старой копии. Сообщите в службу ИТ!
    Pause
}

ParseCommandLine() {
    CommandLine := DllCall( "GetCommandLine", "Str" )
    ; ["]%A_AhkPath%["] [args] ["][%A_ScriptDir%\]%A_ScriptName%["] [rarus-args]
    
    inQuote := 0
    currFragmentEnd := 1
    Loop Parse, CommandLine, %A_Space%%A_Tab%
    {
	If (!inQuote) {
	    currArgStart := currFragmentEnd
	    argNo++
	}
	currFragmentEnd += StrLen(A_LoopField)+1
	
	outerLoopField := A_LoopField
	Loop Parse, A_LoopField, "
	{
	    If (A_Index-1) ; for «"string"», first loop field is empty. If string at EOL, last too.
		inQuote := !inQuote
	}

	If (inQuote) { ; this substring is part of quote (starting at currArgStart)
	    continue
	}
	; Else := If(!inQuote) { ; quote is just over or not started
	currArg := Trim(SubStr(CommandLine, currArgStart, currFragmentEnd - currArgStart))

	If (realScriptPath) { ; script name found in cmdline, script args following
	    ; on first entrance, %1% must be = Trim(currArg; """")
;	    If (currArg="/KillOnExit") {
;		skipChars := currFragmentEnd ; next char after this argument
;	    	global forceExit :=0
;	    }
	    break ; break in any case, because first argument after script name needed check only
	} Else {
	    If (argNo==1) {
		;First arg is always autohotkey-exe (path optional, for example, if started via cmdline: try «cmd /c ahk.exe script.ahk»; even extension may not be there. Path can be partial, repeating ahk-name: «./ahk.exe/ahk script/ahk/script.ahk»).
;		RealAhkPath := currArg
	    } Else If (InStr(currArg, A_ScriptName)) {
		realScriptPath := currArg
		skipChars := currFragmentEnd ; next char after real script name
	    }
	}
    }
    
    return SubStr(CommandLine, skipChars)
}

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
    
    EnvGet ProgramFilesx86,ProgramFiles(x86)
    EnvGet SystemDrive,SystemDrive
    Try return findexe(exename, ProgramFiles . "\7-Zip", ProgramFilesx86 . "\7-Zip", SystemDrive . "\Program Files\7-Zip", SystemDrive . "\Arc\7-Zip")
    Try return findexe("7za.exe", SystemDrive . "\Arc\7-Zip")
    
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
	Throw exename " not found in " . dir7z
    return exe7z
}

find7zaexe(paths:="") {
    If(paths=="")
	paths := []
    paths.push("\Distributives\Soft\PreInstalled\utils", "D:\Distributives\Soft\PreInstalled\utils","W:\Distributives\Soft\PreInstalled\utils", "\\localhost\Distributives\Soft\PreInstalled\utils", "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils","\\192.168.1.80\Distributives\Soft\PreInstalled\utils")
    return find7zexe("7za.exe",paths*)
}

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
    Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\Applications\" . exename)
    Loop Reg, HKEY_CLASSES_ROOT\, K
    {
	Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\" . %A_LoopRegName%)
    }
    
    Try return GetPathForFile(exe, A_ScriptDir . "..\..\..\Distributives\Soft\PreInstalled\utils"
				 , A_ScriptDir . "..\..\Soft\PreInstalled\utils"
				 , "\Distributives\Soft\PreInstalled\utils"
				 , "\\localhost\Distributives\Soft\PreInstalled\utils"
				 , "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils" )

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

FileCreatedAfterBoot(path) {
    If (FileExist(path))
	return A_TickCount > FileAge(path)*1000
    Else
	return
}

FileAge(path, unit="s", timestampType="M") {
    FileGetTime fTime, %path%, %timestampType%
    fAge -= fTime, %unit%
    return fAge
}
