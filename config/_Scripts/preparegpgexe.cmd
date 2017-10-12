@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

CALL "%~dp0findgpgexe.cmd"
)
(
REM Check if there is a secret key yet
FOR /F "usebackq tokens=1" %%A IN (`%gpgexe% --batch -K`) DO IF "%%~A"=="sec" EXIT /B

REM otherwise, generate first secret key and import trusted keys
CALL "%~dp0\genGpgKeyring.cmd"
EXIT /B 0
)
