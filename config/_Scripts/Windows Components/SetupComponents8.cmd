@(REM coding:OEM
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

rem -games
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Disable-Feature /FeatureName:"Solitaire" /FeatureName:"SpiderSolitaire" /FeatureName:"Hearts" /FeatureName:"FreeCell" /FeatureName:"Minesweeper" /FeatureName:"PurblePlace" /FeatureName:"Chess" /FeatureName:"Shanghai" /FeatureName:"Internet Checkers" /FeatureName:"Internet Backgammon" /FeatureName:"Internet Spades" /FeatureName:"Internet Games" /FeatureName:"InboxGames" /FeatureName:"More Games"

rem +useful components
"%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"TelnetClient" /FeatureName:"TFTP"
rem "%SystemRoot%\System32\Dism.exe" /Online /NoRestart /Enable-Feature /FeatureName:"TelnetServer" /FeatureName:"ScanManagementConsole" /FeatureName:"Printing-XPSServices-Features" /FeatureName:"TIFFIFilter"

EXIT /B
)
