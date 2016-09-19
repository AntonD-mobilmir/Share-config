@REM coding:OEM
(
IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe
SET "UIDAdministrators=S-1-5-32-544;s:y"
SET "UIDSYSTEM=S-1-5-18;s:y"
)
:again
IF NOT EXIST "%~2" GOTO :SkipThis

%SetACLexe% -on %2 -ot file -actn setowner -ownr "n:%UIDAdministrators%" -actn setprot -op "dacl:p_nc;sacl:np" -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc,so" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:sc,so" -actn ace -ace "n:%~1;p:change,FILE_DELETE_CHILD;i:sc" -actn ace -ace "n:%~1;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so" 

:SkipThis
SHIFT /2
IF NOT "%~2"=="" GOTO :again
