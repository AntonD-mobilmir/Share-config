@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
)

START "" /B /WAIT /D"%srcpath%" c:\SysUtils\curl.exe -LRO https://github.com/tatsuhiro-t/aria2/releases/download/release-1.19.2/aria2-1.19.2-win-32bit-build1.zip
START "" /B /WAIT /D"%srcpath%" c:\SysUtils\curl.exe -LRO https://github.com/tatsuhiro-t/aria2/releases/download/release-1.19.2/aria2-1.19.2-win-64bit-build1.zip
