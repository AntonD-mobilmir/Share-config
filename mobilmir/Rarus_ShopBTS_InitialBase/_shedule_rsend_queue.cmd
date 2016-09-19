@(REM coding:CP866
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd" || (PAUSE & EXIT /B 32767)
)
(
CALL :procconfig "%DefaultsSource%" || (PAUSE & EXIT /B 32767)
SET TaskXML="%~dp0Tasks\1S Rarus DispatchFiles.xml"
IF NOT EXIST "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" SET TaskXML="%~dp0Tasks\1S Rarus DispatchFiles_x86.xml"

SET "SIDAdmins=S-1-5-32-544;s:y"
SET "SIDUsers=S-1-5-32-545;s:y"
)
:repeat
(
    SET repeat=
    CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6 || GOTO :XP
    "%SystemRoot%\System32\schtasks.exe" /Delete /TN "mobilmir\1S Rarus DispatchFiles" /f
    "%SystemRoot%\System32\schtasks.exe" /Create /TN "mobilmir.ru\1S Rarus DispatchFiles" /XML %TaskXML% /IT /f
)
:CheckError
(
    IF NOT ERRORLEVEL 1 EXIT /B
    IF ERRORLEVEL 1 SET /P "repeat=Ошибка. Повторить попытку? [0=нет]"
)
(
    IF "%repeat%"=="0" EXIT /B
    IF /I "%repeat:~0,1%" EQU "0" EXIT /B
    IF /I "%repeat:~0,1%" EQU "n" EXIT /B
GOTO :repeat
)
:XP
    IF NOT DEFINED exeSetACL CALL "%ConfigDir%_Scripts\find_exe.cmd" exeSetACL SetACL.exe "%SystemDrive%\SysUtils\SetACL.exe"
(
    %exe7z% x -aoa -o"%SystemRoot%\Tasks" "%srcpath%Tasks.7z" "1S Rarus DispatchFiles.job"
    %exeSetACL% -on "%SystemRoot%\Tasks\1S Rarus DispatchFiles.job" -ot file -actn setowner -ownr "n:%SIDAdmins%" -actn setprot -op "dacl:p_nc;sacl:np" -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%SIDAdmins%;p:full;i:sc,so;m:set;w:dacl" -actn ace -ace "n:SYSTEM;s:n;p:full;i:io,so;m:set;w:dacl" -actn ace -ace "n:%SIDUsers%;p:change,FILE_DELETE_CHILD;i:sc;m:set;w:dacl" -actn ace -ace "n:%SIDUsers%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so;m:set;w:dacl" 
    "%SystemRoot%\System32\schtasks.exe" /Change /TN "1S Rarus DispatchFiles" /RU Продавец
GOTO :CheckError
)
:procconfig <DefaultsSource>
(
    SET "ConfigDir=%~dp1"
    CALL "%~dp1_Scripts\find7zexe.cmd"
EXIT /B
)
