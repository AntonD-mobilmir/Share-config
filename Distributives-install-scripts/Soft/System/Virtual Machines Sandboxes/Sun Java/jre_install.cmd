@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

rem     IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
rem     IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"

rem     IF DEFINED OS64Bit (
rem 	CALL "%~dp0jre9_install.cmd"
rem     ) ELSE (
	SET "installjre64bit=1"
	CALL "%~dp0jre8_install.cmd"
rem     )
)
