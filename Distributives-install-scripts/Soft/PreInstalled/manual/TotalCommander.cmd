@(REM coding:CP866
REM Script to install preinstalled and working-without-install software
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED utilsdir SET "utilsdir=%~dp0..\utils\"
IF NOT DEFINED LOCALAPPDATA CALL :DefineLocalAppData

    SET "UIDCreatorOwner=S-1-3-0;s:y"
    CALL :FindAutoHotkeyExe || (CALL "%~dp0..\..\Keyboard Tools\AutoHotkey\install.cmd" & CALL :FindAutoHotkeyExe)

    SET OS64Bit=
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"

    SET "dist7zDir=%~dp0..\..\Archivers Packers\7Zip"
    SET "distzpaqDir=%~dp0..\..\..\Soft FOSS\Archivers Packers\zpaq"
    SET "distNotepad2Mask=Notepad2-mod.*"
    IF DEFINED OS64Bit ( SET "Notepad2DistSuffix=_x64.zip" ) ELSE SET "Notepad2DistSuffix=_x86.zip"
    SET "distNotepad2Dir=%~dp0..\..\..\Soft FOSS\Office Text Publishing\Text Documents\Notepad2\Special and Custom Editions\notepad2-mod"
)
(
    SET "TCDir=%LOCALAPPDATA%\Programs\Total Commander"
    SET exe7z="%utilsdir%7za.exe"
    REM exe7z will be redefined in next CALL
    FOR /F "usebackq delims=" %%N IN (`DIR /B /A-D "%dist7zDir%\7z*.exe"`) DO CALL :Unpack7ZipDist "%dist7zDir%\%%~N"
)
(
    %exe7z% x -r -aoa -o"%TCDir%" -- "%~dpn0.7z"
    %exe7z% x -r -aoa -o"%TCDir%" -- "%~dpn0.Plugins.7z"
    IF DEFINED OS64Bit (
	%exe7z% x -r -aoa -o"%TCDir%" -- "%~dpn0.64bit.7z"
	%exe7z% x -r -aoa -o"%TCDir%" -- "%~dpn0.Plugins64bit.7z"
    )
    "%SystemDrive%\SysUtils\SetACL.exe" -on "%TCDir%" -ot file -actn ace -ace "n:%UIDCreatorOwner%;p:change;i:so,sc;m:set;w:dacl"
    rem this causes weird permissions after profile permission reset --- "%utilsdir%xln.exe" %AutohotkeyExe% "%TCDir%\AutoHotkey.exe" || 
    XCOPY %AutohotkeyExe% "%TCDir%\*.*" /I /Y || (
	@ECHO Error copying AutoHotkey to TC dir
	PING 127.0.0.1 -n 3 >NUL
    )
)
(
    IF NOT EXIST "%dist7zDir%" SET "dist7zDir=\\Srv0.office0.mobilmir\Distributives\Soft\Archivers Packers\7Zip"
    IF NOT EXIST "%distzpaqDir%" SET "distzpaqDir=\\Srv0.office0.mobilmir\Distributives\Soft FOSS\Archivers Packers\zpaq"
    IF NOT EXIST "%distNotepad2Dir%" SET "distNotepad2Dir=\\Srv0.office0.mobilmir\Distributives\Soft FOSS\Office Text Publishing\Text Documents\Notepad2\Special and Custom Editions\notepad2-mod"
)
(
    CALL :UnpackNotepad2Mod
    REM unpacking config after notepad2.zip to overwrite notepad2.ini
    %exe7z% x -r -aoa -o"%TCDir%" -- "%~dpn0.config.7z"
    REM Autohotkey.exe копируется в %TCDir% выше
    IF NOT EXIST "%APPDATA%\GHISLER\wincmd.ini" START "" /D"%TCDir%" "%TCDir%\Autohotkey.exe" "%TCDir%\_copy_config.ahk"

    FOR /F "usebackq delims=" %%N IN (`DIR /B /A-D "%distzpaqDir%\zpaq*.zip"`) DO CALL :Unpackzpaq "%distzpaqDir%\%%~N" && EXIT /B
    @ECHO 7-Zip not unpacked!
EXIT /B
)
:Unpack7ZipDist
(
    rem SET "dist7zPath=%~1"
    SET "dist7zNameNoExt=%~n1"
    SET "outSubdir="
    SET "flagVar=Unpacked32bit7Zip"
)
(
    IF "%dist7zNameNoExt:~-4%"=="-x64" (
	IF NOT DEFINED OS64Bit EXIT /B
	SET "outSubdir=\64"
	SET "flagVar=Unpacked64bit7Zip"
    )
)
(
    IF NOT DEFINED %flagVar% %exe7z% x -r -aoa -o"%TCDir%\PlugIns\wcx\Total7zip%outSubdir%" -- %1 Lang\* 7z.dll 7z.sfx 7zg.exe 7z.exe && SET "%flagVar%=1"
    IF EXIST "%TCDir%\PlugIns\wcx\Total7zip%outSubdir%\7z.exe" SET exe7z="%TCDir%\PlugIns\wcx\Total7zip%outSubdir%\7z.exe"
    EXIT /B
)
:Unpackzpaq
(
    IF DEFINED OS64Bit (
	%exe7z% x -r -aoa -o"%TCDir%\zpaq" -- %1 zpaq64.exe readme.txt
	MOVE /Y "%TCDir%\zpaq\zpaq64.exe" "%TCDir%\zpaq64.exe"
    ) ELSE (
	%exe7z% x -r -aoa -o"%TCDir%\zpaq" -- %1 zpaq.exe readme.txt
	MOVE /Y "%TCDir%\zpaq\zpaq.exe" "%TCDir%\zpaq.exe"
    )
    MOVE /Y "%TCDir%\zpaq\readme.txt" "%TCDir%\zpaq-readme.txt"
    RD "%TCDir%\zpaq"
    EXIT /B
)
:UnpackNotepad2Mod
(
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%distNotepad2Dir%\%distNotepad2Mask%%Notepad2DistSuffix%"`) DO (
	%utilsdir%7za.exe x -aoa -o"%TCDir%\notepad2" -- "%distNotepad2Dir%\%%~A"
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
    IF NOT DEFINED AutohotkeyExe CALL :CheckAutohotkeyExe "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" || CALL :CheckAutohotkeyExe "%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe" || SET AutohotkeyExe="%~dp0..\utils\AutoHotkey.exe"
    EXIT /B
)
:CheckAutohotkeyExe <exepath>
(
    IF NOT EXIST %1 EXIT /B 1
    SET AutohotkeyExe=%1
EXIT /B 0
)
