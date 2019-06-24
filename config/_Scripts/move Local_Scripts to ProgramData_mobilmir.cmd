@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED ProgramData SET "ProgramData=%ALLUSERSPROFILE%\Application Data"
)
(
    RD "%SystemDrive%\Local_Scripts"
    IF EXIST "%SystemDrive%\Local_Scripts" (
	ATTRIB -R -S -H "%SystemDrive%\Local_Scripts" /S /D
	FOR /D %%I IN ("%SystemDrive%\Local_Scripts\*") DO MOVE /Y "%%~I" "%ProgramData%\mobilmir.ru\%%~nxI"
	RD "%SystemDrive%\Local_Scripts"
	MOVE /Y "%SystemDrive%\Local_Scripts" "%ProgramData%\Local_Scripts_old"
    )
    REM "%SystemDrive%\SysUtils\xln.exe" -n "%ProgramData%\mobilmir.ru" "%SystemDrive%\Local_Scripts"
)
