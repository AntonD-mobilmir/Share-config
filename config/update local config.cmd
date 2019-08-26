@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
    SET "srcpath=%~dp0"
    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"

    IF NOT "%~1"=="" SET "configDir=%~1"
    SET "rsyncHost=Srv0.office0.mobilmir"
    IF NOT DEFINED configDir (
        IF DEFINED DefaultsSource CALL :getconfigDirFromDefaultsSource "%DefaultsSource%"
        IF NOT DEFINED configDir CALL "%~dp0_Scripts\copy_defaultconfig_to_localhost.cmd"
        IF NOT DEFINED configDir ECHO Место назначения не определено. Сначала стоит установить _get_defaultconfig_source.cmd & PAUSE & EXIT /B
    )
    
    SET "robocopyDcopy=DAT"
    CALL "%~dp0_Scripts\CheckWinVer.cmd" 8 || SET "robocopyDcopy=T"
)
(
    IF "%configDir:~0,2%"=="\\" ECHO Папка конфигурации - в сети, обновлять можно только локальную папку! & PAUSE & EXIT /B
    IF NOT EXIST "%configDir%" MKDIR "%configDir%" || EXIT /B
    IF EXIST "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\*.*" %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config" "%configDir:~0,-1%" /MIR /DCOPY:%robocopyDcopy% /SL /XO && EXIT /B
    
    ECHO Локальная конфигурация не обновлена!>&2
EXIT /B 1
)
:getconfigDirFromDefaultsSource <DefaultsSource>
    SET "configDir=%~dp1"
(
    IF "%configDir:~0,2%"=="\\" SET "dest=" & EXIT /B 1
EXIT /B 0
)
