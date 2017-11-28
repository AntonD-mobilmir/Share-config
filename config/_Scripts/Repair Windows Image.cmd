@(REM coding:CP866
REM via https://technet.microsoft.com/en-us/library/hh824869.aspx
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

%SystemRoot%\System32\Dism.exe /Online /Cleanup-Image /ScanHealth
%SystemRoot%\System32\Dism.exe /Online /Cleanup-Image /CheckHealth

ECHO Чтобы запустить восстановление, укажите путь к неповреждённой папке Windows
ECHO или нажмите Enter, чтобы загрузить исправные файлы через Интернет
ECHO (или закройте окно, если восстанавливать не надо^)
SET /P "repairsrc=> "
)
IF DEFINED repairsrc (
    %SystemRoot%\System32\Dism.exe /Online /Cleanup-Image /RestoreHealth /Source:"%repairsrc%"
) ELSE %SystemRoot%\System32\Dism.exe /Online /Cleanup-Image /RestoreHealth
