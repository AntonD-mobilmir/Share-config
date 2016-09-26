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

REM -!!! exceptions list: -
;Microsoft.Advertising.Xaml_*
Microsoft.PPIProjection_*
;Microsoft.CommsPhone_*
;Microsoft.ConnectivityStore_* ;Microsoft WiFi
;Microsoft.Getstarted_*
;Microsoft.MicrosoftOfficeHub_*
;Microsoft.MicrosoftSolitaireCollection_*
;Microsoft.Office.OneNote_*
;Microsoft.Office.Sway_*
;Microsoft.SkypeApp_*
Microsoft.3DBuilder_*
Microsoft.AAD.BrokerPlugin_*
Microsoft.AccountsControl_*
Microsoft.Appconnector_*
Microsoft.BingFinance_*
Microsoft.BingNews_*
Microsoft.BingSports_*
Microsoft.BingWeather_*
;Microsoft.BingFoodAndDrink_*
;Microsoft.BingHealthAndFitness_*
Microsoft.BioEnrollment_*
Microsoft.DesktopAppInstaller_*
Microsoft.Getstarted_*
Microsoft.LockApp_*
;Microsoft.Messaging_* ;Skype messages
Microsoft.MicrosoftEdge_*
;Microsoft.MicrosoftSolitaireCollectionPreview_*
Microsoft.MicrosoftStickyNotes_*
Microsoft.MovieMoments_*
Microsoft.NET.*
;Microsoft.NET.Native.Framework.1.0_1.0.22929.0_x86__8wekyb3d8bbwe
;Microsoft.NET.Native.Runtime.1.1_1.1.23406.0_x86__8wekyb3d8bbwe
;Microsoft.OneConnect_*
Microsoft.Office.OneNote_*
Microsoft.Office.Sway_*
Microsoft.People_*
Microsoft.Reader_*
Microsoft.SkypeApp_*
Microsoft.StorePurchaseApp_*
Microsoft.VCLibs.*
Microsoft.WelcomeScreen_*
Microsoft.Windows.Apprep.ChxApp_*
Microsoft.Windows.AssignedAccessLockApp_*
Microsoft.Windows.CloudExperienceHost_*
Microsoft.Windows.ContentDeliveryManager_*
Microsoft.Windows.Cortana_*
Microsoft.Windows.Photos_*
Microsoft.Windows.ShellExperienceHost_*
Microsoft.WindowsAlarms_*
Microsoft.WindowsCalculator_*
Microsoft.WindowsCamera_*
microsoft.windowscommunicationsapps_*
;Microsoft.WindowsFeedbackHub_*
Microsoft.WindowsMaps_*
Microsoft.WindowsReadingList_*
Microsoft.WindowsScan_*
Microsoft.WindowsSoundRecorder_*
Microsoft.WindowsStore_*
Microsoft.Windows.SecureAssessmentBrowser_*
Microsoft.Windows.WindowPicker_*
;Microsoft.Windows.HolographicFirstRun_*
;Microsoft.Windows.ParentalControls_*
;Microsoft.Windows.PeopleExperienceHost_*
;Microsoft.Windows.ProximityConnectService_*
;Microsoft.Windows.SecondaryTileExperience_*
;Microsoft.WindowsFeedback_*
;Microsoft.WindowsPhone_*
;Microsoft.XboxApp_*
;Microsoft.XboxGameCallableUI_*
;Microsoft.XboxIdentityProvider_*
Microsoft.ZuneMusic_*
Microsoft.ZuneVideo_*
;windows.immersivecontrolpanel_*
windows.*
