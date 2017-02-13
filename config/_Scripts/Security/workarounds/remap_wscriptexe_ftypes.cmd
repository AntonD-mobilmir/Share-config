@(REM coding:CP866
REM via https://twitter.com/SwiftOnSecurity/status/794440680235859968
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

rem Alternative: https://technet.microsoft.com/en-us/library/ee198684.aspx

    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    FOR /F "usebackq tokens=1 delims=[]" %%I IN (`%SystemRoot%\System32\find.exe /n "-!!! extensions list-" "%~f0"`) DO SET "extSkipLines=skip=%%I"
    FOR /F "usebackq tokens=1 delims=[]" %%I IN (`%SystemRoot%\System32\find.exe /n "-!!! file types list-" "%~f0"`) DO SET "ftypesSkipLines=skip=%%I"
    
    SET "today=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
    SET "bkpDir=%LOCALAPPDATA%\%~n0"
)
(
    SET tf="%TEMP%\%~n0.%today% %TIME::=-%.tmp"
    
    MKDIR "%bkpDir%" 2>NUL
    IF NOT EXIST "%bkpDir%" EXIT /B
    SET bkpASSOC="%bkpDir%\ASSOC %today% %TIME::=-%.txt"
    SET bkpFTYPE="%bkpDir%\FTYPE %today% %TIME::=-%.txt"
)
FOR /F "usebackq %extSkipLines% tokens=1* delims==" %%A IN ("%~f0") DO (
    IF "%%~A"=="." GOTO :ExitExtFor
    (ASSOC "%%~A">>%bkpASSOC%) && (
	FOR /F "usebackq tokens=1* delims==" %%B IN (`ASSOC "%%~A"`) DO CALL :procFTYPE "%%~C"
	ASSOC "%%A=%%B"
    )
)
:ExitExtFor

FOR /F "usebackq %ftypesSkipLines% tokens=*" %%A IN ("%~f0") DO (
    CALL :procFTYPE %%A
)
:ExitFTypeFor
EXIT /B

:procFTYPE <ftype>
(
    (FTYPE "%~1">>%bkpFTYPE%) && FTYPE "%~1"=%%SystemRoot%%\system32\NOTEPAD.EXE %%1
EXIT /B
)

rem -!!! extensions list-
.js
.jse
.vbs
.vbe
.wsh
.hta
.
rem prev line is end-of-list marker, do not remove

rem -!!! file types list-
JSEFile
JSFile
VBEFile
VBSFile
WSFFile
WSHFile
