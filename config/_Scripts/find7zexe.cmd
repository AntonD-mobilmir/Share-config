@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
)

:find7zexe
(
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString"`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    
    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"

    CALL "%~dp0find_exe.cmd" exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe"
    IF ERRORLEVEL 1 IF DEFINED OS64Bit CALL "%~dp0find_exe.cmd" exe7z 7za64.exe
    IF ERRORLEVEL 1 CALL "%~dp0find_exe.cmd" exe7z 7za.exe || (ECHO  & EXIT /B 9009)
EXIT /B
)
:checkDirFrom1stArg <arg1> <anything else>
(
    CALL :Check7zDir "%~dp1"
EXIT /B
)
:Check7zDir <dir>
    IF NOT "%~1"=="" SET "dir7z=%~1"
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
(
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" <NUL >NUL 2>&1 || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B
)
