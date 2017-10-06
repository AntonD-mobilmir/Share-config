@(REM coding:CP866
IF NOT EXIST dfhl.err.log ECHO.>dfhl.err.log
START "" /B /BELOWNORMAL "%LOCALAPPDATA%\Programs\SysUtils\UnxUtils\tail.exe" -F dfhl.err.log
)
:again
(
"%LOCALAPPDATA%\Programs\SysUtils\DFHL.exe" /l /m /r /w %* 2>>dfhl.err.log | "d:\Users\LogicDaemon\AppData\Local\Programs\SysUtils\UnxUtils\tee.exe" -a dfhl.log
PING 127.0.0.1 -n 300 >NUL 2>&1
GOTO :again
)
