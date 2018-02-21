@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
    SET "relpath=PreInstalled\manual\BleachBit-Portable-RUN.cmd"
    
    IF NOT "%~1"=="" CALL :ProcessArgs %* || EXIT /B
    
    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
    IF NOT DEFINED Distributives CALL "%~dp0..\FindSoftwareSource.cmd"
)
(
    IF NOT EXIST "%SoftSourceDir%\%relpath%" EXIT /B
    CALL "%SoftSourceDir%\%relpath%" %BleachBitArgs%
    ECHO BleachBit finished
    rem BleachBit, бывает работает, через планировщик. В этом случае explorer.exe закрывается у пользователя! TASKKILL /F /IM explorer.exe
    ENDLOCAL
EXIT /B
rem CALL "\\Srv0.office0.mobilmir\profiles$\Share\Programs\BleachBit-Portable\_run_from_localtemp.cmd" -c --no-uac --preset
)
:ProcessArgs
@(
    IF /I "%~1"=="/ProfileOnSystemDrive" (
	CALL :SameDrive "%SystemDrive%" "%USERPROFILE%" || EXIT /B
    ) ELSE SET "BleachBitArgs=%BleachBitArgs% %1"
    
    IF "%~2"=="" EXIT /B 0
    SHIFT
    GOTO :ProcessArgs
)
:SameDrive <path1> <path2>
@(
    IF /I "%~d1"=="%~d2" EXIT /B 0
    EXIT /B 1
)
