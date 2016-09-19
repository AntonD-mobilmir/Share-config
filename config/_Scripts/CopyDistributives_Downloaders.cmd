@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd" || PAUSE

SET localDist=D:\Distributives
FOR /R %localDist% %%I IN (".sync*") DO (
    IF "%%~nxI"==".sync" DEL "%%~I"
    IF "%%~nxI"==".sync.includes" DEL "%%~I"
    IF "%%~nxI"==".sync.excludes" DEL "%%~I"
)

%exe7z% x -aoa -y -o"%localDist%" -- "%~dpn0.syncmarker.7z"
XCOPY "%~dp0rsync_DistributivesFromSrv0.cmd" "%localDist%" /Y /I

START "Копирование дистрибутивов" /MIN /D "%localDist%" %comspec% /U /C "%localDist%\rsync_DistributivesFromSrv0.cmd"
