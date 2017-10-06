@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

MKDIR "%TEMP%\%~nx0.tmp"
PUSHD "%TEMP%\%~nx0.tmp" && (
    wget -N http://goo.gl/aJVb http://goo.gl/Bnw1
    CALL :UpdateFile trid_w32.zip *
    CALL :UpdateFile triddefs.zip triddefs.trd
    POPD
)
RD /S /Q "%TEMP%\%~nx0.tmp"
EXIT /B
)
:UpdateFile <arcPath> <mask>
(
"%~dp0..\..\..\wcx\Total7zip\7zg.exe" x -aoa -o"%TEMP%\%~nx0.tmp\%~nx1.tmp" -- %*
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
