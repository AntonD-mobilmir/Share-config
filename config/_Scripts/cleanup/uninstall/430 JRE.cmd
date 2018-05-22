@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0..\uninstall_soft_init.cmd"
)
FOR %%A IN ("%ProgramFiles32%" "%ProgramFiles64%") DO IF EXIST "%%~A\Java" (
    FOR /D %%B IN ("%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\otn-pub\java\jdk\*") DO IF EXIST "%%~B\*.exe" (
	CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\jre_install.cmd"

	ECHO %DATE% %TIME% Удаление JRE
	CALL "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\jre6_uninstall.cmd"
	CALL "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\jre7_uninstall.cmd"
	%AutohotkeyExe% "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\uninstall.ahk"
    )
)
