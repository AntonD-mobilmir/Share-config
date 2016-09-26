@REM coding:OEM
FOR /D %%I IN ("%~dp0*") DO IF EXIST "%%~I\download.cmd" CALL "%%~I\download.cmd"
