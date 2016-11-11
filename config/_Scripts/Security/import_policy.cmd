@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF NOT DEFINED ErrorCmd SET ErrorCmd=SET ErrorPresence=1

SET secVer=7
CALL "%~dp0..\CheckWinVer.cmd" 6 || SET secVer=5

SET ImportSecPol=0
REM User Install must exist, otherwise some policies are not imported
IF EXIST "%~dp0..\AddUsers\AddUser_Install.cmd" (
    CALL "%~dp0..\AddUsers\AddUser_Install.cmd"
) ELSE (
    NET USER Install /ADD
)

REM same for admin-task-scheduler
IF EXIST "%~dp0..\AddUsers\AddUser_admin-task-scheduler.cmd" (
    CALL "%~dp0..\AddUsers\AddUser_admin-task-scheduler.cmd"
) ELSE (
    NET USER admin-task-scheduler /ADD
)
SET ImportSecPol=

SET seceddb=%SystemRoot%\security\Database\secedit.sdb
SET SecurityCfgInfSrc=%~dp0win%secVer%_security_configured.inf
SET SecurityCfgInf=%TEMP%\win%secVer%_security_configured.inf

IF NOT EXIST "%seceddb%.org" COPY /B "%seceddb%" "%seceddb%.org"
COPY /B "%seceddb%" "%seceddb%.new"||(%ErrorCmd%&EXIT /B 1)
IF "%secVer%"=="5" COPY /Y /B "%srcpath%XP Service Pack 3.sdb" "%seceddb%.new"||(%ErrorCmd%&EXIT /B 1)
REM копировать скрипт .inf в %TEMP%, иначе Win7 не может импортировать политику, поскольку не может получить доступ в сеть
COPY /B /Y "%SecurityCfgInfSrc%" "%SecurityCfgInf%"
"%SystemRoot%\System32\secedit.exe" /configure /db "%seceddb%.new" /cfg "%SecurityCfgInf%"||%ErrorCmd%

CALL "%~dp0GroupPolicy.DenyExecuteRemovables.cmd"

rem MOVE /Y "%seceddb%.new" "%seceddb%"||%ErrorCmd%
DEL "%SecurityCfgInf%"
