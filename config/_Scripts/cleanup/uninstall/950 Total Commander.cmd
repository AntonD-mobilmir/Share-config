@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
(
    FOR %%A IN ("%ProgramFiles32%" "%ProgramFiles64%") DO CALL :RemoveCheckKill "%%~A\Total Commander" totalcmd.exe
    FOR /D %%I IN (%SystemDrive%\Users\*) DO (
	CALL :RemoveCheckKill "%%~I\Program Files\Total Commander" totalcmd.exe
	CALL :RemoveCheckKill "%%~I\AppData\Local\Programs\Total Commander" totalcmd.exe
    )
    EXIT /B
)
:RemoveCheckKill <dir> <executable>
(
    RD /S /Q "%~1"
    IF EXIST "%~1" (
	%SystemRoot%\System32\taskkill.exe /F /IM %2
	PING 127.0.0.1 -n 5 >NUL
	
	IF DEFINED Repeated FOR /R %1 %%A IN (*.*) DO %SystemRoot%\System32\taskkill.exe /F /IM "%%~nxA"
	SET "Repeated=1"
	GOTO :RemoveCheckKill
    )
    SET "Repeated="
EXIT /B
)
