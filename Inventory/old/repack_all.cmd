@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

SET "today=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
CALL "%~dp0..\..\config\_Scripts\find7zexe.cmd"
FOR /D %%D IN ("%~dp0*.*") DO CALL :unpackAllArchives "%%~D"
)
(
START "" /B /WAIT /D "%~dp0" %exe7z% a -sdel -mx=9 -m0=LZMA2:a=2:fb=273 -mqs=on -x!"*.7z" -x!"%~nx0" -x!"board-dumps" -- "%today%.7z"
EXIT /B
)

:unpackAllArchives
(
    FOR /R "%~1" %%A IN (*.7z) DO %exe7z% x -aoa -o"%%~dpA*" -- "%%~A" && DEL "%%~A"
EXIT /B
)
