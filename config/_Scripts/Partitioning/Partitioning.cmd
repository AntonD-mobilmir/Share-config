@REM coding:OEM
@ECHO OFF

IF NOT EXIST D:\ DISKPART /s "%~dp0PartitionCreateD.dps"

SET /A MenuCount=0
ECHO Menu:
FOR %%I IN ("%~dp0*.dps") DO CALL :AddMenuItem "%%~I"

SET /P SelectedMenuItem=Selected menu item number: 

FOR /F "usebackq delims=" %%I IN (`ECHO %%MenuItem%SelectedMenuItem%%%`) DO SET SelectedFile=%%~I
DISKPART /s "%SelectedFile%"
CALL "%~dp0FormatPartitions.cmd"
PAUSE
EXIT /B

:AddMenuItem
    SET /A MenuCount+=1
    ECHO %MenuCount%: %~n1
    SET MenuItem%MenuCount%=%1
EXIT /B
