;Remove old files from %TEMP%
;                                             by logicdaemon@gmail.com
;                                                       logicdaemon.ru
;This script is licensed under LGPL
#NoEnv

CreationTimeHorinzon =
CreationTimeHorinzon += -7, Days
ModificationTimeHorinzon =
ModificationTimeHorinzon += -1, Days

Loop %A_Temp%\*, 0, 1 ; All files first
{
    If ( A_LoopFileTimeModified < ModificationTimeHorinzon || A_LoopFileTimeCreated < CreationTimeHorinzon ) {
	If A_LoopFileAttrib contains R,H,S
	    FileSetAttrib -RHS ; if file omitted, the current file of the innermost enclosing File-Loop will be used instead

	FileAppend Deleting %A_LoopFileFullPath%, *
	FileDelete %A_LoopFileFullPath%
	FileAppend %A_Tab%[%ERRORLEVEL%]`n, *
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
    FileAppend RemovingEmptyDir %A_LoopFileFullPath%, *
    FileRemoveDir %A_LoopFileFullPath%
    FileAppend %A_Tab%[%ERRORLEVEL%]`n, *
}

;    attrib -R *.* /S /D
;    "%UnxUt%find.exe" . -mindepth 1 -atime +7 -type f -or -ctime +31 -type f -exec %comspec% /C DEL /F """{}""" ;
;    "%UnxUt%find.exe" . -type d -mindepth 1 -exec %comspec% /C RD """{}""" ;
