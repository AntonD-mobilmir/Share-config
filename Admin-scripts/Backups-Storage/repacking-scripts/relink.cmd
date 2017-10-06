@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET "dst=%~2"
IF NOT DEFINED dst SET "dst=%~dp0"
)
IF "%dst:~-1%"=="\" SET "dst=%dst:~0,-1%"
(
FOR /D %%A IN (%1) DO ln.exe -r "%%~A" "%dst%\%%~nxA"
FOR %%A IN (%1) DO ln.exe "%%~A" "%dst%\%%~nxA"
)
