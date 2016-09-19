@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

SET TempDir=%TEMP%\Reg

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
%exe7z% x -aoa "%~dp0reg.7z" -o"%TempDir%" || PAUSE

PUSHD "%TempDir%" || (PAUSE & GOTO :EOF)

regedit.exe /s "ui\Animation_Disable.reg"
regedit.exe /s "ui\BootTime_AutoCheck_CountDown.reg"
regedit.exe /s "ui\cmd_exe_colors.reg"
regedit.exe /s "ui\ForegroundLockTimeout.reg"
regedit.exe /s "ui\no_low_disk_space_warning.reg"
regedit.exe /s "ui\no_low_disk_space_warning_.d.reg"
regedit.exe /s "ui\No_Sounds.reg"
regedit.exe /s "ui\No_Sounds.d.reg"
regedit.exe /s "ui\NoActiveDesktop.reg"
regedit.exe /s "ui\NoActiveDesktopChanges.reg"
regedit.exe /s "ui\XP_HKU.Default_PowerConfig.reg"
POPD

RD /S /Q "%TempDir%" || PAUSE
ENDLOCAL

GOTO :EOF

:regall
PUSHD %1 || (PAUSE & GOTO :EOF)
FOR %%i IN (*.reg) DO regedit.exe /s "%%i"
POPD

:EOF
