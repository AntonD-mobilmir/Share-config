;Remove old files from %TEMP%
;                                             by logicdaemon@gmail.com
;                                                       logicdaemon.ru
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

CreationTimeHorinzon =
CreationTimeHorinzon += -31, Days
ModificationTimeHorinzon =
ModificationTimeHorinzon += -7, Days

Loop %A_Temp%\*, 0, 1 ; All files first
{
    If ( A_LoopFileTimeModified < ModificationTimeHorinzon || A_LoopFileTimeCreated < CreationTimeHorinzon ) {
	If A_LoopFileAttrib contains R,H,S
	    FileSetAttrib -RHS ; if file omitted, the current file of the innermost enclosing File-Loop will be used instead
	
	FileDelete %A_LoopFileFullPath%
    }
}

Loop %A_Temp%\*, 2, 1 ; Then all directories
{
    If ( A_LoopFileTimeModified < ModificationTimeHorinzon || A_LoopFileTimeCreated < CreationTimeHorinzon ) {
	FileRemoveDir %A_LoopFileFullPath%, 1
    }
    
    Loop %A_LoopFileFullPath% ; Are there any files
    {
	continue ; At lest one file found, don't remove this dir, cont with next
    }
    ; No files found, dir is empty
    FileRemoveDir %A_LoopFileFullPath%
}

;    attrib -R *.* /S /D
;    "%UnxUt%find.exe" . -mindepth 1 -atime +7 -type f -or -ctime +31 -type f -exec %comspec% /C DEL /F """{}""" ;
;    "%UnxUt%find.exe" . -type d -mindepth 1 -exec %comspec% /C RD """{}""" ;
