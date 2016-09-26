@(REM coding:CP866
IF NOT DEFINED SysUtilsDir CALL "%~dp0_init.cmd"
)
(
FOR %%I IN ("%~dp0SysUtils\*.cmd") DO CALL "%%~fI"
%windir%\System32\compact.exe /C /F /EXE:LZX /I /S:"%SysUtilsDir%" || %windir%\System32\compact.exe /C /F /I /S:"%SysUtilsDir%"
rem Importing REGs
FOR /R "%SysUtilsDir%\SysInternals" %%I IN (*.reg) DO REG IMPORT "%%~fI"
REM done in _init.cmd: Adding DLLs and CMDs to %PATH% "%utilsdir%pathman.exe" /as "%pathString%"

rem always defined on new windowses -- IF NOT DEFINED APPDATA SET APPDATA=%USERPROFILE%\Application Data
rem not needed on new windowses -- IF NOT EXIST "%APPDATA%" "%SysUtilsDir%\ResKit\setx.exe" APPDATA "~USERPROFILE~\Application Data"

REM GTK+ post-install script works only if gtk-libraries are in path
REM This is done least because of problem with this when using 64-bit OS because of brackets (x86) in %path%
CALL "%SysUtilsDir%\libs\GTK+\gtk2-runtime\gtk-postinstall.bat"
)
