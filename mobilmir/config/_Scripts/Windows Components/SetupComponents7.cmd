@REM coding:OEM
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

rem Windows 7 Pro
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"MediaCenter"

rem -games
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Solitaire"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"SpiderSolitaire"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Hearts"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"FreeCell"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Minesweeper"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"PurblePlace"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Chess"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Shanghai"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Internet Checkers"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Internet Backgammon"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Internet Spades"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Internet Games"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"InboxGames"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"More Games"

rem +useful components
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"TelnetClient"
rem "%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"TelnetServer"
rem "%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"ScanManagementConsole"
rem "%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"TFTP"
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"Printing-XPSServices-Features"
REM "%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"TIFFIFilter"

EXIT /B
