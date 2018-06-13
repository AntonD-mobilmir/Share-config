@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
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

EXIT /B
)
:runMsiExec
(
    %SystemRoot%\System32\msiexec.exe %*
    IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( PING 127.0.0.1 -n 30 >NUL & GOTO :runMsiExec ) & rem another install in progress, wait and retry
EXIT /B
)
