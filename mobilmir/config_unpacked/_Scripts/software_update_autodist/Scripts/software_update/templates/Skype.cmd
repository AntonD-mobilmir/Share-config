@( REM coding:CP866
SET "SkypeInstFlag=%TEMP%\Skype-Must-Be-Installed.flag"
SET "logmsi=%SUScriptsStatus%\%~nx0-msiexec.log"
SET "TempDst=%TEMP%\Skype"
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
rem If install already started but not finished, continue
IF EXIST "%SkypeInstFlag%" GOTO :continue
rem Except following version,
FOR /F "usebackq tokens=1" %%I IN (`"%SystemDrive%\SysUtils\lbrisar\getver.exe" "%lProgramFiles%\Skype\Phone\Skype.exe"`) DO IF "%%~I"=="6.14.0.104" EXIT /B
rem ...update any existing Skype
IF EXIST "%lProgramFiles%\Skype" GOTO :continue
EXIT /B
)
:continue
(
ECHO. >"%SkypeInstFlag%"
MKDIR "%TempDst%"
ECHO Y|XCOPY "%Distributives%\Soft\Network\Chat Messengers\Skype\*.*" "%TempDst%" /I /H /K /Y || EXIT /B 2

CALL "%Distributives%\Soft\Network\Chat Messengers\Skype\install.cmd"
IF NOT EXIST "%lProgramFiles%\Skype\Phone\Skype.exe" EXIT /B 32767
DEL "%SkypeInstFlag%"
RD /S /Q "%TempDst%"
EXIT /B 0
)
