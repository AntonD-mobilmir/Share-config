@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

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
)

%SetACLexe% -on %1 -ot file -actn clear -clr dacl -actn setprot -op "dacl:p_nc;sacl:p_nc" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:so,sc" -actn ace -ace "n:%UIDAdministrators%;p:full;i:so,sc" -actn ace -ace "n:%UIDAuthenticatedUsers%;p:read,FILE_ADD_SUBDIRECTORY;i:np;m:set;w:dacl" -ace "n:%UIDCreatorOwner%;p:full;i:io,so,sc;m:set;w:dacl" -ignoreerr -silent
