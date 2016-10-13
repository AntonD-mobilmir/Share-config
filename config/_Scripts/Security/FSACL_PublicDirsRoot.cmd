@REM coding:OEM
@ECHO OFF
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

SETLOCAL ENABLEEXTENSIONS

IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe
IF NOT DEFINED SetACLexe (
    ECHO SetACL.exe не найден, продолжение невозможно.
    EXIT /B 2
)

(
SET UIDEveryone=S-1-1-0;s:y
SET UIDAuthenticatedUsers=S-1-5-11;s:y
SET UIDUsers=S-1-5-32-545;s:y
SET UIDSYSTEM=S-1-5-18;s:y
SET UIDCreatorOwner=S-1-3-0;s:y
)

:Next
%SetACLexe% -on %1 -ot file -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%UIDEveryone%;p:read;i:so,sc" -actn ace -ace "n:%UIDEveryone%;p:traverse,list_dir,read_attr,read_ea,add_file,add_subdir,del_child,read_dacl;i:io,sc" -actn ace -ace "n:%UIDEveryone%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so" -ignoreerr -silent

SHIFT
IF NOT "%~1"=="" GOTO :Next

EXIT /B
