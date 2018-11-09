@(REM coding:CP866
rem https://trello.com/c/Y6uaH2WB/5-активация-windows-создание-образа-системы
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    rem после cls было:
    rem 	cscript.exe %windir%\System32\slmgr.vbs /ato &
    rem но это вызывает двойную активацию на Win10
    SET "key=%~1"
    IF NOT DEFINED key IF NOT "%RunInteractiveInstalls%"=="0" SET /P "key=Ключ: "
    IF NOT DEFINED ErrorCmd (
	IF "%RunInteractiveInstalls%"=="0" (
	    SET "ErrorCmd=ping -n 30 127.0.0.1 >nul"
	) ELSE SET "ErrorCmd=(ECHO &PAUSE)"
    )
)
(
%SystemRoot%\System32\cscript.exe %windir%\System32\slmgr.vbs /ipk "%key%" || %ErrorCmd%
IF NOT ERRORLEVEL 1 CLS & %SystemRoot%\System32\cscript.exe %windir%\System32\slmgr.vbs /cpky || %ErrorCmd%
EXIT /B
)
