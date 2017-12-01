@REM coding:OEM
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

net stop BITS
net stop wuauserv
sc stop BITS
sc stop wuauserv
ping -n 2 127.0.0.1 >NUL

MOVE "%SystemRoot%\SoftwareDistribution" "%SystemRoot%\SoftwareDistribution.bak"
:again
RD /S /Q "%SystemRoot%\SoftwareDistribution.bak"
IF EXIST "%SystemRoot%\SoftwareDistribution.bak" GOTO :again
RD /S /Q "%SystemRoot%\SoftwareDistribution\Download"

DEL "%ProgramData%\Microsoft\Network\Downloader\qmgr0.dat"
DEL "%ProgramData%\Microsoft\Network\Downloader\qmgr1.dat"

IF /I "%~1"=="/NOWAIT" EXIT /B
IF "%~1"=="" (
    ECHO При продолжении служба обновления будет снова запущена
    PAUSE
) ELSE (
    PING 127.0.0.1 -n 30
)

SC START BITS
SC START WUAUSERV
compact /C /S:"%SystemRoot%\SoftwareDistribution" /I *
