@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd"  http://ahkscript.org/download/1.1/AutoHotkeyHelp.zip AutoHotkeyHelp.zip

    SET "srcpath=%~dp0ahk-u32\"
    CALL "%baseScripts%\_DistDownload.cmd"  http://ahkscript.org/download/ahk-u32.zip *.zip

    SET "srcpath=%~dp0ahk-u64\"
    CALL "%baseScripts%\_DistDownload.cmd"  http://ahkscript.org/download/ahk-u64.zip *.zip
)
