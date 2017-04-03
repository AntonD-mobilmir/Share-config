@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "sidAuthenticatedUsers=*S-1-5-11"

IF NOT DEFINED Download IF /I "%~1"=="/Unpack" SET "Download=0"
IF NOT DEFINED Download IF /I "%~1"=="/Download" SET "Download=1"
IF NOT DEFINED Download IF /I "%USERNAME%"=="Продавец" SET "Download=1"
IF NOT DEFINED Download IF /I "%USERNAME%"=="Пользователь" SET "Download=1"
)
SET "dest=%srcpath%bin"
IF "%Download%"=="1" (
    ECHO Скачиваение
    "%ProgramFiles%\Internet Explorer\IEXPLORE.EXE" https://dealer.beeline.ru/dealer/criacx.cab
    ECHO Когда свежий criacx.cab будет в папке "%dest%", нажмите любую клавишу для продолжения.
    PAUSE>NUL
    "%SystemRoot%\System32\schtasks.exe" /Run /TN "mobilmir.ru\update dealer.beeline.ru criacx.ocx"
)
(
IF NOT "%secondrun%"=="1" IF NOT "%PROCESSOR_ARCHITECTURE%"=="x86" (
    SET "secondrun=1"
    SET "Download=0"
    "%SystemRoot%\SysWOW64\cmd.exe" /C %0 %*
    EXIT /B
)

IF EXIST "%dest%\tmp" RD /S /Q "%dest%\tmp"
MKDIR "%dest%\tmp"
%SystemRoot%\System32\extrac32.exe /Y /E "%dest%\criacx.cab" /L "%dest%\tmp"

FOR %%A IN ("%dest%\tmp\*.*") DO (
    IF /I "%%~nA"=="criacx.inf" (
	IF NOT EXIST "%SystemRoot%\Downloaded Program Files" MKDIR "%SystemRoot%\Downloaded Program Files"
	MOVE /Y "%%~A" "%SystemRoot%\Downloaded Program Files"
    ) ELSE IF /I "%%~nA"=="criacx" (
	MOVE /Y "%%~A" "%SystemRoot%\System32"
	IF /I "%%~xA"==".ocx" (
	    "%SystemRoot%\System32\icacls.exe" "%SystemRoot%\System32\criacx.ocx" /grant "%sidAuthenticatedUsers%:RX"
	    "%SystemRoot%\System32\regsvr32.exe" /s "%SystemRoot%\System32\criacx.ocx"
	)
    )
)
RD "%dest%\tmp"

EXIT /B
)
