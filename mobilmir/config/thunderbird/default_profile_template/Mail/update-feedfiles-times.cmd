@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

FOR /R "%srcpath%Feeds" %%I IN (*.) DO c:\SysUtils\kliu\timeclone.exe "%srcpath%Feeds\Trash" "%%I"
