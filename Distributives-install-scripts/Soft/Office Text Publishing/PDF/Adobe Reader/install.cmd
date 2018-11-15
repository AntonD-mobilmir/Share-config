@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED exe7z CALL :RunFromConfig "_Scripts\find7zexe.cmd" || CALL :SetFirstExistingExe exe7z "%~dp0..\..\PreInstalled\utils\7za.exe" || EXIT /B
    
    SET "unpackDst=%TEMP%\AcroReadDC-%~n0.tmp"
    IF NOT DEFINED logmsi SET "logmsi=%TEMP%\AcroReadDC-%~n0.log"
)
(
    %exe7z% x -aoa -y -o"%unpackDst%.tmp" -- "%~dp0AcroReadDC.7z"
    RD /S /Q "%unpackDst%"
    MOVE /Y "%unpackDst%.tmp" "%unpackDst%"
    FOR %%A IN ("%unpackDst%\*.mst") DO SET MSITransformSwitch=/t"%%~A"
)
:retrymsiexec
(
    %SystemRoot%\System32\msiexec.exe /i "%unpackDst%\AcroRead.msi" %MSITransformSwitch% /qn /norestart /l+* "%logmsi%"
    IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( PING 127.0.0.1 -n 30 >NUL & GOTO :retrymsiexec ) & rem another install in progress, wait and retry
    
    CALL "%~dp0install_updates.cmd"
    RD /S /Q "%unpackDst%"
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
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
(
    CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
