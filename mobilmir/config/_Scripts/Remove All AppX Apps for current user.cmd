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
Microsoft.AAD.BrokerPlugin_*
Microsoft.AccountsControl_*
Microsoft.Appconnector_*
Microsoft.BioEnrollment_*
Microsoft.LockApp_*
Microsoft.MicrosoftEdge_*
Microsoft.NET.*
Microsoft.Reader_*
Microsoft.VCLibs.*
;Microsoft.Windows.AssignedAccessLockApp_*
;Microsoft.Windows.CloudExperienceHost_*
;Microsoft.Windows.ContentDeliveryManager_*
Microsoft.Windows.Cortana_*
Microsoft.Windows.ShellExperienceHost_*
Microsoft.WindowsAlarms_*
Microsoft.WindowsCalculator_*
Microsoft.WindowsCamera_*
Microsoft.WindowsScan_*
Microsoft.WindowsSoundRecorder_*
windows.*
