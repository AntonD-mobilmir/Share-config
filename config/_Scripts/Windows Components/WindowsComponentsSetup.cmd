@REM coding:OEM
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)
(
IF NOT DEFINED dismDoneFile SET "dismDoneFile=%TEMP%\WindowsComponentsSetup.done"
)
(
IF EXIST "%dismDoneFile%" EXIT /B
ECHO %DATE% %TIME% Started
)

FOR /F "usebackq delims=" %%W IN (`ver`) DO SET VW=%%W
IF "%VW:~0,27%"=="Microsoft Windows [Version " (
    SET "WinVerNum=%VW:~27,-1%"
) ELSE IF "%VW:~0,26%"=="Microsoft Windows [Версия " SET "WinVerNum=%VW:~26,-1%"

IF "%WinVerNum:~0,4%"=="10.0" ( CALL :proceed 10
) ELSE IF "%WinVerNum:~0,4%"=="6.4." ( CALL :proceed 10
) ELSE IF "%WinVerNum:~0,4%"=="6.3." ( CALL :proceed 8.1
) ELSE IF "%WinVerNum:~0,4%"=="6.2." ( CALL :proceed 8
) ELSE IF "%WinVerNum:~0,4%"=="6.1." ( CALL :proceed 7
) ELSE IF "%WinVerNum:~0,4%"=="6.0." ( CALL :proceed Vista
)
(
ECHO %DATE% %TIME%
IF DEFINED dismDoneFile (ECHO %DATE% %TIME%)>"%dismDoneFile%"
rem |MOVE /Y "%dismLockFile%" "%dismDoneFile%"
EXIT /B
)
:proceed
CALL "%~dp0SetupComponents%~1.cmd"
EXIT /B
