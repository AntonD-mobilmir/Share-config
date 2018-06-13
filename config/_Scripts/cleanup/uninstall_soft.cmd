@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    CALL "%~dp0uninstall\Lib\_init.cmd"
)
(
    ECHO Running uninstall scripts...

    FOR /F "usebackq delims=" %%A IN (`DIR /O /B "%~dp0uninstall\*.*"`) DO (
	SET "RunningUninstallName=%%~nA"
	IF /I "%%~xA"==".ahk" (
	    %AutohotkeyExe% /ErrorStdOut "%~dp0uninstall\%%~A"
	) ELSE (
	    CALL "%~dp0uninstall\%%~A"
        )
    )
)
