@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
%SystemRoot%\System32\taskkill.exe /F /IM Skype.exe

rem Skype 4.2.169
CALL :runMsiExec /X{D103C4BA-F905-437A-8049-DB24763BBE36} /quiet /norestart

rem Skype 5.1
CALL :runMsiExec /X{9C538746-C2DC-40FC-B1FB-D4EA7966ABEB} /quiet /norestart
rem Skype 5.3
CALL :runMsiExec /X{F1CECE09-7CBE-4E98-B435-DA87CDA86167} /quiet /norestart

rem user Skype installations
CALL :runMsiExec /X{F1CECE09-7CBE-4E98-B435-DA87CDA86167} /quiet /norestart

rem Skype Business (msi distributive)
CALL :runMsiExec /X{1845470B-EB14-4ABC-835B-E36C693DC07D} /quiet /norestart

rem Skype 8
rem "C:\Program Files (x86)\Microsoft\Skype for Desktop\unins000.exe" /SILENT
FOR %%A IN ("%ProgramFiles(x86)%" "%ProgramFiles%") DO IF NOT "%%~A"=="" FOR %%B IN ("%%~A\Microsoft\Skype for Desktop\unins*.exe") DO "%%~B" /SILENT

FOR %%I IN (1 2 3 4 5 6 7 8 9) DO FOR /F "usebackq skip=2 tokens=1,2* delims=	 " %%A IN (`%SystemRoot%\System32\REG.exe QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Skype_is%%I" /v "QuietUninstallString" /REG:32`) DO (
    REM IF /I "%%~B"=="REG_SZ"
    IF /I "%%~A"=="QuietUninstallString" %%C
)

EXIT /B
)
:runMsiExec
(
    %SystemRoot%\System32\msiexec.exe %*
    IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( PING 127.0.0.1 -n 30 >NUL & GOTO :runMsiExec ) & rem another install in progress, wait and retry
EXIT /B
)
