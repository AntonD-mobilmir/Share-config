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
    SET out="%Temp%\acl-list-%RANDOM%.csv"
)
%SetACLexe% -ot file -on %1 -rec cont_obj -actn list -lst "f:csv;w:d,o,g;s:n" -bckp %out%
START "" %out%
