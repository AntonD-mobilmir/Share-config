#NoEnv

RunWait %ComSpec% /C "%A_ScriptDir%\Sort.cmd", %A_ScriptDir%, UseErrorLevel Min
RunWait "%A_AhkPath%" /ErrorStdOut move_old_duplicates_to_old.ahk, \\Srv0\profiles$\Share\Inventory\actual

CreationTimeHorinzon =
CreationTimeHorinzon += -31, Days
ModificationTimeHorinzon =
ModificationTimeHorinzon += -7, Days

Loop %A_ScriptDir%\Reports\*
    If ( A_LoopFileTimeModified < ModificationTimeHorinzon || A_LoopFileTimeCreated < CreationTimeHorinzon )
	FileMove %A_LoopFileFullPath%, %A_LoopFileDir%\trash\%A_LoopFileName%
;	FileDelete %A_LoopFileFullPath%
