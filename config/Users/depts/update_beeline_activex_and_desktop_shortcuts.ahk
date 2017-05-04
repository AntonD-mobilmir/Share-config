;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

global childPID
OnExit("KillChild")

FileGetTime origOcxDate, d:\dealer.beeline.ru\bin\criacx.ocx
If (A_IsAdmin) {
    ;Запущено с правами админстратора
    pathSrvConfigUpdater:="\\Srv0.office0.mobilmir\profiles$\Share\config\update local config.cmd"

    If (!FileExist(pathSrvConfigUpdater)) {
	Exit 4
    }

    global DefaultConfigDir := getDefaultConfigDir()

    SplitPath pathSrvConfigUpdater, fnameConfigUpdater
    pathLocConfigUpdater=%DefaultConfigDir%\%fnameConfigUpdater%

    FileGetTime srvConfigUpdaterMtime, %pathSrvConfigUpdater%
    FileGetTime locConfigUpdaterMtime, %pathLocConfigUpdater%

    If (locConfigUpdaterMtime == srvConfigUpdaterMtime) {
	runConfUpdScript:= pathLocConfigUpdater
    } Else {
	runConfUpdScript := pathSrvConfigUpdater
    }

    ; Обновление локальной конфигурации
    RunWait %comspec% /C "%runConfUpdScript%",,Min UseErrorLevel, childPID

    ; Замена ярлыков и распаковка D:\dealer.beeline.ru
    RunWait %comspec% /C ""%DefaultConfigDir%\_Scripts\unpack_retail_files_and_desktop_shortcuts.cmd"", %DefaultConfigDir%\_Scripts, Min UseErrorLevel, childPID
    FileDelete %A_DesktopCommon%\Exchange.lnk
    FileDelete %A_DesktopCommon%\Ценники из выгрузок Рарус.lnk
} Else {
    comment := "Без прав администратора"
    ; Запущено из под пользователя без прав администратора
    ; config обновить не получится
    ; Минимальный вариант с распаковкой ocx с сервера и заменой в bin
    exe7z := find7zGUIorAny()
    If (!exe7z)
	Throw Exception("Не найден 7-Zip.")
    RunWait "%exe7z%" x -aoa -o"D:\" -- "%A_ScriptDir%\D.7z" dealer.beeline.ru
    FileCopyDir %A_ScriptDir%\D\dealer.beeline.ru, D:\dealer.beeline.ru, 1

}
; Обновление criacx.ocx
RunWait %comspec% /C "d:\dealer.beeline.ru\update_dealer_beeline_activex.cmd" /Unpack, d:\dealer.beeline.ru, Min UseErrorLevel,childPID
If (ErrorLevel)
    comment .= ", ErrorLevel:" . errFinal

FileGetTime newOcxDate, d:\dealer.beeline.ru\bin\criacx.ocx

diffOcxTime := newOcxDate
diffOcxTime -= origOcxDate, Days

If (diffOcxTime)
    comment .= ", timeDiff: " . diffOcxTime

PostGoogleForm("https://docs.google.com/a/mobilmir.ru/forms/d/e/1FAIpQLSeRvIBRHnVjhnUS09Dh7lNEoXtTRjkY9210stwJhftwqQ8tgg/formResponse"
		, {   "entry.1266830572": GetDeptID()
		    , "entry.298209335": A_ComputerName
		    , "entry.411109659": A_UserName
		    , "entry.831594180": newOcxDate
		    , "entry.352111625": Trim(comment, ",`t ")})

Exit diffOcxTime!=0

KillChild() {
    If (childPID)
	Run %A_Windir%\System32\TASKKILL.exe /PID %childPID% /T /F
    return
}

#include %A_LineFile%\..\..\..\_Scripts\Lib\getDefaultConfig.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\find7zexe.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\PostGoogleForm.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\GetDeptID.ahk
