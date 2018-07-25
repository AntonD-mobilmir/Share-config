@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF NOT DEFINED ErrorCmd SET "ErrorCmd=EXIT /B"
)
(
    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || %ErrorCmd%
    IF NOT DEFINED xln CALL "%~dp0..\find_exe.cmd" xln xln.exe || %ErrorCmd%

    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    IF NOT DEFINED DefaultsSource EXIT /B

    rem Getting DefaultUserProfile location
    CALL :RegQueryExpand DefaultUserProfile "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" Default || EXIT /B
    CALL :RegQueryExpand PublicUserProfile "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" Public || EXIT /B
)
(
    SET "HKDUStartup=%DefaultUserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    SET "HKDUDesktop=%DefaultUserProfile%\Desktop"
)
(
    FOR %%I IN ("%HKDUStartup%\*.*") DO IF /I "%%~nxI" NEQ "desktop.ini" DEL "%%~I"
    FOR %%I IN ("%HKDUDesktop%\*.*") DO IF /I "%%~nxI" NEQ "desktop.ini" DEL "%%~I"
)
(
    ATTRIB -H -R "%DefaultUserProfile%" /S /D /L
    DEL /F "%DefaultUserProfile%\Desktop\дополнительные ярлыки.lnk"
    DEL /F "%DefaultUserProfile%\Desktop\Установить 1С (создать ярлыки).ahk"
    DEL /F "%DefaultUserProfile%\Desktop\дополнительные ярлыки.lnk"
    DEL /F "%DefaultUserProfile%\Desktop\Обмен.lnk"
    DEL /F "%DefaultUserProfile%\Desktop\Обмен (длинный путь).lnk"
    DEL /F "%DefaultUserProfile%\Desktop\Установить 1С (создать ярлыки).ahk"

    RD /S /Q "%DefaultUserProfile%\Desktop\Документы"
    RD /S /Q "%DefaultUserProfile%\Desktop\Документы (длинный путь)"
    RD /S /Q "%DefaultUserProfile%\Desktop\Обмен"
    RD /S /Q "%DefaultUserProfile%\Desktop\Обмен (длинный путь)"
    RD /S /Q "%DefaultUserProfile%\AppData\Roaming\Opera"
    RD /S /Q "%DefaultUserProfile%\AppData\Roaming\DefaultUserRegistrySettings.7z"
    
    RD /S /Q "%DefaultUserProfile%\AppData\Local\mobilmir.ru"
    
    XCOPY "%~dp0..\..\Users\Default\*.*" "%DefaultUserProfile%" /E /I /Q /G /H /K /Y

    %exe7z% x -aoa -y -o"%DefaultUserProfile%\AppData\Roaming" -- "%~dp0default_AppDataRoaming.7z"
    rem XCOPY "\\Srv0\profiles$\Share\Users\Public\*.*" "%PublicUserProfile%" /E /I /Q /G /H /Y

    RD /S /Q "%TEMP%\Users"
    %exe7z% x -aoa -y -o"%TEMP%" -- "%DefaultsSource%" "Users\Default" "Users\Public"
    PUSHD "%TEMP%\Users\Default" && (
	XCOPY * "%DefaultUserProfile%" /E /I /Q /G /H /K /Y
	POPD
    )
    PUSHD "%TEMP%\Users\Public" && (
	XCOPY * "%PublicUserProfile%" /E /I /Q /G /H /K /Y
	POPD
    )
    RD /S /Q "%TEMP%\Users"
    ATTRIB +H +R "%DefaultUserProfile%\Desktop"
EXIT /B
)
:RegQueryExpand
(
    SETLOCAL ENABLEEXTENSIONS
    SET "var="
    FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY %2 /v %3`) DO SET "var=%%~J"
    IF NOT DEFINED var EXIT /B 1
)
(
    ENDLOCAL
    FOR /F "usebackq delims=" %%I IN (`ECHO %var%`) DO SET "%~1=%%~I"
EXIT /B
)
