@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED exe7z CALL :RunFromConfig "_Scripts\find7zexe.cmd" || CALL :SetFirstExistingExe exe7z "%~dp0..\..\PreInstalled\utils\7za.exe" || EXIT /B
    
    IF NOT DEFINED unpackDst SET "unpackDst=%TEMP%\AcroReadDC-%~n0.tmp"
    IF NOT DEFINED logmsi SET "logmsi=%TEMP%\AcroReadDC-%~n0.log"
)
(
    IF NOT EXIST "%unpackDst%\*.mst" %exe7z% x -aoa -y -o"%unpackDst%" -- "%~dp0AcroReadDC.7z" *.mst
    FOR %%A IN ("%unpackDst%\*.mst") DO SET MSITransformSwitch=/t"%%~A"
    
    FOR %%A IN ("%~dp0Updates\*.7z") DO %exe7z% x -aoa -y -o"%unpackDst%" -- "%%~A"
)
(
    rem Two pass to ensure security updates installed after common ones
    FOR %%I IN ("%unpackDst%\*.msp" "%~dp0updates\*.msp" "%unpackDst%\AdbeRdrSec*.msp" "%~dp0updates\AdbeRdrSec*.msp") DO CALL :runMsiExec /update "%%~I" %MSITransformSwitch% /qn /norestart /l+* "%logmsi%"

    RD /S /Q "%unpackDst%"
    CALL "%~dp0RemoveUnneededAutorunAndServices.cmd"
EXIT /B
)
:runMsiExec
(
    %SystemRoot%\System32\msiexec.exe %*
    IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( PING 127.0.0.1 -n 30 >NUL & GOTO :runMsiExec ) & rem another install in progress, wait and retry
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
