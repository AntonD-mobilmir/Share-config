@REM <meta http-equiv="Content-Type" content="text/batch; charset=cp866">
REM Ask user to enter value for variable [environment]
REM                                           by LogicDaemon AKA AntICode
REM                                                 logicdaemon@gmail.com

SET AskOption_tempbatch=%TEMP%\%~n0_deriative.cmd
SETLOCAL ENABLEDELAYEDEXPANSION
IF "%~1"=="" (
	ECHO Usage:
	ECHO %0 "VariableName" "QuestionToUser" [value if empty]
	ECHO %0: not enough command line arguments>&2
	EXIT /b 2
)
IF NOT "%~3"=="" SET DefaultValue=, Enter=%3

SET /p %1=%2 [y/yes/д = 1(да)%DefaultValue%]
IF /I "!%1!"=="y" SET %1=1
IF /I "!%1!"=="yes" SET %1=1
IF /I "!%1!"=="д" SET %1=1
IF "!%1!"=="" SET %1=%3
ECHO SET %1=!%1!>"%AskOption_tempbatch%"
ENDLOCAL
CALL "%AskOption_tempbatch%"
DEL "%AskOption_tempbatch%"
SET AskOption_tempbatch=
