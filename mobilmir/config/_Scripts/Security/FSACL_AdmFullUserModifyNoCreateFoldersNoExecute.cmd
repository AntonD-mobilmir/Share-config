@REM coding:OEM

IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe
SET UIDEveryone=S-1-1-0;s:y
SET UIDAuthenticatedUsers=S-1-5-11;s:y
SET UIDUsers=S-1-5-32-545;s:y
SET UIDSYSTEM=S-1-5-18;s:y
SET UIDCreatorOwner=S-1-3-0;s:y
SET UIDAdministrators=S-1-5-32-544;s:y

:again
IF NOT EXIST "%~2" GOTO :SkipThis
rem -silent -ignoreerr 
%SetACLexe% -on %2 -ot file -actn setowner -ownr "n:%UIDAdministrators%" -actn setprot -op "dacl:p_nc;sacl:np" -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc,so;m:set;w:dacl" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:io,so;m:set;w:dacl" -actn ace -ace "n:%~1;p:read_execute,FILE_ADD_FILE,FILE_WRITE_EA,FILE_DELETE_CHILD,FILE_WRITE_ATTRIBUTES,DELETE;i:sc;m:set;w:dacl" -actn ace -ace "n:%~1;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so;m:set;w:dacl" 

rem Users,read_execute+FILE_ADD_FILE+FILE_WRITE_EA+FILE_DELETE_CHILD+FILE_WRITE_ATTRIBUTES+DELETE,allow,container_inherit
rem Users,write+read+FILE_DELETE_CHILD+DELETE,allow,object_inherit+inherit_only"

:SkipThis
SHIFT /2
IF NOT "%~2"=="" GOTO :again
