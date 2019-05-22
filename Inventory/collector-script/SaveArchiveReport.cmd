@(REM coding:CP866
REM Configuration and security policy collecting script
REM using WinAudit (FOSS)
REM Script by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

    SET "fnametime=%TIME::=%"
    
    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    
    IF DEFINED OS64Bit ( SET "smartctlexe=smartctl-64.exe" ) ELSE ( SET "smartctlexe=smartctl-32.exe" )
    IF NOT DEFINED exe7z IF DEFINED OS64Bit IF EXIST "%~dp07za64.exe" SET exe7z="%~dp07za64.exe"
    IF NOT DEFINED exe7z IF EXIST "%~dp07za.exe" ( SET exe7z="%~dp07za.exe" ) ELSE ( CALL :find7zexe || CALL :no7zip )
    
    FOR /F "usebackq tokens=1 delims=[]" %%A IN (`%SystemRoot%\System32\find.exe /n "-!!! list of WMI paths to request" "%~0"`) DO SET "WMIListSkipLines=skip=%%A"
    FOR /F "usebackq tokens=1,2*" %%A IN (`reg.exe query HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1 /v "ClientID" /reg:32`) DO IF "%%A"=="ClientID" SET /A "tvID=%%~C"
    rem /reg:32 won't work on Vista and XP, so fall back
    IF ERRORLEVEL 1 FOR /F "usebackq tokens=1,2*" %%A IN (`reg.exe query HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1 /v "ClientID"`) DO IF "%%A"=="ClientID" SET /A "tvID=%%~C"
)
(
    ECHO Y|DEL /F /Q "%TEMP%\%~n0\TempWmicBatchFile.bat"
    RD "%TEMP%\%~n0" 2>NUL
    IF EXIST "%TEMP%\%~n0" (
	IF "%RunInteractiveInstalls%"=="0" EXIT /B 127
	ECHO Папка "%TEMP%\%~n0" существует. Возможно, в данный момент выполняется другой процесс аудита.
	ECHO Нажмите любую клавишу для попытки полного удаления этой папки.
	PAUSE
	RD /S /Q "%TEMP%\%~n0"
    )

    REM %TIME% не всегда возвращает 2 цифры часов
    SET "datetime=%DATE:~-4,4%%DATE:~-7,2%%DATE:~-10,2%_%fnametime:~,6%"

    
    FOR %%A IN ("%srcpath%bin.7z" "%srcpath%WinAudit.7z") DO IF EXIST "%%~A" (%exe7z% x -o"%TEMP%\%~n0" -- "%%~A" & SET "%%~nADir=%TEMP%\%~n0\")
    
    REM not using %COMPUTERNAME% because it's always uppercase
    FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
    IF NOT DEFINED Hostname SET "Hostname=%COMPUTERNAME%"
    
    IF EXIST "%srcpath%..\new-unsorted-reports" (
	SET "ReportPath=%srcpath%..\new-unsorted-reports"
    ) ELSE SET "ReportPath=%srcpath%Reports"
    
    IF DEFINED tvID SET "fnametvID=TVID=%tvID% "

    IF NOT EXIST "%TEMP%\%~n0" MKDIR "%TEMP%\%~n0"
)
(
    PUSHD "%TEMP%\%~n0" && (
	CALL :RunInBackground "%~dp0SaveJsonFingerprint.cmd" "%TEMP%\%~n0"
	
	rem Security included to full WinAudit report
	rem     secedit.exe /export /CFG "SecurityPolicy-%Hostname%.inf"
	rem     secedit.exe /export /mergedpolicy /CFG "SecurityPolicy-ADMerged-%Hostname%.inf"
	CALL :RunInBackground "%WinAuditDir%WinAudit.exe" /r=goPNtzabMpmid /f="%TEMP%\%~n0\Short WinAudit %Hostname% macaddress.csv" /l="short-%Hostname%-log"
	CALL :RunInBackground "%WinAuditDir%WinAudit.exe" /r=gsoPxuTUeERNtnzDaIbMpmidcSArHG /f="%TEMP%\%~n0\Full WinAudit %Hostname% macaddress.html" /l="full-html-%Hostname%-log"
	CALL :RunInBackground "%WinAuditDir%WinAudit.exe" /r=gsoPxuTUeERNtnzDaIbMpmidcSArHG /f="%TEMP%\%~n0\Full WinAudit %Hostname% macaddress.csv" /l="full-csv-%Hostname%-log"
	
	rem winaudit switches:
	rem g	Include System Overview
	rem s	Include Installed Software
	rem o	Include Operating System (Small letter o)
	rem P	Include Peripherals
	rem x	Include Security
	rem u	Include Groups and Users
	rem T	Include Scheduled Tasks
	rem U	Include Uptime Statistics
	rem e	Include Error Logs
	rem E	Include Environment Variables
	rem R	Include Regional Settings
	rem N	Include Windows Network
	rem t	Include Network TCP/IP
	rem z	Include Devices
	rem D	Include Display Capabilities
	rem a	Include Display Adapters
	rem I	Include Installed Printers (Capital I )
	rem b	Include BIOS Version
	rem M	Include System Management
	rem p	Include Processor
	rem m	Include Memory
	rem i	Include Physical Disks
	rem d	Include Drives
	rem c	Include Communication Ports
	rem S	Include Startup Programs
	rem A	Include Services
	rem r	Include Running Programs
	rem C	Include ODBC Information
	rem O	Include OLE DB Drivers (Capital O)
	rem H	Include Software Metering
	rem G	Include User Logon Statistics
	
	FOR /F "usebackq tokens=1" %%I IN (`"%binDir%%smartctlexe%" --scan`) DO "%binDir%%smartctlexe%" -s on -x %%I >"%%~nI-smart.txt" 2>"%%~nI-smart.log"
	IF DEFINED tvID (ECHO %tvID%)>"TVID.txt"
	FOR /F "usebackq %WMIListSkipLines% tokens=1* delims=	" %%A IN ("%~0") DO ECHO.|"%SystemRoot%\System32\Wbem\wmic.exe" path %%A get %%B >>wmi-description.txt 2>&1
	
	ECHO Waiting for background processes to finish...
	DIR /B "%TEMP%\%~n0\*.lock"
:waitBackgroundProcesses
	DEL "%TEMP%\%~n0\*.lock" & IF EXIST "%TEMP%\%~n0\*.lock" PING 127.0.0.1 -n 3 >NUL & GOTO :waitBackgroundProcesses
	ECHO All locks released.
	DEL smartctl-32.exe smartctl-64.exe smartmontools.url WinAudit.exe "WinAudit - Home.url" AutoHotkey.exe
	FOR %%I IN (*.log) DO IF "%%~zI"=="0" ECHO.|DEL %%I
	FOR %%A IN ("%TEMP%\%~n0\*.*") DO IF %%~zA EQU 0 ECHO.|DEL "%%~A"
	%exe7z% a -mx=9 -m0=LZMA2:a=2:d26:fb=273 -- "%ReportPath%\%Hostname% %fnametvID%%datetime%.7z" *.html *.csv *.txt *.inf *.json *.log && DEL *.html *.csv *.txt *.inf *.json *.log
	POPD
	RD /Q "%TEMP%\%~n0"
    )
    EXIT /B
)

:RunInBackground
@SET "lock=%~nx1-%RANDOM%-%RANDOM%-%RANDOM%.lock"
@(
    START "" /B %comspec% /C "%* >"%TEMP%\%~n0\%lock%""
EXIT /B
)

:no7zip
(
    ECHO 7-Zip не найден, продолжить не получится.
    PING 127.0.0.1 -n 15 >NUL
EXIT /B %ERRORLEVEL%
)
:find7zexe
(
    IF EXIST "%~dp0..\..\config\_Scripts\find7zexe.cmd" (
	CALL "%~dp0..\..\config\_Scripts\find7zexe.cmd"
	EXIT /B
    )
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString"`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B

    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"

    IF EXIST "%~dp0..\..\config\_Scripts\find_exe.cmd" (
	SET find_execmd="%~dp0..\..\config\_Scripts\find_exe.cmd"
    ) ELSE SET "find_execmd=:findexesimple"
)
(
    CALL %find_execmd% exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe"
    IF ERRORLEVEL 1 IF DEFINED OS64Bit CALL %find_execmd% exe7z 7za64.exe
    IF ERRORLEVEL 1 CALL %find_execmd% exe7z 7za.exe || (ECHO  & EXIT /B 9009)
EXIT /B
)
:checkDirFrom1stArg <arg1> <anything else>
(
    CALL :Check7zDir "%~dp1"
EXIT /B
)
:Check7zDir <dir>
    IF NOT "%~1"=="" SET "dir7z=%~1"
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
(
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" <NUL >NUL 2>&1 || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B
)
:findexesimple
    (
    SET "locvar=%~1"
    SET "seekforexecfname=%~2"
    )
    :findexeNextPath
    (
	IF "%~3" == "" GOTO :testexe
	REM previous line causes attempt to exec %2 and EXIT /B 9009 to original caller
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
	SHIFT
    GOTO :findexeNextPath
    )
    :testexe
    (
	IF "%~2"=="" EXIT /B 9009
	IF NOT EXIST "%~dp2" EXIT /B 9009
	"%~2" >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %1=%2
    )
EXIT /B

rem http://msdn.microsoft.com/en-us/library/aa394388.aspx
rem http://msdn.microsoft.com/en-us/library/aa394105.aspx
rem old list of WMI paths to request
Win32_ComputerSystemProduct	Name,Vendor,Version
Win32_ComputerSystemProduct	IdentifyingNumber
Win32_ComputerSystemProduct	UUID
Win32_BaseBoard	Manufacturer,Model,Name,OtherIdentifyingInfo,PartNumber,Product,SerialNumber,Version
Win32_Processor	Caption,Manufacturer,Name,ProcessorId,SocketDesignation
Win32_NetworkAdapterConfiguration where "MACAddress is not null"	Caption,IPAddress,MACAddress

rem -!!! list of WMI paths to request
Win32_ComputerSystemProduct
Win32_BaseBoard
Win32_Processor
Win32_NetworkAdapterConfiguration where "MACAddress is not null"
Win32_PhysicalMedia
Win32_PhysicalMemory
Win32_Account
Win32_OperatingSystem
Win32_Share
Win32_UserAccount
Win32_DiskDrive
Win32_BIOS
Win32_SystemBIOS
Win32_DeviceBus
Win32_NetworkAdapter where "MACAddress is not null"
