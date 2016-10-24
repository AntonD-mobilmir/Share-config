@(REM coding:CP866
REM Repacks .zip with store method
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET "comprOpt7z=-mm=Copy -mcu=on"
CALL "%~dp0zip_repack.cmd" %*
ENDLOCAL
)
