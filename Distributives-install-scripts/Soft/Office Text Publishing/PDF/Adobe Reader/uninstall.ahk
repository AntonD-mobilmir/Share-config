#NoEnv

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    ExitApp %ERRORLEVEL%
}

RunWait "%A_WinDir%\System32\MsiExec.exe" /X{AC76BA86-7AD7-1049-7B44-AB0000000001} /qn
