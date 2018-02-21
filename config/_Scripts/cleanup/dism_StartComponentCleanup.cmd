@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

    rem "%SystemRoot%\System32\DISM.exe" /Online /Cleanup-image /scanhealth
    rem "%SystemRoot%\System32\DISM.exe" /Online /Cleanup-image /RestoreHealth

    "%SystemRoot%\System32\DISM.exe" /Online /Cleanup-image /spsuperseded /hidesp
    "%SystemRoot%\System32\DISM.exe" /Online /Cleanup-Image /StartComponentCleanup /ResetBase
)
