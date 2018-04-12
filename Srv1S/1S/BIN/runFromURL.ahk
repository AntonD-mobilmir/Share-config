#NoEnv

url=%1%
StringMid args, 1, InStr(url, ":")+1

If (args) {
    EnvSet args1s, %args%
    FileAppend %args%`n,%A_Temp%\1stemp\args1s.txt
    TrayTip Запуск 1С по ссылке, Запуск 1С с аргументом %args%, 15, 1
}

RunWait "%A_AhkPath%" "%A_ScriptDir%\run_with_substituted_temp.ahk" ENTERPRISE /SSrv1S.office0.mobilmir:1541\Trade2015
