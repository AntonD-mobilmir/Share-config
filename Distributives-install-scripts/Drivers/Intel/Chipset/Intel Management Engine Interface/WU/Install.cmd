(
@REM coding:OEM
@ECHO OFF
SET "srcpath=%~dp0"
SET "localdist=d:\Distributives\Drivers\Intel\Chipset\Intel Management Engine Interface\WU"
SET "tempdst=%TEMP%\%~n0 Intel MEI"
IF NOT DEFINED ErrorCmd SET "ErrorCmd=PAUSE"
IF NOT DEFINED exe7z CALL :find7z
)
IF EXIST d:\ (
    IF NOT EXIST "%localdist%" MKDIR "%localdist%"
    XCOPY "%srcpath:~0,-1%" "%localdist%" /E /I /Y
    IF NOT ERRORLEVEL 1 SET "srcpath=%localdist%\"
)
(
SET "OSCapacity=32-bit"
IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSCapacity=64-bit"
IF "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSCapacity=64-bit"
)
(
%exe7z% e -r -o"%tempdst%" -- "%srcpath%dpinst.7z"  "dpinst.xml" "%OSCapacity%\*"||%ErrorCmd%
%exe7z% x -r -o"%tempdst%\*" -- "%srcpath%*.cab"||%ErrorCmd%
START "" /WAIT /D "%tempdst%" dpinst.exe||%ErrorCmd%
RD /S /Q "%tempdst%"
EXIT /B
)

:find7z
    IF EXIST "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\find_exe.cmd" CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\find_exe.cmd" exe7z 7z.exe || CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\find_exe.cmd" exe7z 7za.exe
    IF NOT DEFINED exe7z CALL :findexe exe7z 7z.exe || CALL :findexe exe7z 7za.exe || SET exe7z=7z.exe
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
    CALL :testexe %locvar% "%srcpath%..\..\..\..\PreInstalled\utils\%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%"
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
