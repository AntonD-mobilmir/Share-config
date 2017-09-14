@(REM coding:CP866
    REM by LogicDaemon <www.logicdaemon.ru>
    REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    ECHO OFF
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF EXIST "d:\Distributives\Soft\PreInstalled\utils\" (
	SET "utilsdir=d:\Distributives\Soft\PreInstalled\utils\"
    ) ELSE (
	SET "utilsdir=\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\"
    )
    SET "lProgramFiles=%ProgramFiles(x86)%"
    IF NOT DEFINED lProgramFiles SET "lProgramFiles=%ProgramFiles%"
    
    SET "dir1SBin=D:\1S\1Cv77\BIN"
    SET "commonRarusDir=D:\1S\Rarus"
    SET "ShopBTS_InitialBase_archive=ShopBTS_InitialBase*.7z"

    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
)
(
    CALL :GetDir ConfigDir %DefaultsSource%
    SET "link1SBin=%lProgramFiles%\1Cv77\BIN"
    SET "rarusConfigbaseDir=%commonRarusDir%\ShopBTS"

    FOR %%I IN ("%srcpath%D_1S_Rarus_ShopBTS\%ShopBTS_InitialBase_archive%") DO SET "ShopBTS_InitialBase_archive=%%~fI"
)
(
    MKDIR "%commonRarusDir%"
    PUSHD "%commonRarusDir%" && (
	rem     XCOPY "%srcpath%D_1S_Rarus_ShopBTS" "%commonRarusDir%" /D /E /C /Y ||PAUSE
	XCOPY "%srcpath%D_1S_Rarus_ShopBTS\*.reg" "%commonRarusDir%" /D /E /C /Y
	XCOPY "%srcpath%D_1S_Rarus_ShopBTS\backup to temp.cmd" "%commonRarusDir%" /Q /Y
	POPD
    )
)
IF NOT DEFINED utilsdir SET "utilsdir=\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\"
:find7zagain
IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd" || CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\find7zexe.cmd" || (
    ECHO 7-Zip не найден, нажмите любую клавишу для повторной попытки поиска.
    PAUSE
    GOTO :find7zagain
)
IF NOT DEFINED xlnexe CALL "%ConfigDir%_Scripts\find_exe.cmd" xlnexe xln.exe || (
    ECHO xln.exe не найден, нажмите любую клавишу для повторной попытки поиска.
    PAUSE
    GOTO :find7zagain
)
ECHO ON
%exe7z% x -aoa -o"%ProgramData%\mobilmir.ru" -- "%srcpath%Rarus_Scripts.7z"
%exe7z% x -aoa -o"%dir1SBin%" -- "%srcpath%1Cv77_BIN.7z"
MKDIR "%link1SBin%" & %xlnexe% -n "%dir1SBin%" "%link1SBin%"

REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%link1SBin%\1cv7s.exe" /d "DisableNXShowUI" /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%dir1SBin%\1cv7s.exe" /d "DisableNXShowUI" /f
START "Registring components in %dir1SBin%" /WAIT /I /D "%dir1SBin%" %comspec% /C "%dir1SBin%\register_all_components.cmd"

IF NOT EXIST "%rarusConfigbaseDir%" (
    %exe7z% x -r -y -o"%rarusConfigbaseDir%" -- "%srcpath%D_1S_Rarus_ShopBTS\ShopBTS_Add_DLLs.7z"||PAUSE
    %exe7z% x -r -y -o"%rarusConfigbaseDir%" -- "%srcpath%D_1S_Rarus_ShopBTS\ShopBTS_Add_Utils.7z"||PAUSE
    %exe7z% x -r -y -o"%rarusConfigbaseDir%" -- "%srcpath%D_1S_Rarus_ShopBTS\ShopBTS_Add.7z"||PAUSE
    %exe7z% x -r -y -o"%rarusConfigbaseDir%" -- "%ShopBTS_InitialBase_archive%"||PAUSE
    START "Registring components in %rarusConfigbaseDir%" /MIN /I /D "%rarusConfigbaseDir%" %comspec% /C "%rarusConfigbaseDir%\register_all_components.cmd"
    PING 127.0.0.1 -n 15>NUL
    %exe7z% x -r -y -o"%rarusConfigbaseDir%\Exchange" -- "%srcpath%Exchange.7z"
)

%exe7z% x -r -y -o"%SystemRoot%" "%srcpath%SystemRoot.7z"
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SystemRoot%\Eutron\Eutron.exe" /d "DisableNXShowUI" /f
START "Installing Eutron drivers" /D"%SystemRoot%\Eutron" /B /WAIT "%SystemRoot%\Eutron\eutron.exe"

CALL "%srcpath%_shedule_backup1Sbase.cmd"
CALL "%srcpath%_shedule_rsend_queue.cmd"

EXIT /B

:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
