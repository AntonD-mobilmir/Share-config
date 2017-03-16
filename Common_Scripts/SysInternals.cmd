@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED LOCALAPPDATA EXIT /B -1
    MKDIR "%LOCALAPPDATA%\SysInternals" 2>NUL
    PUSHD "%LOCALAPPDATA%\SysInternals" && (
	START "" /D "%LOCALAPPDATA%\SysInternals" /B "%SystemDrive%\SysUtils\wget.exe" -b -q -N "https://live.sysinternals.com/%~n1.chm"
	IF "%~x1"=="" (
	    "%SystemDrive%\SysUtils\wget.exe" -N "https://live.sysinternals.com/%~1.exe"
	) ELSE (
	    "%SystemDrive%\SysUtils\wget.exe" -N "https://live.sysinternals.com/%~1"
	)
	%*
	POPD
    )
)
