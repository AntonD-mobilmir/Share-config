#NoEnv
#NoTrayIcon

If %0%  ; For each parameter:
{
    CommandLine := DllCall( "GetCommandLine", "Str" )
    param=%2%
    CmdlArgs:= SubStr(CommandLine, InStr(CommandLine,param,1)-1)
} Else {
    MsgBox Этот скрипт надо запускать минимум с одним аргументом – путем к программе в ProgramFiles (например, "Mozilla Firefox\firefox.exe")
    Exit
}

EnvGet ProgramFiles_default, ProgramFiles
EnvGet ProgramFiles_x86, ProgramFiles(x86)

path1=%ProgramFiles_x86%\%1%
path2=%ProgramFiles_default%\%1%

TryRun(path1) || TryRun(path2) || DisplayError()

TryRun(path) {
    global CmdlArgs
    IfExist %path%
        Loop %path%
            Run "%A_LoopFileLongPath%" %CmdlArgs%, %A_LoopFileDir%
    Else
        return 0
    return !ErrorLevel
}

DisplayError() {
    MsgBox Не удалось найти запускаемую программу. Скорее всего`, она не установлена.
}