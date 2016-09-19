@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF EXIST "%lProgramFiles%\Java" SET "JREInstalled=1"
IF EXIST "%ProgramFiles%\Java" SET "JREInstalled=1"
)
IF DEFINED JREInstalled (
    FOR /D %%A IN ("%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\otn-pub\java\jdk\*") DO IF EXIST "%%A\*.exe" SET "JREDistributiveFound=1"
    IF DEFINED JREDistributiveFound (
	ECHO %DATE% %TIME% Удаление JRE
	%AutohotkeyExe% "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\uninstall.ahk"

	CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\jre_install.cmd"
    )
)
