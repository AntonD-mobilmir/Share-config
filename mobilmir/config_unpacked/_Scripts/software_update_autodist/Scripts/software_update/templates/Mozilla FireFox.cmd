@(REM coding:CP866
IF /I "%computername:~0,3%"=="Srv" EXIT /B
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
IF NOT EXIST "%lProgramFiles%\Mozilla Firefox\" EXIT /b 1
CALL "%Distributives%\Soft\Network\HTTP\Mozilla FireFox\install.cmd"
)
(
rem IF ERRORLEVEL 1 SET "ErrorMemory=%ERRORLEVEL%"
IF EXIST "%lProgramFiles%\Mozilla Maintenance Service\Uninstall.exe" "%lProgramFiles%\Mozilla Maintenance Service\Uninstall.exe" /S
EXIT /B %ERRORLEVEL%
)
