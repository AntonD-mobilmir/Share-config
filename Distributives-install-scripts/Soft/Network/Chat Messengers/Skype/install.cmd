@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

REM ffs!
REM https://answers.microsoft.com/en-us/skype/forum/all/installing-skype-825-silently-without-being-opened/1ff0a52c-39ef-457f-b9f1-31714f642410?auth=1

    MKDIR "%TEMP%\Skype-install"
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%~dp0Skype-8.*.exe"`) DO (
        SET dist="%~dp0%%~A"
        GOTO :install
    )
)
:install
(
    %SystemRoot%\System32\taskkill.exe /F /IM Skype.exe
    %dist% /VERYSILENT /SP- /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /NOLAUNCH || EXIT /B
    REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Skype for Desktop" /F
    FOR %%A IN (2 3 5) DO (
        %SystemRoot%\System32\PING.exe 127.0.0.1 -n %%A >NUL
        %SystemRoot%\System32\taskkill.exe /F /IM Skype.exe
    )
    RD /S /Q "%TEMP%\Skype-install"
    RD /S /Q "%APPDATA%\Skype for Desktop"

    REM Hiding desktop shortcut
    FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET CommonDesktop=%%B
        IF NOT DEFINED CommonDesktop EXIT /B
    )
    FOR /F "usebackq delims=" %%I IN (`ECHO %CommonDesktop%`) DO ATTRIB +H "%%~I\Skype.lnk"
    EXIT /B 0
)
