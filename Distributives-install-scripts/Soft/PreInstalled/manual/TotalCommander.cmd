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
)
SET "TCDir=%LOCALAPPDATA%\Programs\Total Commander"
(
"%utilsdir%7za.exe" x -r -aoa -o"%TCDir%" -- "%~dpn0.7z"
"%SystemDrive%\SysUtils\SetACL.exe" -on "%TCDir%" -ot file -actn ace -ace "n:%UIDCreatorOwner%;p:change;i:so,sc;m:set;w:dacl"
rem this causes weird permissions after profile permission reset --- "%utilsdir%xln.exe" %AutohotkeyExe% "%TCDir%\AutoHotkey.exe" || 
XCOPY %AutohotkeyExe% "%TCDir%\*.*" /I /Y || @ECHO Error copying AutoHotkey to TC dir
rem IF /I "%SystemDrive:~0,2%" NEQ "%TCDir:~0,2%" GOTO :Unpack7ZipLibs
IF NOT EXIST "%dir7z%\7zg.exe" GOTO :Unpack7ZipLibs
IF NOT EXIST "%dir7z%\7z.dll" GOTO :Unpack7ZipLibs
)
:Link7ZipLibs
(
    "%utilsdir%xln.exe" -n "%dir7z%\Lang" "%TCDir%\PlugIns\wcx\Total7zip\Lang" || XCOPY "%dir7z%\Lang" "%TCDir%\PlugIns\wcx\Total7zip\Lang\*.*" /E /I /Y || GOTO :Unpack7ZipLibs
    "%utilsdir%xln.exe" "%dir7z%\7z.dll" "%TCDir%\PlugIns\wcx\Total7zip\7z.dll" || XCOPY "%dir7z%\7z.dll" "%TCDir%\PlugIns\wcx\Total7zip\*.*" /I /Y || GOTO :Unpack7ZipLibs
    "%utilsdir%xln.exe" "%dir7z%\7z.sfx" "%TCDir%\PlugIns\wcx\Total7zip\7z.sfx" || XCOPY "%dir7z%\7z.sfx" "%TCDir%\PlugIns\wcx\Total7zip\*.*" /I /Y || GOTO :Unpack7ZipLibs
    "%utilsdir%xln.exe" "%dir7z%\7z.exe" "%TCDir%\PlugIns\wcx\Total7zip\7zG.exe" || XCOPY "%dir7z%\7z.exe" "%TCDir%\PlugIns\wcx\Total7zip\*.*" /I /Y || GOTO :Unpack7ZipLibs
    GOTO :Skip7z
)
:Unpack7ZipLibs
(
    "%utilsdir%7za.exe" x -r -aoa -o"%TCDir%\PlugIns\wcx\Total7zip" -- "%~dp0..\..\Archivers Packers\7Zip\7z*.exe" Lang\* 7z.dll 7z.sfx 7zg.exe
)
:Skip7z
(
IF NOT EXIST "%APPDATA%\GHISLER\wincmd.ini" START "" /D"%TCDir%" %AutoHotkeyExe% "%TCDir%\_copy_config.ahk"
EXIT /B
)
:getFirstArg
(
    SET "%~1=%~2"
EXIT /B
)
:FindAutoHotkeyExe
FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
IF DEFINED AutohotkeyExe IF EXIST %AutohotkeyExe% EXIT /B 0
rem continuing here if AutoHotkeyScript isn't defined or specified path points to incorect location
SET AutohotkeyExe="%utilsdir%AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% EXIT /B 1
EXIT /B 0
:DefineLocalAppData
    SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
    IF NOT EXIST "%LOCALAPPDATA%" (
	MKDIR "%USERPROFILE%\AppData"
	"%utilsdir%xln.exe" -n "%USERPROFILE%\Local Settings\Application Data" "%LOCALAPPDATA%"
	"%utilsdir%xln.exe" -n "%USERPROFILE%\Application Data" "%USERPROFILE%\AppData\Roaming"
    )
EXIT /B
