@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

CALL "%~dp0switchdomain.cmd" mobilmir.ru
CALL "%~dp0gam.cmd" csv %1 gam update group ~new add member user ~primaryEmail || PAUSE
CALL "%~dp0gam.cmd" csv %1 gam update group ~old remove user ~primaryEmail || PAUSE

CALL "%~dp0switchdomain.cmd" status.mobilmir.ru
CALL "%~dp0gam.cmd" csv %1 gam update group ~monitoringGroup add member user ~newMonSector || PAUSE
CALL "%~dp0gam.cmd" csv %1 gam update group ~monitoringGroup remove user ~oldMonSector || PAUSE
)
