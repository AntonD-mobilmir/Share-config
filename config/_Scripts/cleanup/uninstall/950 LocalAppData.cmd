@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

    FOR /D %%I IN ("%SystemDrive%\Users\*") DO (
	CALL :RemoveCheckKill "%%~I\AppData\Local\Programs"
	CALL :RemoveCheckKill "%%~I\AppData\Local\Microsoft\OneDrive"
    )
EXIT /B
)
:RemoveCheckKill <dir> <executable>
(
:RemoveCheckKillLoop
    ECHO Removing "%~1"...
    RD /S /Q "%~1"
    IF EXIST "%~1" (
	FOR /R "%~1" %%A IN (*.*) DO %SystemRoot%\System32\taskkill.exe /F /IM "%%~A"
	PING 127.0.0.1 -n 2 >NUL
	GOTO :RemoveCheckKillLoop
    )
EXIT /B
)
