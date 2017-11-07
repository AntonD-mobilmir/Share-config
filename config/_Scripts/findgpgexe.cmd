@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

CALL :findgpgexe || CALL :unpackgpgexe
EXIT /B
)
:findgpgexe
(
SET "findExeTestExecutionOptions=--batch --version"
SET "pathAppendSubpath=..\libs;..\..\libs"
CALL "%~dp0find_exe.cmd" gpgexe "%SystemDrive%\SysUtils\gnupg\gpg.exe" "%SystemDrive%\SysUtils\gnupg\bin\gpg.exe" "%SystemDrive%\SysUtils\gnupg\pub\gpg.exe" "%ProgramFiles%\GnuPG\gpg.exe" "%ProgramFiles%\GnuPG\bin\gpg.exe" "%ProgramFiles%\GnuPG\pub\gpg.exe" "%ProgramFiles(x86)%\GnuPG\gpg.exe" "%ProgramFiles(x86)%\GnuPG\bin\gpg.exe" "%ProgramFiles(x86)%\GnuPG\pub\gpg.exe" "%LOCALAPPDATA%\Programs\SysUtils\gnupg\gpg.exe" "%LOCALAPPDATA%\Programs\SysUtils\gnupg\bin\gpg.exe" "%LOCALAPPDATA%\Programs\SysUtils\gnupg\pub\gpg.exe" "%LOCALAPPDATA%\Programs\gnupg\gpg.exe" "%LOCALAPPDATA%\Programs\gnupg\bin\gpg.exe" "%LOCALAPPDATA%\Programs\gnupg\pub\gpg.exe" "%LOCALAPPDATA%\SysUtils\gnupg\gpg.exe" "%LOCALAPPDATA%\SysUtils\gnupg\bin\gpg.exe" "%LOCALAPPDATA%\SysUtils\gnupg\pub\gpg.exe" || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
SET "pathAppendSubpath="
SET "findExeTestExecutionOptions="
EXIT /B
)
:unpackgpgexe
(
IF NOT DEFINED SoftSourceDir CALL "%~dp0FindSoftwareSource.cmd"
IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd"
SET "PATH=%PATH%;%LOCALAPPDATA%\Programs\SysUtils\libs;%LOCALAPPDATA%\Programs\SysUtils\gnupg"
IF NOT DEFINED LOCALAPPDATA SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
)
(
%exe7z% x -aoa -o"%LOCALAPPDATA%\Programs\SysUtils" -- "%SoftSourceDir%\PreInstalled\auto\SysUtils\SysUtils_ConEssentials.7z"
%exe7z% x -aoa -o"%LOCALAPPDATA%\Programs\SysUtils" -- "%SoftSourceDir%\PreInstalled\auto\SysUtils\SysUtils_GPG.7z"
%SystemRoot%\System32\icacls.exe "%LOCALAPPDATA%\Programs\SysUtils" /grant "*S-1-1-0:(OI)(CI)RX"

REM findExeTestExecutionOptions and pathAppendSubpath should have stayed defined from findgpgexe call
CALL "%~dp0find_exe.cmd" gpgexe "%LOCALAPPDATA%\Programs\SysUtils\gnupg\gpg.exe" "%LOCALAPPDATA%\Programs\SysUtils\gnupg\bin\gpg.exe" "%LOCALAPPDATA%\Programs\SysUtils\gnupg\pub\gpg.exe"
EXIT /B
)
