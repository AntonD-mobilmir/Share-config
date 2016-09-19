@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

SET TempDir=%TEMP%\Reg

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
%exe7z% x -aoa "%~dp0reg.7z" -o"%TempDir%" || PAUSE

PUSHD "%TempDir%" || (PAUSE & GOTO :EOF)

REG IMPORT "default_UI\XP_HKU.Default_control_panel.reg"

POPD

RD /S /Q "%TempDir%" || PAUSE
ENDLOCAL

GOTO :EOF

:regall
PUSHD %1 || (PAUSE & GOTO :EOF)
FOR %%i IN (*.reg) DO regedit.exe /s "%%i"
POPD

:EOF
