@(REM coding:CP866
REM Script to install preinstalled and working-without-install software
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    SET "utilsdir=%~dp0..\utils\"
    IF NOT DEFINED LOCALAPPDATA CALL :DefineLocalAppData

    SET "srcBasePath=%~dpn0"
    SET "UIDCreatorOwner=S-1-3-0;s:y"
    SET "exe7zlocal="
    
    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    IF NOT DEFINED exename7za IF DEFINED OS64Bit ( SET "exename7za=7za64.exe" ) ELSE ( SET "exename7za=7za.exe" )
    IF NOT DEFINED exenameAutohotkey IF DEFINED OS64Bit ( SET "exenameAutohotkey=AutoHotkeyU64.exe" ) ELSE ( SET "exenameAutohotkey=AutoHotkey.exe" )
)
(
    IF NOT DEFINED exe7z SET exe7z="%utilsdir%%exename7za%"
    rem IF NOT DEFINED AutohotkeyExe SET AutohotkeyExe="%utilsdir%%exenameAutohotkey%"
    IF NOT DEFINED AutohotkeyExe CALL :FindAutoHotkeyExe || (CALL "%~dp0..\..\Keyboard Tools\AutoHotkey\install.cmd" & CALL :FindAutoHotkeyExe)

    SET "distNotepad2Mask=Notepad2-mod.*"
    IF DEFINED OS64Bit ( SET "Notepad2DistSuffix=_x64.zip" ) ELSE SET "Notepad2DistSuffix=_x86.zip"

    FOR %%A IN ("%~dp0..\.." "\\Srv1S-B.office0.mobilmir\Distributives\Soft" "\\Srv0.office0.mobilmir\Distributives\Soft") DO (
        SET "findMoreDist="
        IF NOT DEFINED dist7zDir SET "findMoreDist=1" & IF EXIST "%%~A\Archivers Packers\7Zip" SET "dist7zDir=%%~A\Archivers Packers\7Zip"
        IF NOT DEFINED distzpaqDir SET "findMoreDist=1" & IF EXIST "%%~A\..\Soft FOSS\Archivers Packers\zpaq" SET "distzpaqDir=%%~A\..\Soft FOSS\Archivers Packers\zpaq"
        IF NOT DEFINED distNotepad2Dir SET "findMoreDist=1" & IF EXIST "%%~A\..\Soft FOSS\Office Text Publishing\Text Documents\Notepad2\Special and Custom Editions\notepad2-mod" SET "distNotepad2Dir=%%~A\..\Soft FOSS\Office Text Publishing\Text Documents\Notepad2\Special and Custom Editions\notepad2-mod"
        
        IF NOT DEFINED findMoreDist GOTO :foundAllDist
    )
    ECHO Some distributives not found!
    ECHO dist7zDir: "%dist7zDir%"
    ECHO distzpaqDir: "%distzpaqDir%"
    ECHO distNotepad2Dir: "%distNotepad2Dir%"
)
:foundAllDist
:nextArg
@(
    IF NOT "%~1"=="" (
        SHIFT /1
        IF /I "%~1"=="/TCDir" (
            SET "TCDir=%~2"
            SHIFT /1
        ) ELSE IF /I "%~1"=="/srcBase" (
            SET "srcBasePath=%~2"
            SHIFT /1
        ) ELSE (
            ECHO Unknown argument: %1
            EXIT /B 1
        )
        GOTO :nextArg
    )
    
    IF NOT DEFINED TCDir SET "TCDir=%LOCALAPPDATA%\Programs\Total Commander"
    REM exe7z will be redefined in next CALL
    FOR /F "usebackq delims=" %%N IN (`DIR /S /B /A-D "%dist7zDir%\7z*.exe"`) DO CALL :Unpack7ZipDist "%%~N"
)
IF NOT DEFINED exe7zlocal (
    MKDIR "%TCDir%\PlugIns\wcx\Total7zip" >NUL
    ECHO N|COPY /B %exe7z% "%TCDir%\PlugIns\wcx\Total7zip\7zg.exe"
    SET exe7z="%TCDir%\PlugIns\wcx\Total7zip\7zg.exe"
    SET "exe7zlocal=2"
)
(
    %exe7z% x -aoa -y -o"%TCDir%" -- "%srcBasePath%.7z"
    IF "%exe7zlocal%"=="2" "%TCDir%\xln.exe" "%TCDir%\PlugIns\wcx\Total7zip\7zg.exe" "%TCDir%\PlugIns\wcx\Total7zip\7z.exe" || (ECHO N|COPY /B "%TCDir%\PlugIns\wcx\Total7zip\7zg.exe" "%TCDir%\PlugIns\wcx\Total7zip\7z.exe")    
    %exe7z% x -aoa -y -o"%TCDir%" -- "%srcBasePath%.Plugins.7z"
    IF DEFINED OS64Bit (
	%exe7z% x -aoa -y -o"%TCDir%" -- "%srcBasePath%.64bit.7z"
	%exe7z% x -aoa -y -o"%TCDir%" -- "%srcBasePath%.Plugins64bit.7z"
    ) ELSE (
	%exe7z% x -aoa -y -o"%TCDir%" -- "%srcBasePath%.32bit.7z"
    )
    "%SystemDrive%\SysUtils\SetACL.exe" -on "%TCDir%" -ot file -actn ace -ace "n:%UIDCreatorOwner%;p:change;i:so,sc;m:set;w:dacl"
    rem this causes weird permissions after profile permission reset --- "%utilsdir%xln.exe" %AutohotkeyExe% "%TCDir%\AutoHotkey.exe" || 
    XCOPY %AutohotkeyExe% "%TCDir%\*.*" /I /Y || (
	@ECHO Error copying AutoHotkey to TC dir "%TCDir%"
	PING 127.0.0.1 -n 3 >NUL
    )
    CALL :GetFileNameExt AutohotkeyExeName %AutohotkeyExe%
)
(
    "%TCDir%\xln.exe" "%TCDir%\%AutohotkeyExeName%" "%TCDir%\Autohotkey.exe" || COPY /B /Y "%TCDir%\%AutohotkeyExeName%" "%TCDir%\Autohotkey.exe"
    CALL :UnpackNotepad2Mod
    REM unpacking config after notepad2.zip to overwrite notepad2.ini
    %exe7z% x -aoa -y -o"%TCDir%" -- "%srcBasePath%.config.7z"
    REM Autohotkey.exe копируется в %TCDir% выше
    IF NOT EXIST "%APPDATA%\GHISLER\wincmd.ini" START "" /D"%TCDir%" "%TCDir%\%AutohotkeyExeName%" "%TCDir%\_copy_config.ahk"
    
    FOR /F "usebackq delims=" %%N IN (`DIR /B /A-D "%distzpaqDir%\zpaq*.zip"`) DO CALL :Unpackzpaq "%distzpaqDir%\%%~N" && EXIT /B
    @ECHO zpaq not unpacked!
EXIT /B
)
:Unpack7ZipDist <7-zip distributive>
SET "dist7zNameNoExt=%~n1"
IF "%dist7zNameNoExt:~-4%"=="-x64" (
    IF NOT DEFINED OS64Bit EXIT /B
    SET "outSubdir=\64"
    SET "flagVar=Unpacked64bit7Zip"
    SET "newlocal7zType=64"
) ELSE (
    SET "outSubdir="
    SET "flagVar=Unpacked32bit7Zip"
    SET "newlocal7zType=32"
)
(
    IF NOT DEFINED %flagVar% %exe7z% x -aoa -y -o"%TCDir%\PlugIns\wcx\Total7zip%outSubdir%" -- %1 Lang\* 7z.dll 7z.sfx 7zg.exe 7z.exe && SET "%flagVar%=1"
    IF DEFINED exe7zlocal IF %newlocal7zType% GEQ %exe7zlocal%. (
        ECHO Already unpacked %exe7zlocal%-bit 7-Zip locally, ignoring %newlocal7zType%-bit one from %1
        EXIT /B
    )
    CALL :FindFirstExisting exe7z "%TCDir%\PlugIns\wcx\Total7zip%outSubdir%\7z.exe" "%TCDir%\PlugIns\wcx\Total7zip%outSubdir%\7zg.exe" && SET "exe7zlocal=1"
    EXIT /B
)
:FindFirstExisting var <path> <path...>
(
    IF "%~2"=="" EXIT /B 1
    IF EXIST "%~2" (
	SET %~1="%~2"
	EXIT /B
    )
    SHIFT /2
    GOTO :FindFirstExisting
)
:Unpackzpaq
(
    IF DEFINED OS64Bit (
	%exe7z% x -aoa -y -o"%TCDir%\zpaq" -- %1 zpaq64.exe readme.txt
	MOVE /Y "%TCDir%\zpaq\zpaq64.exe" "%TCDir%\zpaq64.exe"
    ) ELSE (
	%exe7z% x -aoa -y -o"%TCDir%\zpaq" -- %1 zpaq.exe readme.txt
	MOVE /Y "%TCDir%\zpaq\zpaq.exe" "%TCDir%\zpaq.exe"
    )
    MOVE /Y "%TCDir%\zpaq\readme.txt" "%TCDir%\zpaq-readme.txt"
    RD "%TCDir%\zpaq"
    EXIT /B
)
:UnpackNotepad2Mod
(
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%distNotepad2Dir%\%distNotepad2Mask%%Notepad2DistSuffix%"`) DO (
	"%utilsdir%%exename7za%" x -aoa -y -o"%TCDir%\notepad2" -- "%distNotepad2Dir%\%%~A"
	FOR %%B IN ("%TCDir%\notepad2\notepad2*.*") DO MOVE "%%~B" "%TCDir%\"
	FOR %%B IN ("%TCDir%\notepad2\*.*") DO MOVE "%%~B" "%TCDir%\notepad2-%%~nxB"
	RD /S /Q "%TCDir%\notepad2"
	EXIT /B
    )
EXIT /B 1
)
:DefineLocalAppData
    SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
(
    IF NOT EXIST "%LOCALAPPDATA%" (
	MKDIR "%USERPROFILE%\AppData"
	"%utilsdir%xln.exe" -n "%USERPROFILE%\Local Settings\Application Data" "%LOCALAPPDATA%"
	"%utilsdir%xln.exe" -n "%USERPROFILE%\Application Data" "%USERPROFILE%\AppData\Roaming"
    )
EXIT /B
)
:FindAutoHotkeyExe
(
    FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :CheckAutohotkeyExe %%I
    rem continuing if AutoHotkeyScript type isn't defined or specified path points to incorect location
    IF NOT DEFINED AutohotkeyExe CALL :CheckAutohotkeyExe "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" || CALL :CheckAutohotkeyExe "%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe" || CALL :CheckAutohotkeyExe "%utilsdir%%exenameAutohotkey%"
    EXIT /B
)
:CheckAutohotkeyExe <exepath>
(
    IF NOT EXIST %1 EXIT /B 1
    SET AutohotkeyExe=%1
EXIT /B 0
)
:GetFileNameExt <var> <path>
(
    SET "%~1=%~nx2"
EXIT /B
)
