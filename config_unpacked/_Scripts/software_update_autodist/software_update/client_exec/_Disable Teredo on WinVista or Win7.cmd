@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

REM if Win8 or higher, don't proceed
CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6.3 && EXIT /B
REM if below Win7, don't proceed
CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6 || EXIT /B

%SystemRoot%\System32\netsh.exe interface ipv6 set teredo disable
%SystemRoot%\System32\netsh.exe interface teredo set state disable
)
