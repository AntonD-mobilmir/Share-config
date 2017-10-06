@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED logfile SET logfile="%~dp0..\logs\%~n0.log"
)
(
START "" /D "%srcpath:~,-1%" /B /WAIT "c:\SysUtils\DFHL.exe" /r /l . >%logfile%
"%WinDir%\System32\compact.exe" /c /s:"%srcpath:~,-1%" /exe:lzx /i *.xls *.doc *.ppt *.eml *.mbx *.log >>%logfile%
)
