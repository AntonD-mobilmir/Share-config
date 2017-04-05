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

SET "suffix=%~3"
SET "dest=%~3"
)
(
IF DEFINED suffix SET "suffix= %suffix%"
IF NOT DEFINED dest SET "dest=%srcpath%bin"
SET "tmpdest=%srcpath%bin\tmp"
SET "infdest=%SystemRoot%\Downloaded Program Files"
)
(

    IF "%Download%"=="1" (
	ECHO Скачиваение
	"%ProgramFiles%\Internet Explorer\IEXPLORE.EXE" https://dealer.beeline.ru/dealer/criacx.cab
	ECHO Когда свежий criacx.cab будет в папке "%dest%", нажмите любую клавишу для продолжения.
	PAUSE>NUL
	"%SystemRoot%\System32\schtasks.exe" /Run /TN "mobilmir.ru\update dealer.beeline.ru criacx.ocx"
	EXIT /B
    )
    IF /I "%PROCESSOR_ARCHITECTURE%" NEQ "x86" IF NOT "%secondrun%"=="1" (
	ENDLOCAL
	SET "secondrun=1"
	SET "Download=0"
	"%SystemRoot%\SysWOW64\cmd.exe" /C "%0 %*"
	EXIT /B
    )
    IF EXIST "%tmpdest%" RD /S /Q "%tmpdest%"
    MKDIR "%tmpdest%"
    %SystemRoot%\System32\extrac32.exe /Y /E "%dest%\criacx.cab" /L "%tmpdest%"

    FOR %%A IN ("%tmpdest%\*.*") DO (
	IF /I "%%~nA"=="criacx" (
	    IF /I "%%~xA"==".inf" (
		IF NOT EXIST "%infdest%" MKDIR "%infdest%"
		MOVE /Y "%%~A" "%infdest%"
	    ) ELSE (
		MOVE /Y "%%~A" "%dest%"
		IF /I "%%~xA"==".ocx" (
		    "%SystemRoot%\System32\icacls.exe" "%dest%\criacx.ocx" /grant "%sidAuthenticatedUsers%:RX"
		    "%SystemRoot%\System32\regsvr32.exe" /s "%dest%\criacx.ocx"
		    REG IMPORT "%~dp0\reg\32-bit LM%suffix%.reg" /reg:32
		)
	    )
	)
    )
    RD "%tmpdest%"

EXIT /B
)
