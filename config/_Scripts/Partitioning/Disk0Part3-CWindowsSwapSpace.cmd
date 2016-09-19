@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET tmpscript="%TEMP%\%~n0%RANDOM%.dps"

MKDIR %SystemRoot%\SwapSpace

ECHO SELECT DISK ^0>>%tmpscript%
ECHO SELECT PART ^3>>%tmpscript%
ECHO ASSIGN MOUNT=%SystemRoot%\SwapSpace>>%tmpscript%
diskpart /s %tmpscript%
DEL %tmpscript%
CHKDSK C:\Windows\SwapSpace /L:2048
ECHO Any key to re-assign swapspace
PAUSE
CALL "%~dp0..\pagefile_on_Windows_SwapSpace.cmd"
PAUSE
