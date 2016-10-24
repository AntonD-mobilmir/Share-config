@REM coding:OEM
REM Creates junction with same target as specified junction
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM This script is licensed under LGPL
REM %1 - source
REM %2 - target
FOR /D %%I IN (%1) DO FOR /F "usebackq delims=> tokens=1*" %%J IN (`ln -j "%%~I"^|recode -f --sequence=memory 1251..866`) DO CALL :makelink "%~2\%%~nxI" "%%K"

EXIT /B

:makelink
    SET source=%~1
    SET target=%~2
    SET target=%target:~1%
    ln -j "%source%" "%target%"
EXIT /B
