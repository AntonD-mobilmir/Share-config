@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd"
CALL "%~dp0reg_commonlysafe.cmd"

SET "xtmp=%TEMP%\%~n0"
)
:CheckTmpAgain
(
IF EXIST "%xtmp%" SET "xtmp=%TEMP%\%~n0.%DATE%.%TIME::=%.%RANDOM%" & GOTO :CheckTmpAgain

%exe7z% x -o"%xtmp%" "%~dp0..\..\Users\Default\AppData\Local\mobilmir.ru\DefaultUserRegistrySettings.7z"
FOR %%A IN ("%xtmp%\*.reg") DO REG IMPORT "%%~A"
RD /S /Q "%xtmp%"
)
