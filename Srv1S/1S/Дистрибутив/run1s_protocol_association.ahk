#NoEnv
#NoTrayIcon

global configFile := A_ScriptDir . "\" . A_ScriptName . "-executable.cfg"
global Proto      := "run1s"

arg=%1%
If (SubStr(arg, 1, 6) == (Proto . ":")) {
    CheckRun(A_ScriptDir . "\..\BIN\runFromURL.ahk")
    || CheckRun(configFile)
    || CheckRun("\\Srv1S.office0.mobilmir\1S\BIN\runFromURL.ahk")
    || MsgBox Не удалось найти скрипт запуска URL
} Else {
    ; wrong arguments or no arguments
    If (arg="" || FileExist(arg))
	Install(arg)
    Else 
	MsgBox Этот скрипт используется для установки и запуска обработчика протокола %Proto%://`nВ качестве аргумента должен передаваться URI с этим протоколом.
}
    
Install(runFromURL="") {
    Menu Tray, Icon
    If (A_ComputerName="Srv1S") {
	urlHandler := A_ScriptFullPath
    } Else {
	VarSetCapacity(LocalAppData,(A_IsUnicode ? 2 : 1)*1025) 
	r:=DllCall("Shell32\SHGetFolderPath", "int", 0 , "uint", 28 , "int", 0 , "uint", 0 , "str" , LocalAppData)
	If (r or ErrorLevel)
	    LocalAppData=%A_AppData%\..\Local

	FileCreateDir %LocalAppData%\1C
	urlHandler := LocalAppData . "\1C\" . A_ScriptName
	configFile := LocalAppData . "\1C\" . A_ScriptName . "-executable.cfg"
	FileCopy %A_ScriptFullPath%, %urlHandler%, 1
    }
    
    If (runFromURL && configFile) {
	FileDelete %configFile%
	FileAppend %runFromURL%,%configFile%
    }
    
    ;https://msdn.microsoft.com/en-us/library/aa767914(v=vs.85).aspx
    RegWrite REG_SZ, HKEY_CURRENT_USER\Software\Classes\%Proto% ,, URL:%Proto% Protocol
    RegWrite REG_SZ, HKEY_CURRENT_USER\Software\Classes\%Proto% ,URL Protocol ,
    RegWrite REG_SZ, HKEY_CURRENT_USER\Software\Classes\%Proto%\shell\open\command ,, "%A_AhkPath%" "%urlHandler%" "`%l"
    
    TrayTip,, Протокол установлен:`n"%A_AhkPath%" "%urlHandler%" "`%l"
    Sleep 3000
}

CheckRun(path, recur=0) {
    Loop Files, %path%
    {
	If (A_LoopFileExt="ahk") {
	    Run "%A_AhkPath%" "%A_LoopFileLongPath%" "%1%", %A_LoopFileDir%, UseErrorLevel
	    return UseErrorLevel != "ERROR"
	} Else {
	    If (recur>2) {
		MsgBox Ошибка в конфигурации`, превышен предел количества ссылок на другие файлы конфигурации.`n`nПоследний прочитанный файл: %path%.
		ExitApp
	    }
	    Loop Read, %A_LoopFileLongPath%
		If (r := CheckRun(A_LoopReadLine, recur+1))
		    return r
	}
    }
    return 0
}
