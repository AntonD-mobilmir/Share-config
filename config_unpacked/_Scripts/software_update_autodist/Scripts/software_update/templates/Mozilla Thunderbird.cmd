@(REM coding:CP866
IF /I "%computername:~0,3%"=="Srv" EXIT /B
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
IF NOT EXIST "%lProgramFiles%\Mozilla Thunderbird\*" EXIT /B 1
CALL "%Distributives%\Soft\Network\Mail News\Mozilla Thunderbird\autoupdate.cmd"
EXIT /B
)
