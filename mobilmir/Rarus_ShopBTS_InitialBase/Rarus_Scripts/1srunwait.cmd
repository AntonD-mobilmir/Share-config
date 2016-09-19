@REM coding:OEM

CALL "%ProgramData%\mobilmir.ru\_rarus_backup_get_files.cmd" || CALL "%SystemDrive%\Local_Scripts\_rarus_backup_get_files.cmd"
START "" "%~dp01srunwait.ahk" %*
