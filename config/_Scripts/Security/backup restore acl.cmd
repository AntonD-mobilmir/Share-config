@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe "%SystemDrive%\SysUtils\SetACL.exe"
    IF NOT DEFINED SetACLexe (
	ECHO SetACL.exe не найден, продолжение невозможно.
	EXIT /B 2
    )
    
    IF "%~2"=="" CALL :restoreACL "" %1 & EXIT /B
    IF "%~1"=="/R" GOTO :restoreACL
    IF "%~1"=="-" GOTO :restoreACL
    IF "%~1"=="" GOTO :restoreACL
)
:backupACL <path> <backup>
(
    ECHO %DATE% %TIME% Сохранение резервной копии ACL для %1
    %SetACLexe% -on %1 -ot file -rec cont_obj -actn list -lst "f:sddl;w:d,o,g" -bckp "%~2.tmp" -ignoreerr||EXIT /B
    REN "%~2.tmp" "*."||EXIT /B
    START "Compacting %~nx2" /MIN /LOW %comspec% /C "%SystemRoot%\System32\COMPACT.exe /C /F /EXE:LZX %2 || %SystemRoot%\System32\COMPACT.exe /C %2"
    EXIT /B 0
)
:restoreACL <backup>
(
    ECHO %DATE% %TIME% Восстановление сохранённых ACL из %2
    %SetACLexe% -on "%TEMP%\NUL" -ot file -actn restore -bckp %2 -ignoreerr
    EXIT /B
)
