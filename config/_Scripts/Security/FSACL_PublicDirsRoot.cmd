@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)
IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe
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
:Next
(
rem %SetACLexe% -on %1 -ot file -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%UIDEveryone%;p:read;i:so,sc" -actn ace -ace "n:%UIDEveryone%;p:traverse,list_dir,read_attr,read_ea,add_file,add_subdir,del_child,read_dacl;i:io,sc" -actn ace -ace "n:%UIDEveryone%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so" -ignoreerr -silent
rem В некоторых отделах после обновления Windows 10, все Public папки, в том числе рабочий стол, в D:\Users
%SetACLexe% -on %1 -ot file -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%UIDEveryone%;p:read;i:so,sc" -actn ace -ace "n:%UIDEveryone%;p:traverse,list_dir,read_attr,read_ea,read_dacl;i:io,sc" -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc,so" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:sc,so" -ignoreerr -silent

FOR %%A IN ("Documents" "Downloads" "Music" "Pictures" "Recorded TV" "Videos") DO %SetACLexe% -on "%~1\%%~A" -ot file -actn ace -actn ace -ace "n:%UIDEveryone%;p:change,FILE_DELETE_CHILD;i:sc" -actn ace -ace "n:%UIDEveryone%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so" -ignoreerr -silent
IF "%~2"=="" EXIT /B
SHIFT
GOTO :Next
)
