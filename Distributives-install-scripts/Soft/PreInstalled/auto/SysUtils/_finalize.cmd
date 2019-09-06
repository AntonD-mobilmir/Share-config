@(REM coding:CP866
REM part of script-set to install preinstalled and working-without-install software
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

    IF DEFINED pathString (
	%AutohotkeyExe% "%utilsdir%pathman.ahk" /as "%pathString%"
	CALL :FilterPaths
	IF DEFINED filteredPathString CALL :AddEnvPath
    )
EXIT /B
)
:AddEnvPath
(
SET "PATH=%PATH%;%filteredPathString%"
EXIT /B
)
:FilterPaths
(
    FOR /F "delims=; tokens=1*" %%A IN ("%pathString%") DO (
	SET "pathString=%%~B"
	IF EXIST "%%~A" CALL :CheckInPathAlready "%%~A" && SET "filteredPathString=%filteredPathString%;%%~A"
    )
    IF DEFINED pathString GOTO :FilterPaths
    EXIT /B
)
:CheckInPathAlready
(
    SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    IF "%PATH%;"=="!PATH:%~1;=!" EXIT /B 0
    EXIT /B 1
)
