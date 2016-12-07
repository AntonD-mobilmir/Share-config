@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
SET "AppExec=%srcpath%freemind.exe"

REM for 64-bit Java:
rem ftype Freemind=javaw -cp "%srcpath%lib\freemind.jar";"%srcpath%lib\commons-lang-2.0.jar";"%srcpath%lib\forms-1.0.5.jar";"%srcpath%lib\jibx\jibx-run.jar";"%srcpath%lib\jibx\xpp3.jar";"%srcpath%lib\bindings.jar" freemind.main.FreeMindStarter "%1"

CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
IF DEFINED DefaultsSource (
    ASSOC .mm=Freemind
    FTYPE Freemind="%AppExec%" "%%1"
    CALL :GetDir configDir "%DefaultsSource%"
    CALL :makelink "%AppExec%"
)

EXIT /B

:makelink
SET workdir=%~dp1
SET workdir=%workdir:~0,-1%
IF NOT DEFINED recodeexe CALL "%configDir%_Scripts\find_exe.cmd" recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
IF DEFINED recodeexe SET recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866
IF NOT DEFINED xlnexe CALL "%configDir%_Scripts\find_exe.cmd" xlnexe xln.exe %SystemDrive%\SysUtils\xln.exe || EXIT /B
(
FOR /F "usebackq tokens=2* delims=	" %%I IN (`REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Common Programs" %recodecmd%`) DO SET RegQValue=%%J
IF NOT DEFINED RegQValue EXIT /B 1
)
FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %RegQValue%`) DO SET CommonPrograms=%%I

IF NOT EXIST "%CommonPrograms%\%~n1" MKDIR "%CommonPrograms%\%~n1"
"%xlnexe%" -w -wd "%workdir%" %1 "%CommonPrograms%\%~n1\%~n1.lnk"

EXIT /B
)
:GetDir <var> <path>
(
SET "%~1=%~dp2"
EXIT /B
)
