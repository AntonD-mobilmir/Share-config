@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    IF DEFINED OS64Bit ( SET "smartctlexe=smartctl-64.exe" ) ELSE ( SET "smartctlexe=smartctl-32.exe" )
    IF NOT DEFINED exe7z CALL :RunFromConfig "_Scripts\find7zexe.cmd" || CALL :SetFirstExistingExe exe7z "%~dp0..\..\PreInstalled\utils\7za.exe" || EXIT /B
    SET "binDir=%TEMP%\%~n0\bin"
    CALL :EnsureNotInWindowsDir "%~dp0" || PUSHD "%TEMP%\%~n0" || EXIT /B
)
(
    %exe7z% x -o"%binDir%" -- "%~dp0bin.7z" "%smartctlexe%"
    FOR /F "usebackq tokens=1" %%I IN (`"%binDir%\%smartctlexe%" --scan`) DO "%binDir%\%smartctlexe%" -s on -x %%I >"%%~nI-smart.txt" 2>"%%~nI-smart.log" & CALL :RemoveIfEmpty "%%~nI-smart.log"
    DEL "%binDir%\%smartctlexe%"
    RD "%binDir%"
EXIT /B
)
:RunFromConfig
IF NOT DEFINED configDir CALL :findconfigDir
(
    IF "%~x1"==".cmd" (
        CALL "%configDir%"%*
    ) ELSE "%configDir%"%*
    EXIT /B
)
:SetFirstExistingExe <varname> <path1> <path2> <...>
(
    IF EXIST %2 (
        SET %1=%2
        EXIT /B
    )
    IF "%~3"=="" EXIT /B 1
    SHIFT /2
    GOTO :SetFirstExistingExe
)
:findconfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
(
    CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
:EnsureNotInWindowsDir
    SET "checkDir=%~dp1"
    SET "checkDir=%checkDir:~0,-1%"
(
    IF "%~1"=="%checkDir%" EXIT /B 0
    IF /I "%checkDir%"=="%SystemRoot%" EXIT /B 1
    CALL :EnsureNotInWindowsDir "%checkDir%"
EXIT /B
)
:RemoveIfEmpty
(
    FOR %%A IN (%1) DO IF "%%~zA"=="0" DEL "%%~A"
    EXIT /B
)
