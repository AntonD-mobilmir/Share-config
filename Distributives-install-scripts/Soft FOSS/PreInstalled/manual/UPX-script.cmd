@REM coding:CP866
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\

IF NOT EXIST "%SystemDrive%\Arc\UPX" MKDIR "%SystemDrive%\Arc\UPX"
compact /C /S:"%SystemDrive%\Arc\upx" /I /Q
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%SystemDrive%\Arc"

"%utilsdir%pathman.exe" /as "%SystemDrive%\Arc"
