@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

xcopy "%~dp0*.*" "%1\d$\dealer.beeline.ru\" /I /G /R /H /K /Y
psexec %1 -w D:\dealer.beeline.ru cmd.exe /C D:\dealer.beeline.ru\update_dealer_beeline_activex.cmd
