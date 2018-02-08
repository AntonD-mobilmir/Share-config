@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

    CALL "%~dp0assoc_csvtsv_with_LO.cmd"
    IF NOT DEFINED configDir CALL :findConfigDir
    IF NOT DEFINED DefaultsSource EXIT /B 1
)
(
    IF NOT DEFINED exe7z CALL "%configDir%_Scripts\find7zexe.cmd"
rem     IF NOT DEFINED SetACLexe CALL "%configDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
    IF NOT DEFINED AutohotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
)
(
    %AutohotkeyExe% "%~dp0LibreOfficeCreateBackupDirs.ahk"
    FOR /F "usebackq delims=" %%A IN (`%AutohotkeyExe% "%~dp0Find_LO_program_dir.ahk"`) DO SET "dirLO=%%~dpA"
    IF NOT DEFINED dirLO FOR %%A IN ("%ProgramFiles%" "%ProgramFiles(x86%") DO FOR /D %%B IN ("%%~A\LibreOffice*") DO IF EXIST "%%~B\program\soffice.bin" SET "dirLO=%%~B\"
    )
    IF NOT DEFINED dirLO EXIT /B 1
)
CALL :GetName nameLO "%dirLO:~0,-1%"
(
    %exe7z% x -aoa -y "%DefaultsSource%" "%nameLO%" -o"%dirLO%..\"
EXIT /B
)
:findConfigDir
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
:GetName
(
    SET "%~1=%~nx2"
EXIT /B
)
