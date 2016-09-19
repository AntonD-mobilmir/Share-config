@REM coding:OEM

FOR /F "usebackq delims=] tokens=1" %%I IN (`FIND /N "---separator---" "%~f0"`) DO SET skip=%%I
SET /A skip=%skip:~1%

SET cleanupPath=%~1
IF "%cleanupPath%"=="" (
    FOR /D %%P IN ("C:\Users\*" "D:\Users\*") DO CALL :CleanProfile "%%~P"
    EXIT /B
)

:nextArg
FOR /D %%P IN (%1) DO CALL :CleanProfile "%%~P"
SHIFT
IF NOT "%~1"=="" GOTO :nextArg

EXIT /B

:CleanProfile
PUSHD "%~1\AppData"||EXIT /B
    FOR /F "usebackq skip=%skip% tokens=1,2 eol=; delims=*" %%I IN ("%~f0") DO (
        FOR /D %%A IN ("%%~I*") DO (
	    FOR /D %%B IN ("%%~A%%J\*") DO RD /S /Q "%%~B"
	    DEL /F /Q /A "%%~A%%J\*.*"
	    DEL /F /Q /A "%%~A%%J"
	)
    )
POPD

EXIT /B

REM Dir list
REM ---separator---
Roaming\NVIDIA
Roaming\Microsoft\Windows\Themes\CachedFiles
Local\Temp
Local\Steam
Local\NVIDIA\NvBackend
Local\Dropbox\logs
Local\Google\Chrome\User Data\Profile *\Cache
Local\Google\Chrome\User Data\Profile *\GPUCache
Local\Google\Chrome\User Data\Profile *\Media Cache
Local\Google\Chrome\User Data\Profile *\Service Worker
Local\Google\Chrome\User Data\Profile *\JumpListIcons
Local\Google\Chrome\User Data\Profile *\JumpListIconsOld
Local\Google\Chrome\User Data\Default\Cache
Local\Google\Chrome\User Data\Default\GPUCache
Local\Google\Chrome\User Data\Default\Media Cache
Local\Google\Chrome\User Data\Default\Service Worker
Local\Google\Chrome\User Data\Default\JumpListIcons
Local\Google\Chrome\User Data\Default\JumpListIconsOld
Local\Microsoft\Internet Explorer
Local\Microsoft\Media Player
;Local\Microsoft\Windows\Caches
Local\Microsoft\Windows\Explorer
Local\Microsoft\Windows\INetCache
Local\Microsoft\Windows\INetCookies
Local\Microsoft\Windows\Notifications
Local\Microsoft\Windows\WebCache
LocalLow
Local\Packages\*\AC\INetCache
Local\Packages\*\AC\INetHistory
Local\Packages\*\AC\Temp
Local\Packages\*\LocalState\Cache
Local\Packages\*\LocalState\LiveTile
Local\Packages\*\TempState
Local\IconCache.db
