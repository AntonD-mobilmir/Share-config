@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

REM Find software source

REM trySoftUpdateScripts first
CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_SoftUpdateScripts_source.cmd"
)
(
IF DEFINED Distributives CALL :CheckSetSoftSource "%Distributives%" && GOTO :found

REM then %configDir%..
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)
CALL :GetDir configDir "%DefaultsSource%"
(
REM first try configdir\.., then fallback to localhost, Srv0 and Srv1S-B
CALL :CheckSetSoftSource "%configDir%.." && CALL :CheckSetSoftSource "%COMPUTERNAME:~0,-2%-K\Distributives" || CALL :CheckSetSoftSource "%~d0\Distributives" || CALL :CheckSetSoftSource "%~dp0..\.." || CALL :CheckSetSoftSource "D:\Distributives" || CALL :CheckSetSoftSource "\\localhost\Distributives" || CALL :CheckSetSoftSource "\\Srv0.office0.mobilmir\Distributives" || CALL :CheckSetSoftSource "\\Srv1S-B.office0.mobilmir\Distributives" || CALL :AskSoftSource || EXIT /B
)
:found
(
SET "utilsdir=%DistSourceDir%\Soft\PreInstalled\utils\"
ECHO SoftSourceDir: %SoftSourceDir%
EXIT /B
)
:CheckSetSoftSource
    IF EXIST "%~1\Soft\PreInstalled\utils\7za.exe" (
	SET "DistSourceDir=%~f1"
	SET "SoftSourceDir=%~f1\Soft"
	EXIT /B 0
    )
EXIT /B 1

:AskSoftSource
(
ECHO Папка дистрибутивов найдена в стандартных расположениях. Укажите полный путь к папке, в которой находится подпапка Soft. Например, D:\Distributives
SET /P "testDistSourceDir=^> "
IF NOT DEFINED testDistSourceDir EXIT /B 1
)
(
CALL :CheckSetSoftSource "%testDistSourceDir%"
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
