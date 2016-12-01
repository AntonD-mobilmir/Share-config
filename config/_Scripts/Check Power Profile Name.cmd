@(REM coding:CP866
@REM Проверка текущего профиля энергосбережения
@REM первая строка выглядит так:
@REM Power Scheme GUID: 7778a9ae-6781-413b-ad56-e724825e2c92  ^(My Custom Plan 1^)
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
)

FOR /F "usebackq delims=() tokens=2" %%A IN (`%SystemRoot%\System32\powercfg.exe /Q`) DO (
    IF /I "%%A"==%1 EXIT /B 1
    EXIT /B 0
)
