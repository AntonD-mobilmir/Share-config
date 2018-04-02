@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

rem HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
rem HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders
rem
rem OR 
rem
rem HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
rem Public

SET "destDir=%ProgramData%\mobilmir.ru\reg-backup"

SET "now=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%_%TIME::=%"
)
(
MKDIR "%destDir%"
%SystemRoot%\System32\REG.exe EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" "%destDir%\HKLM-Shell Folders.%now%.reg"
%SystemRoot%\System32\REG.exe EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" "%destDir%\HKLM-User Shell Folders.%now%.reg"
%SystemRoot%\System32\REG.exe IMPORT "%~dp0HKLM User Shell Folders D_Users_Public.reg"
FOR /D %%A IN ("%~dp0D\*") DO %SystemRoot%\System32\XCOPY.exe "%%~A" "D:\%%~nxA" /E /I /G /H /K /Y /B
)
