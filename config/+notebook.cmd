@REM coding:OEM
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

POWERCFG /HIBERNATE /SIZE 40

IF NOT DEFINED SoftSourceDir CALL "%~dp0_Scripts\FindSoftwareSource.cmd"
rem IF NOT DEFINED instQuickConfig SET /P "instQuickConfig=��⠭����� Intelloware Quick Config? [1=��, ��⠫쭮�=���]"
rem IF "%instQuickConfig%"=="1" START "��⠭���� Intelloware Quick Config" /WAIT /I msiexec.exe /i "%SoftSourceDir%\Network\Configuration\Intelloware Quick Config\QuickConfig.msi" /q
