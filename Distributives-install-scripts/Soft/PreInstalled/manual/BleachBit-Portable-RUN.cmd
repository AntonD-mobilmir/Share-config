@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
SET "utilsdir=%~dp0..\utils\"
IF NOT DEFINED LOCALAPPDATA (
    IF EXIST "%USERPROFILE%\AppData\Local\*" ( SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local" ) ELSE SET "LOCALAPPDATA=%USERPROFILE%\Local Settings\Application Data"
)
SET "UIDEveryone=S-1-1-0;s:y"
)
(
IF NOT DEFINED exe7z SET exe7z="%utilsdir%7za.exe"
SET "dest=%LOCALAPPDATA%\Programs\BleachBit-Portable"
)
(
%exe7z% x -aoa -y -o"%dest%" -- "%~dp0BleachBit-Portable.7z"
"%SystemDrive%\SysUtils\SetACL.exe" -on "%dest%" -ot file -actn ace -ace "n:%UIDEveryone%;p:change;i:so,sc;m:set;w:dacl"

PUSHD "%dest%" && (
    "%dest%\bleachbit_console.exe" -c --no-uac --preset
    POPD
    ECHO BleachBit finished
    RD /S /Q "%dest%"
)
EXIT /B
)
