@REM coding:OEM
@ECHO OFF
ECHO This batch file will Force the Update Detection from the AU client: 
ECHO 1. Stop the Automatic Updates Service (wuauserv)
ECHO 2. Delete the LastWaitTimeout registry key 
ECHO 3. Delete the DetectionStartTime registry key 
ECHO 4. Delete the NextDetectionTime registry key
ECHO 5. Restart the Automatic Updates Service (wuauserv) 
ECHO 6. Force the detection 
PAUSE
ECHO ON
net stop wuauserv
REG DELETE "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v LastWaitTimeout /f
REG DELETE "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v DetectionStartTime /f
Reg Delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v NextDetectionTime /f
net start wuauserv
wuauclt /detectnow
@ECHO off
ECHO This AU client will now check for the Updates on the Local WSUS Server.
