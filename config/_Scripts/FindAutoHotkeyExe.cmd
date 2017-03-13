(@REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SET "AutohotkeyExe="
    FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :CheckAutohotkeyExe %%I
    rem continuing if AutoHotkeyScript type isn't defined or specified path points to incorect location
    IF NOT DEFINED AutohotkeyExe (
	(CALL :CheckAutohotkeyExe "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" || CALL :CheckAutohotkeyExe "%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe" || CALL :tryutilsdir) && EXIT /B
	
	REM without these options, autohotkey.exe starts AutoHotkey.ahk, opens help or says
	rem 	Script file not found:
	rem 	D:\Users\*\Documents\AutoHotkey.ahk
	SET "findExeTestExecutionOptions=/ErrorStdOut ."
	CALL "%~dp0find_exe.cmd" AutohotkeyExe AutoHotkey.exe
	REM explicit backup not needed in same parethensis scope
	SET "findExeTestExecutionOptions=%findExeTestExecutionOptions%"
    )
EXIT /B
)
:CheckAutohotkeyExe <path>
(
    IF NOT EXIST %1 EXIT /B 1
    SET AutohotkeyExe=%1
    EXIT /B 0
)
:tryutilsdir
    IF NOT DEFINED utilsdir CALL "%~dp0FindSoftwareSource.cmd" || EXIT /B 1
(
    CALL :CheckAutohotkeyExe "%utilsdir%AutoHotkey.exe"
EXIT /B
)
