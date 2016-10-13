@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    IF DEFINED PROCESSOR_ARCHITEW6432 (
	"%SystemRoot%\SysNative\cmd.exe" /C %0 %*
	EXIT /B
    )

    IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe "%SystemDrive%\SysUtils\SetACL.exe"
    IF NOT DEFINED SetACLexe (
	ECHO SetACL.exe не найден, продолжение невозможно.
	EXIT /B 2
    )

    SET "UIDEveryone=S-1-1-0;s:y"
    SET "UIDAuthenticatedUsers=S-1-5-11;s:y"
    SET "UIDUsers=S-1-5-32-545;s:y"
    SET "UIDSYSTEM=S-1-5-18;s:y"
    SET "UIDCreatorOwner=S-1-3-0;s:y"
    SET "UIDAdministrators=S-1-5-32-544;s:y"

    SET procList=%*
    IF NOT DEFINED procList SET procList=D:\Distributives W:\Distributives "%USERPROFILE%\BTSync"
)

FOR %%A IN (%procList%) DO IF EXIST %%A (
    %SetACLexe% -on %%A -ot file -rec cont_obj -actn setowner -ownr "n:%UIDAdministrators%" -actn rstchldrn -rst dacl -ignoreerr -silent
    %SetACLexe% -on %%A -ot file -actn ace -ace "n:%UIDEveryone%;p:full;m:revoke" -actn ace -ace "n:%UIDEveryone%;p:read_ex" -ignoreerr -silent
)
