@(REM coding:CP866
REM wget_the_site script
REM downloads and archives a site for viewing offline
REM uses wget and 7-zip
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED srcpath (
    ECHO Без указания srcpath скрипт не работает. srcpath --- это расположение папки для загрузки, она же папка с архивом
    EXIT /B 1
)
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF DEFINED RARopts ECHO Переменная RARopts определена, но не работает в этой версии скрипта! Используйте %%noarchmasks%% чтобы указать маски файлов для исключения их архива.>&2 & EXIT /B 1
IF DEFINED RARmoredirs ECHO Переменная RARmoredirs определена, но не работает в этой версии скрипта! Используйте %%moreDirs%%.>&2 & EXIT /B 1

SET "sitename=%~1"
IF "%~2"=="" (
  SET "URL=http://%sitename%/"
) ELSE SET "URL=%~2"
SET "wgetcommonopt=-m -w 2 --random-wait --waitretry=300 -x -E -e robots=off -k -K -p -np --no-check-certificate --progress=dot:giga"
REM %3 and further may be used to spec additional argiments, like
REM -X"dir1,dir2" - directory exclusion
REM -w N  -  wait N seconds between pages
REM -nd, --no-directories           don't create directories.
REM -x,  --force-directories        force creation of directories.
REM -nH, --no-host-directories      don't create host directories.
REM      --protocol-directories     use protocol name in directories.
REM -P,  --directory-prefix=PREFIX  save files to PREFIX/...
REM      --cut-dirs=NUMBER          ignore NUMBER remote directory components.
REM -c		### contunue downloading files
REM -a wget.log	### write all output to that log
REM -t 64	### 64 retries
REM -N		### use timestamping
REM -R,  --reject=LIST               comma-separated list of rejected extensions.
REM -H - host spanning
REM -D%* hosts to span across; when host spanning (-H) off, -D is meaningless

IF NOT DEFINED exe7z CALL :find7zexe
IF NOT DEFINED wgetexe CALL :findexe wgetexe wget.exe "%SystemDrive%\SysUtils\wget.exe"

CALL :parseMasks %noarchmasks%
)
(
    IF EXIST "%srcpath%%sitename%.7z" (
	%exe7z% x -aoa -o"%srcpath%" -- "%srcpath%%sitename%.7z"
    ) ELSE IF EXIST "%srcpath%%sitename%.rar" %exe7z% x -aoa -o"%srcpath%" -- "%srcpath%%sitename%.rar"

    SHIFT
    SHIFT
    START "" /b /wait /D"%srcpath%" wget.exe %wgetcommonopt% %URL% %1 %2 %3 %4 %5 %6 %7 %8 %9
    START "" /b /wait /D"%srcpath%" %exe7z% a -sdel -r %opts7z% -- "%sitename%.7z" "%sitename%" %moreDirs%

EXIT /B
)

:parseMasks <masks>
(
    IF "%~1"=="" EXIT /B
    SET opts7z=%opts7z% -xr!"%~1"
    SHIFT
GOTO :parseMasks
)

:find7zexe
(
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve /reg:64`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B

    CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" || (ECHO  & EXIT /B 9009)
EXIT /B
)

:checkDirFrom1stArg <arg1> <anything else>
    CALL :Check7zDir "%~dp1"
EXIT /B

:Check7zDir <dir>
    IF NOT "%~1"=="" SET "dir7z=%~1"
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" >NUL 2>&1 <NUL || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B

:findexe
    (
    SET locvar=%1
    )
    (
    REM checking simplest variant -- when executable in in %PATH%
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3"=="" GOTO :testexe
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
	SHIFT /3
    GOTO :findexeNextPath
    )
    :testexe
    (
	IF "%~2"=="" EXIT /B 9009
	IF NOT EXIST "%~dp2" EXIT /B 9009
	"%~2" <NUL >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %1=%2
    )
EXIT /B

rem Пример скрипта
@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "noarchmasks=*.exe *.zip *.gz *.bz2 *.rar"
SET "moreDirs="
)
CALL "%ProgramData%\mobilmir.ru\Common_Scripts\wget_the_site.cmd" 