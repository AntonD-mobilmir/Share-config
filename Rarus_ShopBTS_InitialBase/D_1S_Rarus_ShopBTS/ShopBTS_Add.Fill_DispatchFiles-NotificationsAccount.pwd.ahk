;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding CP1251

cfgTemplatePath=d:\1S\Rarus\ShopBTS\ExtForms\post\DispatchFiles-NotificationsAccount.pwd.template
cfgDestPath=d:\1S\Rarus\ShopBTS\ExtForms\post\DispatchFiles-NotificationsAccount.pwd

accCfgListPaths := ["\\IT-Head.office0.mobilmir\d$\Users\LogicDaemon\Google Drive\IT\Ограниченный доступ\Аккаунты почтовых ящиков для 1С-Рарус\rarus.robots.mobilmir.ru.txt"]

Try {
    rarusnotifCfg := {}
    cfgTemplate := []
    If (!FileExist(cfgTemplatePath))
	RunWait "%A_AhkPath%" "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\D_1S_Rarus_ShopBTS\ShopBTS_Add.install.ahk" /skipSchedule
    Loop Read, %cfgTemplatePath%
	cfgTemplate.Push(A_LoopReadLine)

    If (FileExist(cfgDestPath)) {
	rarusnotifOldcfg := []
	;currentConfigFieldNames := ["server", "login", "password"]
	Loop Read, % rarusnotifOldcfgFile.path
	    rarusnotifOldcfg.Push(A_LoopReadLine)
	If (rarusnotifOldcfg[1] == cfgTemplate[1]) ; сервер тот же, что и в шаблоне
	    rarusnotifCfg.login := SubStr(rarusnotifOldcfg[2], 1, InStr(rarusnotifOldcfg[2], "@")-1)
    }
    If (!rarusnotifCfg.login) ; либо @ нет, либо сервер не тот
	rarusnotifCfg.login := SubStr(A_ComputerName, 1, InStr(A_ComputerName, "-") - 1)
    
    For i, accCfgListPath in accCfgListPaths
	Try {
	    FileRead allPass, %accCfgListPath%
	    break
	}
    If (allPass) {
	Loop Parse, allPass, `n, `r
	{
	    found:=""
	    Loop Parse, A_LoopField, `t
	    {
		If (A_Index==1) {
		    If (found := A_LoopField = rarusnotifCfg.login)
			rarusnotifCfg.login := A_LoopField
		} Else If (A_Index==2 && found) {
		    rarusnotifCfg.pass := A_LoopField
		    break
		} Else
		    break
	    }
	    
	    If (found)
		break
	}
	
	If (found) {
	    If (FileExist(cfgDestPath)) {
		MsgBox 0x24, Настройки отправки уведомлений из 1С-Рарус, % "Перезаписать конфигурацию?`nСервер: " cfgTemplate[1] "`nЛогин: " rarusnotifCfg.login " → " cfgTemplate[2], 30
		IfMsgBox No
		    ExitApp
	    }
	    cfgFO := FileOpen(cfgDestPath, "w")
	    For i, tmpltLine in cfgTemplate {
		While (mts := RegexMatch(tmpltLine, "{(\w+)}", mtc) && A_Index < 10)
		    tmpltLine := SubStr(tmpltLine, 1, mts-1) . rarusnotifCfg[mtc1] . SubStr(tmpltLine, mts+StrLen(mtc))
		cfgFO.WriteLine(tmpltLine)
	    }
	    cfgFO.Close()
	} Else {
	    Throw Exception("Логин не найден в файле учетных записей",,rarusnotifCfg.login)
	}
    } Else Throw Exception("Данные аккаунтов не прочитались",,accCfgListPath)
} Catch e {
    Throw e
}
