@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

(
SETLOCAL
ECHO Usage: %0 <file> [<MinVer>]
ECHO If second argument provided, returns error level 1 if version of file is less than required
ECHO Otherwise, sets %%filever%% variable to file version No.

rem http://superuser.com/a/363308/131936
SET "fileNameForWMIC=%~1"
)
SET fileNameForWMIC=%fileNameForWMIC:\=\\%
FOR /F "usebackq skip=1" %%I IN (`wmic datafile where Name^="%fileNameForWMIC%" get Version`) DO (
    SET filever=%%~I
    GOTO :break
)
:break
(
IF "%~2"=="" (
    ENDLOCAL
    SET "filever=%filever%"
    EXIT /B
)
FOR /F "delims=. tokens=1,2,3,4" %%I IN ("%filever%") DO (
    SET fileverSub1=%%I
    SET fileverSub2=%%J
    SET fileverSub3=%%K
    SET fileverSub4=%%L
)
FOR /F "delims=. tokens=1,2,3,4" %%I IN ("%~2") DO (
    SET chkSub1=%%I
    SET chkSub2=%%J
    SET chkSub3=%%K
    SET chkSub4=%%L
)
IF NOT DEFINED fileverSub2 SET fileverSub2=0
IF NOT DEFINED fileverSub3 SET fileverSub3=0
IF NOT DEFINED fileverSub4 SET fileverSub4=0
IF NOT DEFINED chkSub2 SET chkSub2=0
IF NOT DEFINED chkSub3 SET chkSub3=0
IF NOT DEFINED chkSub4 SET chkSub4=0
)
(
ENDLOCAL
IF %chkSub1% GTR %fileverSub1% EXIT /B 1
IF %chkSub2% GTR %fileverSub2% EXIT /B 1
IF %chkSub3% GTR %fileverSub3% EXIT /B 1
IF %chkSub4% GTR %fileverSub4% EXIT /B 1
EXIT /B 0
)
