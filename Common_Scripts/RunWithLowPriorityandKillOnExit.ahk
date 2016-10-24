;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon

CommandLine := DllCall( "GetCommandLine", "Str" )
CmdlArgs:= SubStr(CommandLine, InStr(CommandLine,A_ScriptName,1)+StrLen(A_ScriptName)+2)

OnExit KillOnExit

Run %CmdlArgs%,,, aPID
Process Priority, %aPID%, L
Process WaitClose, %aPID%

KillOnExit:
Process Close, %aPID%
