;Remove old files
;                                             by logicdaemon@gmail.com
;                                                       logicdaemon.ru
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
;CC BY-SA 4.0 <http://creativecommons.org/licenses/by-sa/4.0/>
#NoEnv

CreationTimeHorinzon =
CreationTimeHorinzon += -31, Days
ModificationTimeHorinzon =
ModificationTimeHorinzon += -7, Days

EnvGet SUScriptsOldLogs,SUScriptsOldLogs

Loop %SUScriptsOldLogs%\*, 0, 1 ; All files first
{
    If ( A_LoopFileTimeModified < ModificationTimeHorinzon || A_LoopFileTimeCreated < CreationTimeHorinzon ) {
	If A_LoopFileAttrib contains R,H,S
	    FileSetAttrib -RHS ; if file omitted, the current file of the innermost enclosing File-Loop will be used instead
	
	FileDelete %A_LoopFileFullPath%
    }
}

Loop %SUScriptsOldLogs%\*, 2, 1 ; Then all directories
    FileRemoveDir %A_LoopFileFullPath%
