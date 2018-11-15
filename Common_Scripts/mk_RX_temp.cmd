@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.

    SET "TMP=%TEMP%\%RANDOM%"
)
(
    SET "TEMP=%TMP%"
    MKDIR "%TMP%"
    ICACLS "%TEMP%" /grant "%USERNAME%:(OI)(CI)F"
)
