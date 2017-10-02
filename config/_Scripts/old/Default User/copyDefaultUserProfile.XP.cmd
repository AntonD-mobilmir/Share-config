@REM coding:OEM
IF NOT DEFINED ErrorCmd SET ErrorCmd=EXIT /B

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || %ErrorCmd%
IF NOT DEFINED xln CALL "%~dp0..\find_exe.cmd" xlnexe xln.exe || %ErrorCmd%
IF NOT DEFINED recodeexe CALL "%~dp0..\find_exe.cmd" recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
IF NOT DEFINED cp CALL "%~dp0..\find_exe.cmd" cp cp.exe "%SystemDrive%\SysUtils\UnxUtils\cp.exe" || %ErrorCmd%
IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe "%SystemDrive%\SysUtils\UnxUtils\cp.exe" || %ErrorCmd%
IF DEFINED recodeexe SET recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866

rem All Users Profile
CALL :RegQueryExpand HKLMStartup "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" "Common Startup"
CALL :MakeWin7PathsLinks "%ALLUSERSPROFILE%" "%HKLMStartup%"

rem Вместо копирования папок с ярлыками в Default лежит ярлык
rem XCOPY /E /C /I /Q /H /K /O  \\Srv0\profiles$\Share\Users\Common\*.* "%ALLUSERSPROFILE%"

rem Getting ProfilesDirectory, DefaultUserProfile
CALL :RegQueryExpand ProfilesDirectory "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" ProfilesDirectory || EXIT /B
CALL :RegQueryExpand DefaultUserProfile "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" DefaultUserProfile || EXIT /B
SET DefaultUserProfile=%ProfilesDirectory%\%DefaultUserProfile%

SET backupUSERPROFILE=%USERPROFILE%
SET USERPROFILE=%DefaultUserProfile%
CALL :RegQueryExpand HKUDStartup "HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" Startup
CALL :RegQueryExpand HKUDDesktop "HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" Desktop
SET USERPROFILE=%backupUSERPROFILE%

ECHO backuping of default user profile
IF NOT EXIST "%DefaultUserProfile%.org" XCOPY "%DefaultUserProfile%" "%DefaultUserProfile%.org" /E /C /I /Q /H /K /O

rem Default profile
%exe7z% x -aoa -o"%DefaultUserProfile%" -- "%~dp0Default User.xp.7z"
rem This profiles uses modified paths for Documents and Desktop
MKDIR D:\Users
rem Fixing security for new dirs
IF NOT DEFINED NoSetACL %SetACLexe% -on D:\Users -ot file -actn clear -clr dacl -actn ace -ace "n:S-1-5-11;s:y;p:FILE_ADD_SUBDIRECTORY;i:np;m:set;w:dacl"

CALL :MakeWin7PathsLinks "%DefaultUserProfile%" "%HKUDStartup%"
rem Copying Windows 7 files
ATTRIB -R "%DefaultUserProfile%" /S /D
XCOPY /E /C /I /Q /G /H /K /Y %~dp0..\Users\Default\*.* "%DefaultUserProfile%"

rem %exe7z% x -aoa -y -o"%HKUDStartup%" -- "%~dp0common_startup.7z"
%exe7z% x -aoa -y -o"%DefaultUserProfile%\Application Data" -- "%~dp0default_AppDataRoaming.7z"

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B

rem Following lines extract files to :\Users\Default\Users\Default (they add archive path to output path)
rem %exe7z% x -aoa -o"%DefaultUserProfile%" -- "%DefaultsSource%" Users\Default
rem %exe7z% x -aoa -o"%PublicUserProfile%" -- "%DefaultsSource%" Users\Public

%exe7z% x -aoa -o"%TEMP%" -- "%DefaultsSource%" Users\Default
PUSHD "%TEMP%\Users\Default" && (
    %cp% -afv * "%DefaultUserProfile%"
    POPD
)

%exe7z% x -aoa -o"%TEMP%" -- "%DefaultsSource%" Users\Public
PUSHD "%TEMP%\Users\Public" && (
    %cp% -afv * "%ProfilesDirectory%\All Users"
    POPD
)

EXIT /B

:RegQueryExpand
    FOR /F "usebackq tokens=2* delims=	" %%I IN (`REG QUERY %2 /v %3 %recodecmd%`) DO SET %1=%%J
    IF NOT DEFINED %1 EXIT /B 1
    SET ExpandText=%1
    SET PercentSign=%%
    SET ExpandText=%PercentSign%%ExpandText%%PercentSign%
    
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %ExpandText%`) DO SET %1=%%I
EXIT /B

:MakeWin7PathsLinks
    rem links for Windows 7 files make their way into Windows XP dir structure
    rem %1 - DefaultUserProfile
    rem %2 - Default User Profile Startup (HKUDStartup)
    PUSHD %1||EXIT /B
	MKDIR "AppData"
	%xlnexe% -n "Application Data" "AppData\Roaming"
	%xlnexe% -n "Local Settings\Application Data" "AppData\Local"

	MKDIR "AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
	%xlnexe% -n %2 "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
	
	CALL :CheckExistenceOrLink "Start Menu" "Главное меню"
	CALL :CheckExistenceOrLink "Start Menu\Programs" "Start Menu\Программы"
	CALL :CheckExistenceOrLink "Start Menu\Programs\Accessories" "Start Menu\Programs\Стандартные"
	CALL :CheckExistenceOrLink "Start Menu\Programs\Startup" "Start Menu\Programs\Автозагрузка"
    POPD
EXIT /B

:CheckExistenceOrLink
    IF NOT EXIST %1 IF EXIST %2 (
	%xlnexe% -n %2 %1
	ATTRIB +H %1
    )
EXIT /B
