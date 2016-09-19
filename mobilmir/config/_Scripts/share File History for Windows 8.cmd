@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

SETLOCAL ENABLEEXTENSIONS

SET "UIDEveryone=S-1-1-0;s:y"
SET "UIDAuthenticatedUsers=S-1-5-11;s:y"
SET "UIDUsers=S-1-5-32-545;s:y"
SET "UIDSYSTEM=S-1-5-18;s:y"
SET "UIDCreatorOwner=S-1-3-0;s:y"
SET "UIDAdministrators=S-1-5-32-544;s:y"

SET targetDir="R:\File History"
SET shareName="File History$"

IF NOT DEFINED SetACLexe CALL "%~dp0find_exe.cmd" SetACLexe SetACL.exe "%SystemDrive%\SysUtils\SetACL.exe" || (
    ECHO SetACL.exe не найден, доступ не будет настроен.
)
)
(
MKDIR %targetDir%
%SystemRoot%\system32\compact.exe /C %targetDir%
rem ATTRIB +H %targetDir%
%SystemRoot%\system32\NET.exe SHARE %shareName%=%targetDir% /GRANT:Users,FULL /REMARK:"Ресурс для локальной истории файлов"
%SystemRoot%\system32\NET.exe SHARE %shareName%=%targetDir% /GRANT:Пользователи,FULL /REMARK:"Ресурс для локальной истории файлов"

IF DEFINED SetACLexe %SetACLexe% -on %targetDir% -ot file -actn clear -clr dacl -actn setprot -op "dacl:p_nc;sacl:p_nc" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:so,sc" -actn ace -ace "n:%UIDAdministrators%;p:full;i:so,sc" -actn ace -ace "n:%UIDAuthenticatedUsers%;p:read,FILE_ADD_SUBDIRECTORY;i:np;m:set;w:dacl" -ace "n:%UIDCreatorOwner%;p:full;i:io,so,sc;m:set;w:dacl"
)
