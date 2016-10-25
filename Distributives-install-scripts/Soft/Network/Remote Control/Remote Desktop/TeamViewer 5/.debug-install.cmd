@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

PUSHD "%TEMP%"||PAUSE
SET debug=1
SET AutohotkeyExe="C:\Program Files\AutoHotkey\AutoHotkey.exe"
SET DefaultsSource=\\Srv0\profiles$\Share\config\Apps_roaming.7z
SET DistSourceDir=\\Srv0.office0.mobilmir\Distributives
SET utilsdir=\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\
SET SoftSourceDir=\\Srv0.office0.mobilmir\Distributives\Soft
)

(%SystemRoot%\SysWOW64\cmd.exe /C ""%SoftSourceDir%\Network\Remote Control\Remote Desktop\TeamViewer 5\install.cmd" TeamViewer_Host.msi TeamViewer_ServiceNote.reg")|tee tv5inst.log
PAUSE
