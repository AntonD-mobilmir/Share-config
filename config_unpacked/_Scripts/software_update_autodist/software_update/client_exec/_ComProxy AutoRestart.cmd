@(REM coding:CP866
%SystemRoot%\System32\sc.exe failure ComProxy reset= 600 actions= restart/15/restart/60
IF ERRORLEVEL 1060 IF NOT ERRORLEVEL 1061 (
    ECHO Service not exist!
    EXIT /B 0
)
)
