@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.


(
    SET "OSWordSize=32"
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSWordSize=64"
    IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSWordSize=64"
    FOR /F "usebackq delims=" %%W IN (`ver`) DO SET "VW=%%W"
)

IF "%VW:~0,24%"=="Microsoft Windows 2000 [" (
    REM 2K: Microsoft Windows 2000 [����� 5.00.2195]
    SET WinVerNum=5.0
) ELSE IF "%VW:~0,22%"=="Microsoft Windows XP [" (
    REM XP: Microsoft Windows XP [Version 5.1.2600]
    SET WinVerNum=5.1
) ELSE (
    IF "%VW:~0,27%"=="Microsoft Windows [Version " SET "WinVerNum=%VW:~27,-1%"
    IF "%VW:~0,26%"=="Microsoft Windows [����� " SET "WinVerNum=%VW:~26,-1%"
)

:compare
(
IF "%~1"=="" EXIT /B
SETLOCAL
rem Compare Windows version with %1 by parts as numbers.
rem This is required because string "10." is less (<, LSS) than "5.0".

rem returns 1 if version provided via command line is greater than windows version
rem %0 6 to check for Vista-or-higher (equiv to %0 6.0)
rem %0 6.1 to check for Windows 7 / Server 2008 R2 (or higher)
rem %0 6.2 to check for Windows 8 / Server 2012 (or higher)
rem %0 6.3 to check for Windows 8.1 / Server 2012 R2 (or higher)

FOR /F "delims=. tokens=1,2,3" %%I IN ("%WinVerNum%") DO (
    SET "verSub1=%%I"
    SET "verSub2=%%J"
    SET "verSub3=%%K"
)
FOR /F "delims=. tokens=1,2,3" %%I IN ("%~1") DO (
    SET "chkSub1=%%I"
    SET "chkSub2=%%J"
    SET "chkSub3=%%K"
)
IF NOT DEFINED verSub3 SET "verSub3=0"
IF NOT DEFINED chkSub2 SET "chkSub2=0"
IF NOT DEFINED chkSub3 SET "chkSub3=0"
)
(
ENDLOCAL
IF %chkSub1% GTR %verSub1% EXIT /B 1
IF %chkSub1% LSS %verSub1% EXIT /B 0
IF %chkSub2% GTR %verSub2% EXIT /B 1
IF %chkSub2% LSS %verSub2% EXIT /B 0
IF %chkSub3% GTR %verSub3% EXIT /B 1
EXIT /B 0
)
