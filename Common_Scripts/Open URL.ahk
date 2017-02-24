;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

argc=%0%
sw1=%1%
If (sw1="/assoc") {
    If (A_IsAdmin) {
	Assoc()
    } Else {
	RestartAsAdmin()
    }
    ExitApp
}

If (argc) {
    Loop %argc%
    {
	path:=%A_Index%
	IniRead URL, %path%, InternetShortcut, URL, %A_Space%
	Run %URL%
    }
} Else {
    MsgBox 0x4, %A_ScriptName%, Этот скрипт считывает и открывает адрес из файла .url. Нужен`, чтобы открывать файл .url через Chrome (см. <https://bugs.chromium.org/p/chromium/issues/detail?id=114871>).`n`nСвязать скрипт с файлами .url?
    IfMsgBox Yes
	RestartAsAdmin()
}

ExitApp

RestartAsAdmin(text:="%A_SciptName%: Для связывания с файлами .url требуются права администратора.") {
    ToolTip %text%
    Run % "*RunAs " . DllCall( "GetCommandLine", "Str" ) . " /assoc",,UseErrorLevel  ; Requires v1.0.92.01+
    If (ErrorLevel)
	MsgBox %text%
    return !ErrorLevel
}

Assoc() {
    RunWait %comspec% /C "FTYPE OpenURLahk="%A_AhkPath%" "%A_ScriptFullPath%" "`%1"",,Min
    RunWait %comspec% /C "ASSOC .url=OpenURLahk"
}
