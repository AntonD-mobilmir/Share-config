@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
    
    IF NOT EXIST "d:\Scripts\software_update\scripts" EXIT /B
    
    FOR /F "usebackq delims=" %%A IN ("%ProgramData%\mobilmir.ru\ScriptUpdaterDir.txt") DO SET "ScriptUpdaterDir=%%~A"
    IF NOT DEFINED ScriptUpdaterDir EXIT /B 1

    FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
    IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
    
    SET "scriptConfDir=D:\Scripts\ScriptUpdater"
)
(
    IF NOT EXIST "%scriptConfDir%" MKDIR "%scriptConfDir%"
    %AutohotkeyExe% /ErrorStdOut "%ScriptUpdaterDir%\scriptUpdater.ahk" "%scriptConfDir%\software_update_autodist downloader-dist.7z" "https://www.dropbox.com/s/fy4z5xaue1yphzu/software_update_autodist%20downloader-dist.7z.gpg?dl=1"
    %AutohotkeyExe% /ErrorStdOut "%ScriptUpdaterDir%\scriptUpdater.ahk" "%scriptConfDir%\software_update_autodist software_update.7z" "https://www.dropbox.com/s/jkdv5ewz5kgbnod/software_update_autodist%20software_update.7z.gpg?dl=1"
    IF NOT DEFINED exe7z CALL "%configDir%_Scripts\find7zexe.cmd"
    
    FOR %%A IN ("%scriptConfDir%\software_update_autodist downloader-dist.7z") DO SET "dldisttm=%%~tA"
    FOR %%A IN ("%scriptConfDir%\software_update_autodist software_update.7z") DO SET "softuptm=%%~tA"
    
    FOR /F "usebackq delims=" %%A IN ("%scriptConfDir%\last_dates.txt") DO (
        IF DEFINED prevdldisttm (SET "prevsoftuptm=%%~A") ELSE SET "prevdldisttm=%%~A"
    )
)
(
    IF "%prevdldisttm%"=="%dldisttm%" IF "%prevsoftuptm%"=="%softuptm%" EXIT /B
    
    %exe7z% x -aoa -y -o"d:\Scripts" -- "%scriptConfDir%\software_update_autodist downloader-dist.7z" || CALL :RecordError "downloader-dist.7z"
    %exe7z% x -aoa -y -o"d:\Scripts\software_update" -- "%scriptConfDir%\software_update_autodist software_update.7z" || CALL :RecordError "software_update.7z"
    
    IF NOT DEFINED recErr (
        (
            ECHO %dldisttm%
            ECHO %softuptm%
        ) >>"%scriptConfDir%\last_dates.txt"
        
        START "" %AutohotkeyExe% "%configDir%_Scripts\Lib\RetailStatusReport.ahk" "%~n0" "OK" "downloader-dist.7z: %dldisttm% (prev: %prevdldisttm%), software_update.7z: %softuptm% (prev: %prevsoftuptm%)"
        EXIT /B
    )
)
(
    START "" %AutohotkeyExe% "%configDir%_Scripts\Lib\RetailStatusReport.ahk" "%~f0" "%recErr:~2%" "downloader-dist.7z: %dldisttm% (prev: %prevdldisttm%), software_update.7z: %softuptm% (prev: %prevsoftuptm%)"
    EXIT /B
)
:RecordError
(
    SET "recErr=%ErrorLevel%, %~1: %recErrLvl%"
EXIT /B
)
