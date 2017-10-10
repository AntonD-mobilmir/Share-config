@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

%SystemRoot%\System32\reg.exe DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Adobe ARM" /f
%SystemRoot%\System32\reg.exe DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /v "Adobe ARM" /f
%SystemRoot%\System32\reg.exe DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Adobe Reader Speed Launcher" /f
%SystemRoot%\System32\sc.exe STOP AdobeARMservice
%SystemRoot%\System32\sc.exe DELETE AdobeARMservice

REM Hiding desktop shortcut
FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET CommonDesktop=%%B
IF NOT DEFINED CommonDesktop EXIT /B
)
FOR /F "usebackq delims=" %%I IN (`ECHO %CommonDesktop%`) DO SET "CommonDesktop=%%~I"
(
ATTRIB +H "%CommonDesktop%\Adobe Reader*.lnk"
EXIT /B
)
