@(REM coding:CP866
START "Copying config" /WAIT %comspec% /C "\\Srv0.office0.mobilmir\profiles$\Share\config\update local config.cmd"
IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || PAUSE
)
(
%exe7z% x -aoa -o"%TEMP%\BTSync install scripts" -- "%~dp0BTSync install scripts.7z"
START "" /D"%TEMP%\BTSync install scripts" /B /WAIT %comspec% /C "%TEMP%\BTSync install scripts\Install_BTSync.cmd"
RD /S /Q "%TEMP%\BTSync install scripts"
)
