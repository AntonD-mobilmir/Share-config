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
rem RD /S /Q "%SystemRoot%\SoftwareDistribution\Download"

DEL "%ProgramData%\Microsoft\Network\Downloader\qmgr0.dat"
DEL "%ProgramData%\Microsoft\Network\Downloader\qmgr1.dat"

IF /I "%~1"=="/NOWAIT" EXIT /B
IF NOT "%~1"=="" EXIT /B
ECHO �� �த������� �㦡� ���������� �㤥� ᭮�� ����饭�
PAUSE
SC START BITS
SC START WUAUSERV

PING 127.0.0.1 -n 30

compact /C /S:"%SystemRoot%\SoftwareDistribution" /I *
