#NoEnv

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if ErrorLevel = ERROR
	MsgBox Без прав администратора ничего не выйдет.
    Exit
}

EnvGet logmsi,logmsi
If Not logmsi
    logmsi=%A_Temp%\Intelloware Quick Config install.log
RunWait msiexec.exe /i "%A_ScriptDir%\QuickConfig.msi" /q /norestart /l+* "%logmsi%"
