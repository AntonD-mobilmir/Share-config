@REM coding:OEM
IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe

:again
IF NOT EXIST "%~2" GOTO :SkipThis

rem -silent -ignoreerr 
%SetACLexe% -on %2 -ot file -actn ace -ace "n:%~1;p:change;i:so,sc;m:set;w:dacl" -ignoreerr -silent

:SkipThis
SHIFT /2
IF NOT "%~2"=="" GOTO :again
