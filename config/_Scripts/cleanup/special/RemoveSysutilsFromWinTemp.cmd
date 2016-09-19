@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
)
:RemoveSysutilsFromWinTemp
(
    FOR /D %%A IN ("%SystemDrive%\Windows\Temp\SysUtils_*") DO RD /S /Q "%%~A"
    IF EXIST "%SystemDrive%\Windows\Temp\SysUtils_*" (
	ECHO Не удалось удалить все остатки SysUtils из %SystemDrive%\Windows\Temp. Ожидание 30 сек. перед повторной попыткой.
	PING 127.0.0.1 -n 30 >NUL
	GOTO :RemoveSysutilsFromWinTemp
    )
EXIT /B
)
