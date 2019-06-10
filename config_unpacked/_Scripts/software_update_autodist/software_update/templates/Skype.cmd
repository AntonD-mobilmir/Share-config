@(REM coding:CP866
SET "SkypeInstFlag=%ProgramData%\mobilmir.ru\Skype-Must-Be-Installed.flag"
rem defined in software_update.cmd -- SET "logmsi=%s_uscriptsStatus%\%~nx0-msiexec.log"
SET "TempDst=%TEMP%\SkypeDistributive"
)
(
rem If install already started but not finished, continue
IF EXIST "%SkypeInstFlag%" GOTO :continue
rem Except following version,
rem -- older versions stopped working recently -- FOR /F "usebackq tokens=1" %%I IN (`"%SystemDrive%\SysUtils\lbrisar\getver.exe" "%lProgramFiles%\Skype\Phone\Skype.exe"`) DO IF "%%~I"=="6.14.0.104" EXIT /B
rem ...update any existing Skype
IF EXIST "%lProgramFiles%\Microsoft\Skype for Desktop\Skype.exe" GOTO :continue
IF EXIST "%lProgramFiles%\Skype\Phone\Skype.exe" GOTO :continue
EXIT /B
)
:continue
(
    (
	ECHO %DATE% %TIME%
	MKDIR "%TempDst%"
    )>>"%SkypeInstFlag%"
    ECHO Y|XCOPY "%Distributives%\Soft\Network\Chat Messengers\Skype\*.*" "%TempDst%" /D /I /H /Y || EXIT /B 2
    CALL "%TempDst%\install.cmd"
    IF NOT EXIST "%lProgramFiles%\Microsoft\Skype for Desktop\Skype.exe" EXIT /B 32767
    DEL "%SkypeInstFlag%"
    RD /S /Q "%TempDst%"
    EXIT /B 0
)
