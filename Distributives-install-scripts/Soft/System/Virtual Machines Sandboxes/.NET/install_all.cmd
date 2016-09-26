@(REM coding:CP866
ECHO OFF
rem sc config wuauserv start= auto
rem sc start wuauserv
PUSHD "%~dp0..\..\..\..\Updates\Windows\wsusoffline" && (
    CALL cmd\DoUpdate /nobackup /instdotnet35 /instdotnet4 /skipieinst %*
    CALL cmd\DoUpdate /nobackup /instdotnet35 /instdotnet4 /skipieinst %*
    POPD
)
)
