@REM coding:OEM
IF NOT DEFINED ErrorCmd SET ErrorCmd=EXIT /B
IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd" || %ErrorCmd%
IF NOT DEFINED xln CALL "%~dp0..\find_exe.cmd" xln xln.exe || %ErrorCmd%

rem Getting DefaultUserProfile location
CALL :RegQueryExpand DefaultUserProfile "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" Default || EXIT /B
CALL :RegQueryExpand PublicUserProfile "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" Public || EXIT /B

SET HKUDStartup=%DefaultUserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\
SET HKUDDesktop=%DefaultUserProfile%\Desktop

FOR %%I IN ("%HKUDStartup%\*.*") DO IF /I "%%~nxI" NEQ "desktop.ini" DEL "%%~I"
FOR %%I IN ("%HKUDDesktop%\*.*") DO IF /I "%%~nxI" NEQ "desktop.ini" DEL "%%~I"

%exe7z% x -aoa -y -o"%DefaultUserProfile%\AppData\Roaming" -- "%~dp0default_AppDataRoaming.7z"

ATTRIB -H -R "%DefaultUserProfile%" /S /D /L
XCOPY "%~dp0..\Users\Default\*.*" "%DefaultUserProfile%" /E /I /Q /G /H /K /Y

rem XCOPY "\\Srv0\profiles$\Share\Users\Public\*.*" "%PublicUserProfile%" /E /I /Q /G /H /Y

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B

%exe7z% x -aoa -o"%TEMP%" -- "%DefaultsSource%" Users\Default
PUSHD "%TEMP%\Users\Default" && (
    XCOPY * "%DefaultUserProfile%" /E /I /Q /G /H /K /Y
    POPD
)
RD /S /Q %TEMP%\Users\Default

%exe7z% x -aoa -o"%TEMP%" -- "%DefaultsSource%" Users\Public
PUSHD "%TEMP%\Users\Public" && (
    XCOPY * "%PublicUserProfile%" /E /I /Q /G /H /K /Y
    POPD
)
RD /S /Q "%TEMP%\Users\Public"

ATTRIB +H +R "%DefaultUserProfile%\Desktop"

EXIT /B

:RegQueryExpand
    FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY %2 /v %3 %recodecmd%`) DO SET %1=%%J
    IF NOT DEFINED %1 EXIT /B 1
    SET ExpandText=%1
    SET PercentSign=%%
    SET ExpandText=%PercentSign%%ExpandText%%PercentSign%
    
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %ExpandText%`) DO SET %1=%%I
EXIT /B
