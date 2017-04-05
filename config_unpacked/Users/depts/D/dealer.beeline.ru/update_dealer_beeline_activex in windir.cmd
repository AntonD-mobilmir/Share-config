@(REM coding:CP866
SET "System32=%SystemRoot%\System32"
IF EXIST %SystemRoot%\SysWOW64\cmd.exe SET "System32=%SystemRoot%\SysWOW64"
)
CALL "%~dp0update_dealer_beeline_activex.cmd" /Unpack "in windir" "%System32%"
