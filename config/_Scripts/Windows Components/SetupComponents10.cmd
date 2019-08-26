@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)


"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Windows-Defender-Default-Definitions" /FeatureName:"FaxServicesClientPackage"
rem "%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"SMB1Protocol-Deprecation"

rem +useful components
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"TelnetClient" /FeatureName:"TFTP"
rem /FeatureName:"SMB1Protocol" /FeatureName:"SMB1Protocol-Client"
rem "%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"TelnetServer" /FeatureName:"ScanManagementConsole" /FeatureName:"Printing-XPSServices-Features" /FeatureName:"TIFFIFilter"

EXIT /B
)
