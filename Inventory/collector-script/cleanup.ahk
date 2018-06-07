#NoEnv

RunWait %ComSpec% /C "%A_ScriptDir%\Sort.cmd", %A_ScriptDir%, UseErrorLevel Min
RunWait "%A_AhkPath%" /ErrorStdOut "%A_ScriptDir%\..\actual\move_old_duplicates_to_old.ahk", %A_ScriptDir%\..\actual

CreationTimeHorinzon =
CreationTimeHorinzon += -31, Days
ModificationTimeHorinzon =
ModificationTimeHorinzon += -7, Days

Loop %A_ScriptDir%\..\new-unsorted-reports\*
    If ( A_LoopFileTimeModified < ModificationTimeHorinzon || A_LoopFileTimeCreated < CreationTimeHorinzon )
	FileMove %A_LoopFileFullPath%, %A_LoopFileDir%\trash\%A_LoopFileName%
