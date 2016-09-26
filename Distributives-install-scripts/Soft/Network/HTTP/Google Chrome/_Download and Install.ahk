#NoEnv

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if ErrorLevel = ERROR
	MsgBox Без прав администратора ничего не выйдет.
    Exit
}

SetWorkingDir %A_ScriptDir%
RunWait %comspec% /C ".Distributives_Update_Run.Office.cmd",%A_ScriptDir%,Min
IfExist *.msi
    Run %A_AhkPath% install.ahk
Else
    MsgBox Дистрибутив не загружен
