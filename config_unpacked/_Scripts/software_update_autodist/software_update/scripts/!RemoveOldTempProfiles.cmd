@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

FOR /F "usebackq tokens=1,2*" %%A IN (`%SystemRoot%\System32\reg.exe QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /v "ProfilesDirectory"`) DO IF "%%~A"=="ProfilesDirectory" SET "ProfilesDirectory=%%~C"
)
FOR /F "usebackq delims=" %%I IN (`CALL ECHO "%ProfilesDirectory%"`) DO SET "ProfilesDirectory=%%~I"
(
CALL :TakeownRemove "%ProfilesDirectory%\TEMP"
FOR /D %%A IN ("%ProfilesDirectory%\TEMP.*") DO CALL :TakeownRemove "%%~A"
EXIT /B
)
:TakeownRemove
SET "checkStart=%~1"
(
    IF NOT DEFINED checkStart EXIT /B 32767
    IF NOT "%ProfilesDirectory:~0,8%"=="%checkStart:~0,8%" (ECHO Asked to remove %1, which is not subpath of %ProfilesDirectory%!&EXIT /B 32767)
    PUSHD %1 && (
	%SystemRoot%\System32\takeown.exe /A /R /D Y /F %1
	%SystemRoot%\System32\icacls.exe %1 /reset /T /C /L
	rem Administrators=S-1-5-32-544
	%SystemRoot%\System32\icacls.exe %1 /grant "*S-1-5-32-544:(OI)(CI)F"
	POPD
	RD /S /Q %1
    )
EXIT /B
)
