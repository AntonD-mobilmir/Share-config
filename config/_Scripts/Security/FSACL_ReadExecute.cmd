@REM coding:OEM
IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe

:again
IF NOT EXIST "%~2" GOTO :SkipThis

rem SetACL -on %2 -ot file -actn ace -ace "n:%~1;p:read_ex;i:so,sc;m:set;w:dacl"
%SetACLexe% -on %2 -ot file -actn ace -ace "n:%~1;p:full;m:revoke" -actn ace -ace "n:%~1;p:read_ex" -ignoreerr -silent

:SkipThis
SHIFT /2
IF NOT "%~2"=="" GOTO :again

rem -silent -ignoreerr 