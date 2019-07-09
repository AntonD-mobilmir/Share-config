@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

IF NOT DEFINED exe7z IF EXIST "%~dp0..\..\..\wcx\Total7zip\7z.exe" (SET exe7z="%~dp0..\..\..\wcx\Total7zip\7z.exe") ELSE SET exe7z="%~dp0..\..\..\wcx\Total7zip\7zg.exe"

MKDIR "%TEMP%\%~nx0.tmp" 2>NUL
PUSHD "%TEMP%\%~nx0.tmp" && (
    curl -LR -o trid_w32.zip http://goo.gl/aJVb
    curl -LR -o triddefs.zip http://goo.gl/Bnw1
    CALL :UpdateFile trid_w32.zip
    CALL :UpdateFile triddefs.zip triddefs.trd
    POPD
)
rem RD /S /Q "%TEMP%\%~nx0.tmp"
EXIT /B
)
:UpdateFile <arcPath> <mask>
(
%exe7z% x -aoa -o"%TEMP%\%~nx0.tmp\%~nx1.tmp" -- %*
PUSHD "%TEMP%\%~nx0.tmp\%~nx1.tmp" && (
    FOR %%A IN (%2) DO (
	FC /B /LB1 /A "%%~A" "%~dp0%%~A" >NUL
	IF ERRORLEVEL 2 PAUSE
	IF ERRORLEVEL 1 MOVE /Y "%%~A" "%~dp0%%~A"
    )
    POPD
)
EXIT /B
)
