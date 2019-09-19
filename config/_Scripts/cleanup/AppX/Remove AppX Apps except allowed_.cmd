@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

FOR /F "usebackq tokens=1 delims=[]" %%A IN (`find /n "-!!! exceptions list: -" "%~f0"`) DO SET "InlineListSkipLines=skip=%%A"
REM Get-AppXPackage uses PackageFullName or PackageFamilyName
SET "UserExceptList=where-object {$_.PackageFullName -notlike 'windows.*' "
REM Get-AppxProvisionedPackage uses PackageName
SET "ProvExceptList=where-object {$_.PackageName -notlike 'windows.*' "
)

:CheckNextArg
(
    IF /I "%~1"=="/Quiet" ( SET "quiet=1"
    ) ELSE IF /I "%~1"=="/CurrentUserOnly" ( SET "onlyCU=1"
    ) ELSE IF /I "%~1"=="/firstlogon" ( SET "onlyCU=1" )
    IF NOT "%~2"=="" (
	SHIFT
	GOTO :CheckNextArg
    )
)

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
FOR /F "usebackq %InlineListSkipLines% eol=; tokens=*" %%A IN ("%~f0") DO (
    SET "UserExceptList=!UserExceptList! -and $_.PackageFullName -notlike '%%~A'"
    SET "ProvExceptList=!ProvExceptList! -and $_.PackageName -notlike '%%~A'"
)
(
ENDLOCAL
SET "UserExceptList=%UserExceptList% }"
SET "ProvExceptList=%ProvExceptList% }"
)

(
    IF NOT "%onlyCU%"=="1" (
	IF NOT "%quiet%"=="1" (
	    powershell.exe -command "Get-AppXPackage -Allusers | %UserExceptList% | Format-Table -Property PackageFullName"||EXIT /B
	    ECHO При продолжении, указанные выше AppX будут удалены у всех пользователей.
	    PAUSE
	)
	powershell.exe -command "Get-AppXPackage -Allusers | %UserExceptList% | Remove-AppxPackage -Verbose"

	IF NOT "%quiet%"=="1" (
	    powershell.exe -command "Get-AppxProvisionedPackage -online | %ProvExceptList% | Format-Table -Property PackageName"||EXIT /B
	    ECHO При продолжении, указанные выше AppX будут удалены из системы.
	    PAUSE
	)
	powershell.exe -command "Get-AppxProvisionedPackage -online | %ProvExceptList% | Remove-AppxProvisionedPackage -online"
    )

    IF NOT "%quiet%"=="1" (
	powershell.exe -command "Get-AppXPackage | %UserExceptList% | Format-Table -Property PackageFullName"||EXIT /B
	ECHO При продолжении, указанные выше AppX будут удалены у текущего пользователя.
	PAUSE
    )
    powershell.exe -command "Get-AppXPackage | %UserExceptList% | Remove-AppxPackage -Verbose"
EXIT /B
)

REM https://www.reddit.com/r/pcmasterrace/comments/34qzni/how_to_remove_xbox_integration_in_latest_windows/
REM http://www.thewindowsclub.com/erase-default-preinstalled-modern-apps-windows-8
REM http://stackoverflow.com/questions/6037146/how-to-execute-powershell-commands-from-a-batch-file
REM https://dmitrysotnikov.wordpress.com/2008/06/27/powershell-script-in-a-bat-file/

REM http://winaero.com/blog/how-to-remove-all-bundled-apps-in-windows-10/
REM remove from system account: Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage -online
REM remove all Modern apps from your current user account: Get-AppXPackage | Remove-AppxPackage
REM remove for specific user: Get-AppXPackage -User <username> | Remove-AppxPackage
REM for all users: Get-AppxPackage -AllUsers | Remove-AppxPackage

REM http://winaero.com/blog/how-to-restore-windows-store-in-windows-10-after-removing-it-with-powershell/
REM Get-Appxpackage -Allusers
REM Add-AppxPackage -register "C:\Program Files\WindowsApps\******\AppxManifest.xml" -DisableDevelopmentMode
REM ex: Add-AppxPackage -register "C:\Program Files\WindowsApps\Microsoft.WindowsStore_8wekyb3d8bbwe\AppxManifest.xml" -DisableDevelopmentMode

REM https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/169
REM 1527c705-839a-4832-9118-54d4Bd6a0c89	Microsoft.Windows.FilePicker
REM c5e2524a-ea46-4f67-841f-6a9465d9d515	Microsoft.Windows.FileExplorer
REM E2A4F912-2574-4A75-9BB0-0D023378592B	Microsoft.Windows.AppResolverUX
REM F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE	Microsoft.Windows.AppSuggestedFoldersToLibraryDialog

REM also https://docs.microsoft.com/en-us/windows/configuration/mobile-devices/product-ids-in-windows-10-mobile

REM -!!! exceptions list: -
1527c705-839a-4832-9118-54d4Bd6a0c89_*
c5e2524a-ea46-4f67-841f-6a9465d9d515_*
E2A4F912-2574-4A75-9BB0-0D023378592B_*
F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE_*
InputApp_*
Microsoft.3DBuilder_*
Microsoft.AAD.BrokerPlugin_*
Microsoft.AccountsControl_*
Microsoft.Appconnector_*
Microsoft.AsyncTextService_*
Microsoft.BingFinance_*
Microsoft.BingFoodAndDrink_*
Microsoft.BingHealthAndFitness_*
Microsoft.BingNews_*
Microsoft.BingSports_*
Microsoft.BingWeather_*
Microsoft.BioEnrollment_*
Microsoft.CommsPhone_*
Microsoft.CredDialogHost_*
Microsoft.DesktopAppInstaller_*
Microsoft.ECApp_*
Microsoft.GetHelp_*
Microsoft.Getstarted_*
Microsoft.HEIFImageExtension_*
Microsoft.Language*
Microsoft.LockApp_*
Microsoft.Messaging_*
Microsoft.Microsoft3DViewer_*
Microsoft.MicrosoftEdge_*
Microsoft.MicrosoftEdgeDevToolsClient_*
Microsoft.MicrosoftOfficeHub_*
Microsoft.MicrosoftStickyNotes_*
Microsoft.MixedReality.Portal_*
Microsoft.MovieMoments_*
Microsoft.MSPaint_*
Microsoft.NET.*
Microsoft.Office.OneNote_*
Microsoft.Office.Sway_*
Microsoft.OneConnect_*
Microsoft.People_*
Microsoft.PPIProjection_*
Microsoft.Print3D_*
Microsoft.Reader_*
Microsoft.ScreenSketch_*
Microsoft.Services.Store.Engagement_*
Microsoft.SkypeApp_*
Microsoft.StorePurchaseApp_*
Microsoft.UI.Xaml.*
Microsoft.VCLibs.*
Microsoft.VP9VideoExtensions_*
Microsoft.Wallet_*
Microsoft.WebMediaExtensions_*
Microsoft.WebpImageExtension_*
Microsoft.WelcomeScreen_*
Microsoft.Win32WebViewHost_*
Microsoft.Windows*
Microsoft.WinJS.*
Microsoft.YourPhone_*
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
CyberLinkCorp.th.Power2GoforLenovo_*
CyberLinkCorp.th.PowerDVDforLenovo_*
AppUp.IntelGraphicsControlPanel_*
