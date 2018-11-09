@(REM coding:CP866
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
)
(
CALL "%baseScripts%\_GetWorkPaths.cmd"
CALL "%baseScripts%\_DistDownload.cmd" http://download.yandex.ru/punto/PuntoSwitcherSetup.exe PuntoSwitcherSetup.exe
)
