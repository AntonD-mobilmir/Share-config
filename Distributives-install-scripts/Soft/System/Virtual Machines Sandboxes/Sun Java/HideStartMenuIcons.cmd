@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET RegQueryParsingOptions="usebackq tokens=3* delims= "
FOR /F "usebackq delims=" %%I IN (`ver`) DO SET WinVer=%%I
IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" GOTO :IncludeRecoding
IF "%WinVer:~0,22%"=="Microsoft Windows XP [" GOTO :IncludeRecoding
GOTO :SkipRecoding
:IncludeRecoding
rem     there's tab in end of next line. It's mandatory
SET RegQueryParsingOptions="usebackq tokens=2* delims=	"

IF NOT DEFINED recodeexe CALL :findexe recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
IF DEFINED recodeexe SET recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866
:SkipRecoding

FOR /F %RegQueryParsingOptions% %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Programs" %recodecmd%`) DO SET CommonPrograms=%%J
IF NOT DEFINED CommonPrograms EXIT /B
FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %CommonPrograms%`) DO SET CommonPrograms=%%I

ATTRIB +H "%CommonPrograms%\Java"

EXIT /B

:findexe
    REM %1 variable which will get location
    REM %2 executable file name
    REM %3... additional paths with filename (including masks) to look through
    REM ERRORLEVEL 3 The system cannot find the path specified.
    REM ERRORLEVEL 9009 'test.exe' is not recognized as an internal or external command, operable program or batch file.

    SET locvar=%1
    SET seekforexecfname=%~2
    
    REM checking simplest variant -- when executable in in %PATH%
    CALL :testexe %locvar% %2
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    
    REM checking paths suggestions
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    
    REM following is relative to containing-script-location
    CALL :testexe %locvar% "%srcpath%..\..\..\PreInstalled\utils\%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B

    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    CALL :testexe %locvar% "\\Srv0\Distributives\Soft\PreInstalled\utils\%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B

    :findexeNextPath
    IF "%~3" == "" GOTO :testexe
    REM previous line causes attempt to exec %2 and EXIT /B 9009 to original caller
    IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    SHIFT
    GOTO :findexeNextPath

    :testexe
    IF NOT EXIST "%~dp2" EXIT /B 9009
    %2 >NUL 2>&1
    IF NOT "%ERRORLEVEL%"=="9009" SET %1=%2
EXIT /B
