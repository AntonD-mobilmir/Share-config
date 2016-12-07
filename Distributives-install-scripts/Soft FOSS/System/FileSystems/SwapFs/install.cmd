@REM coding:OEM

IF NOT DEFINED exe7z CALL :findexe exe7z 7za.exe || CALL :findexe exe7z 7z.exe C:\Arc\7-Zip\7z.exe "%~d0\Distributives\Soft\PreInstalled\utils\7za.exe" "d:\Distributives\Soft\PreInstalled\utils\7za.exe" "W:\Distributives\Soft\PreInstalled\utils\7za.exe" || PAUSE

%exe7z% e -aou -y -o"%SystemRoot%\System32\drivers" -i!swapfs-3.0\swapfs.reg -i!swapfs-3.0\sys\obj\fre\i386\swapfs.sys -- "%~dp0swapfs-3.0.zip"
regedit /s "%SystemRoot%\System32\drivers\swapfs.reg"
SC START SwapFS || PAUSE

EXIT /B

:findexe
    REM %1 variable which will get location
    REM %2 executable file name
    REM %3... additional paths with filename (including masks) to look through

    REM ERRORLEVEL 3 The system cannot find the path specified.
    REM ERRORLEVEL 9009 'test.exe' is not recognized as an internal or external command, operable program or batch file.
    SET locvar=%1
    SET seekforexecfname=%~2

    CALL :testexe %locvar% %2
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    IF DEFINED srcpath IF EXIST "%srcpath%" CALL :testexe %locvar% "%srcpath%%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    IF DEFINED utilsdir IF EXIST "%utilsdir%" CALL :testexe %locvar% "%utilsdir%%seekforexecfname%"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    IF EXIST "\\Srv0\Distributives\Soft\PreInstalled\utils\" CALL :testexe %locvar% "\\Srv0\Distributives\Soft\PreInstalled\utils\%seekforexecfname%"
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
