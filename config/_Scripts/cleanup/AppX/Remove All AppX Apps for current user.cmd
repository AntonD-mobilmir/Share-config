@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

FOR /F "usebackq tokens=1 delims=[]" %%A IN (`find /n "-!!! exceptions list: -" "%~f0"`) DO SET InlineListSkipLines=skip=%%A
REM Get-AppXPackage uses PackageFullName or PackageFamilyName
SET UserExceptList=where-object {$_.PackageFullName -notlike 'windows.*' 
)

:CheckNextArg
(
    IF /I "%~1"=="/quiet" SET "quiet=1"
    IF /I "%~1"=="/firstlogon" CALL :firstlogon||EXIT /B
    IF NOT "%~2"=="" (
	SHIFT
	GOTO :CheckNextArg
    )
)

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
FOR /F "usebackq %InlineListSkipLines% eol=; tokens=*" %%A IN ("%~f0") DO (
    SET UserExceptList=!UserExceptList! -and $_.PackageFullName -notlike '%%~A'
    SET ProvExceptList=!ProvExceptList! -and $_.PackageName -notlike '%%~A'
)
(
ENDLOCAL
SET UserExceptList=%UserExceptList% }
SET ProvExceptList=%ProvExceptList% }
)

(
    IF NOT "%quiet%"=="1" (
	powershell.exe -command "Get-AppXPackage | %UserExceptList% | Format-Table -Property PackageFullName"||EXIT /B
	ECHO При продолжении, указанные выше AppX будут удалены у текущего пользователя.
	PAUSE
    )
    powershell.exe -command "Get-AppXPackage | %UserExceptList% | Remove-AppxPackage -Verbose"
    EXIT /B
)

:firstlogon
(
    SET "quiet=1"
    rem Специальные пользователи --- либо общие, либо приложения AppX всё равно не нужны
    IF /I "%USERNAME%"=="Install" EXIT /B 0
    IF /I "%USERNAME%"=="Administrator" EXIT /B 0
    IF /I "%USERNAME%"=="Admin" EXIT /B 0
    IF /I "%USERNAME%"=="Guest" EXIT /B 0
    rem Если в имени пользователя есть русские буквы, это общий пользователь
    SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    FOR %%A IN (а б в г д е ё ж з и й к л м н о п р с т у ф х ц ч ш щ ъ ы ь э ю я) DO IF NOT "!USERNAME:%%A=!"=="%USERNAME%" EXIT /B 0
    ENDLOCAL
EXIT /B 1
)

REM -!!! exceptions list: -
;Microsoft.WindowsStore_*
1527c705-839a-4832-9118-54d4Bd6a0c89_*
c5e2524a-ea46-4f67-841f-6a9465d9d515_*
E2A4F912-2574-4A75-9BB0-0D023378592B_*
F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE_*
InputApp_*
Microsoft.AAD.BrokerPlugin_*
Microsoft.AccountsControl_*
Microsoft.Appconnector_*
Microsoft.AsyncTextService_*
Microsoft.BioEnrollment_*
Microsoft.CredDialogHost_*
Microsoft.DesktopAppInstaller_*
Microsoft.ECApp_*
Microsoft.GetHelp_*
Microsoft.Getstarted_*
Microsoft.HEIFImageExtension_*
Microsoft.Language*
Microsoft.LockApp_*
Microsoft.Microsoft3DViewer_*
Microsoft.MicrosoftEdge_*
Microsoft.MicrosoftEdgeDevToolsClient_*
Microsoft.MicrosoftStickyNotes_*
Microsoft.MSPaint_*
Microsoft.NET.*
Microsoft.Office.OneNote_*
Microsoft.PPIProjection_*
Microsoft.Reader_*
Microsoft.ScreenSketch_*
Microsoft.UI.Xaml.*
Microsoft.VCLibs.*
Microsoft.VP9VideoExtensions_*
Microsoft.Wallet_*
Microsoft.WebMediaExtensions_*
Microsoft.WebpImageExtension_*
Microsoft.Win32WebViewHost_*
Microsoft.Windows.*
Microsoft.WindowsAlarms_*
Microsoft.WindowsCalculator_*
Microsoft.WindowsCamera_*
Microsoft.WindowsMaps_*
Microsoft.WindowsReadingList_*
Microsoft.WindowsScan_*
Microsoft.WindowsSoundRecorder_*
Microsoft.WinJS.*
Microsoft.ZuneMusic_*
Microsoft.ZuneVideo_*
windows.*
Windows.*
Microsoft.HEVCVideoExtension_*
Microsoft.MPEG2VideoExtension_*
E046963F.LenovoCompanion_*
E046963F.LenovoUtility_*
E0469640.LenovoUtility_*
*.LenovoUtility_*
AppUp.IntelGraphicsControlPanel_*
