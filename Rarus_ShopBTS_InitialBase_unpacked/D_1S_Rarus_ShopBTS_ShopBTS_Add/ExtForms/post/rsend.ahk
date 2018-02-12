#NoEnv
Menu Tray, Icon, %A_WinDir%\system32\shell32.dll,69,0
Menu Tray, Tip, Отправка выгрузок 1C-Рарус

moveFileInsteadOfEmail:=0
logfile=%A_Temp%\%A_ScriptName%.log
lockfile=%A_Temp%\%A_ScriptName%.lock
exe7z := find7zGUIorAny()

TrayTip Подготовка файла выгрузки к отправке, Проверка прямого доступа к папке входящих на офисном сервере 1С
For i, exchangeSrvr in ["Srv1S.office0.mobilmir", "Rarus-Exchange-Server.office.mobilmir.ru"] {
    queueDir := "\\" exchangeSrvr "\Exchange\LAN\In\txt"
    moveFileInsteadOfEmail := InStr(FileExist(queueDir), "D")
} Until moveFileInsteadOfEmail
TrayTip

If (!moveFileInsteadOfEmail)
    queueDir := A_ScriptDir "\OutgoingFiles"

While (!FileExist(queueDir)) {
    If (A_Index==1) {
	FileCreateDir %queueDir%
    } Else {
	MsgBox 16, Ошибка при инициализации отправки, Папка очереди не существует`, и не может быть создана: "%queueDir%"`n`nОтправка невозможна`, обратитесь к системному администратору для устанения проблемы., 30
	ExitApp
    }
}

argc = %0%
If (!argc) {
    MsgBox 64, Отправка выгрузок и подтверждений, Для отправки перетащите файлы на специальный ярлык скрипта. Перетащенные файлы будут отправлены и удалёны!
    Exit 32767
}

Loop %argc%
{
    FileToSend:=%A_Index%
    ;Иногда при перетаскивании в качестве аргумента передаётся путь и имя в формате 8.3. Получается что-то вроде ST_С0_~1.7z
    Loop %FileToSend%
    {
	FileToSend:=A_LoopFileLongPath
	
	SplitPath FileToSend, FileToSendName, , FileToSendExtension, FileToSendNameNoExt

	; Префикс "TS" значит, это выгрузка из центральной базы
	If (SubStr(FileToSendNameNoExt, 1, 3) = "TS_") {	
	    MsgBox 51,Файл не будет отправлен!,Файл: "%FileToSendName%" предназначен для загрузки`, а не отправки.`nКогда-то давно входящие файлы после загрузки в Рарусе надо было перетаскивать на скрипт`, поскольку в офис отправлялись подтверждения. Теперь это неактуально`, и до обновления скрипта в марте 2013`, при обработке этих файлов они тихо и без вопросов удалялись.`n`nЧто делать с этим файлом`, удалить?
	    IfMsgBox Yes
		FileDelete %FileToSend%
	    IfMsgBox Cancel
		Exit
	    Continue
	}

	If (moveFileInsteadOfEmail) {
	    TrayTip Подготовка файла выгрузки к отправке, Перемещение выгрузки напрямую на сервер 1С (без отправки по почте).
	    FileMove %FileToSend%, %queueDir%
	} else {
	    If (!exe7z) {
		MsgBox 22, Ошибка при создании архива для отправки, Выгрузка не отправлена.`nДля создания архива и отправки файла требуется 7-Zip`, но он не найден на компьютере. Зарегистрируйте заявку по этому поводу!`nВременно выгрузки можно пробовать отправлять`, подключившись к офису через VPN.
		Exit 2
	    }

	retryArchiving:
	    Loop {
		lockFileObj := FileOpen(lockfile, "rw-", 0)
		If (!IsObject(lockFileObj)) {
		    TrayTip Подготовка файла выгрузки к отправке, Одновременно активен другой процесс подготовки архива`, ожидание.
		    Sleep 300
		} Else {
		    If (A_Index > 1)
			TrayTip
		    break
		}
	    }
	    
	    TrayTip Подготовка файла выгрузки к отправке, Архивация выгрузки в папку очереди на отправку.
	    Loop
	    {
		fnameArchive = %queueDir%\%A_Now%_%A_Index%.7z
		fnameNote = %queueDir%\%A_Now%_%A_Index%.txt
	    } Until !FileExist(fnameArchive)
	    
	    ; архив создаётся с расширением ".new", чтобы скрипт отправки не начал отправлять его раньше времени
	    RunWait "%exe7z%" a -sdel -- "%fnameArchive%.new" "%FileToSend%",, Min UseErrorLevel
	    error7z := ErrorLevel
	    lockFileObj.Close()
	    
	    If (error7z < 2) {
		;0 No error 
		;1 Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed. 

		; запись исходного имени файла в txt (расположена рядом с архивом)
		FileAppend %FileToSendName%, %fnameNote%, UTF-8
		; переименование архива – после того, как сам архив готов и txt записан
		FileMove %fnameArchive%.new, %fnameArchive%, 1
	    } Else {
		;2 Fatal error 
		;7 Command line error 
		;8 Not enough memory for operation 
		;255 User stopped the process 
		FileDelete %fnameArchive%.new
		MsgBox 22, Ошибка при создании архива для отправки, При попытке создать архив с отправляемым файлом возникла ошибка.`nПри регистрации заявки сообщите код ошибки 7-Zip: %ErrorLevel%
		
		IfMsgBox Cancel
		    Exit
		IfMsgBox TryAgain
		    GoTo retryArchiving
	    }
	    
	    TrayTip
	    ; Запуск в фоновом режиме скрипта доставки
	    Run "%A_AhkPath%" "%A_ScriptDir%\DispatchFiles.ahk" "%fnameArchive%"
	}
    }
}
ExitApp

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
	Try return %findexefunc%(exename, ProgramFiles . "\7-Zip", ProgramFilesx86 . "\7-Zip", SystemDrive . "\Program Files\7-Zip", SystemDrive . "\Arc\7-Zip")
	Try return %findexefunc%("7za.exe", SystemDrive . "\Arc\7-Zip")
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
	Throw exename " not found in " . dir7z
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
