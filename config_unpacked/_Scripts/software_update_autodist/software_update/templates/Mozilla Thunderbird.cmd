@(REM coding:CP866
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
IF NOT EXIST "%lProgramFiles%\Mozilla Thunderbird\thunderbird.exe" IF NOT EXIST "%ProgramFiles%\Mozilla Thunderbird\thunderbird.exe" EXIT /B 1
CALL "%Distributives%\Soft\Network\Mail News\Mozilla Thunderbird\autoupdate.cmd"
EXIT /B
)
