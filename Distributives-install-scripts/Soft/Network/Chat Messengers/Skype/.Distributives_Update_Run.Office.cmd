@(REM coding:CP866
REM Skype 8 distributive downloader

REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distMask=Skype-*.exe"
)
(
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (with trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp\ if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or workdir)
    
    IF NOT DEFINED xlnexe CALL :findxlnexe
rem     IF NOT DEFINED curlexe IF EXIST "%SystemDrive%\SysUtils\curl.exe" SET curlexe="%SystemDrive%\SysUtils\curl.exe"
    IF NOT DEFINED wgetexe IF EXIST "%SystemDrive%\SysUtils\wget.exe" SET wgetexe="%SystemDrive%\SysUtils\wget.exe"
)
(
    MKDIR "%workdir%" 2>NUL
    REM go.skype.com doesn't support HEAD request ;-(
    REM CURL, on the other hand, saves to file named "windows.desktop.download"
    REM seemingly because it uses name from URL in command line instead of redirected one. -J as you see does not help
    REM so it looks like there's no other way than download twice, once with wget, and if it's succeed, with CURL, to receive timestamp

    REM up: seems wget -nc --no-timestamping set local file time to timestamp from server!
    
    REM searching for current distributive in current dir, to avoid skipping not-completely-downloaded distributive from temp
    CALL :FindLatest curDst "%srcpath%%distMask%"
)
(
    FOR %%A IN ("%workdir%%distMask%") DO IF /I "%%~nxA"=="%curDst%" (ECHO Found %%A) ELSE (ECHO.|DEL "%%~A"||EXIT /B)
    START "" /B /WAIT /D"%workdir%" "C:\SysUtils\wget.exe" -o "%logsDir%wget.log" --progress=dot:giga -nc --no-timestamping https://go.skype.com/windows.desktop.download
    REM -nc causes stop downloading if file exists, but wget does not return an error in that case
)    
(
    REM check for new files
    CALL :FindLatest newDst "%workdir%%distMask%" "%curDst%" || EXIT /B
)
(
rem     FOR %%A IN ("%workdir%%distMask%") DO ECHO.|DEL "%%~A"||MOVE /Y "%%~A" "%%~dpnA.%RANDOM%%%~xA"
rem     %curlexe% -vLR -o "%workdir%%newDst%" https://go.skype.com/windows.desktop.download >"%logsDir%\curl.log" 2>&1
    REM -L - follow redirects, -R - remote time
    %xlnexe% "%workdir%%newDst%" "%srcpath%%newDst%" || COPY /B /Y "%workdir%%newDst%" "%srcpath%%newDst%"
    FOR %%A IN ("%srcpath%%distMask%") DO IF /I "%%~nxA" NEQ "%newDst%" ECHO N|DEL "%%~A"
    
    rem SET "cleanup_action=DEL "
    CALL "%baseScripts%\DistCleanup.cmd" "%srcpath%%distMask%" "%srcpath%%newDst%"
    rem FOR %%A IN ("%srcpath%%distMask%") DO IF /I "%%~nxA"=="%newDst%" (
    rem     ECHO skipping "%srcpath%%newDst%".
    rem ) ELSE (
    rem     CALL "%baseScripts%\mvold.cmd" "%%~A"
    rem     IF EXIST "%workdir%%%~A" CALL "%baseScripts%\mvold.cmd" "%workdir%%%~A"
    rem )
    IF NOT DEFINED s_uscripts EXIT /B
)
(
    CALL "%s_uscripts%\..\templates\_add_withVer.cmd" "%newDst%"
    EXIT /B
)
:FindLatest <varname> <mask> <exclusion>
(
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D %2`) DO IF NOT "%%~A"=="%~3" (
        SET "%~1=%%~A"
        EXIT /B
    )
EXIT /B 1
)

:findxlnexe
(
    IF EXIST %SystemDrive%\SysUtils\xln.exe (
        SET xlnexe="%SystemDrive%\SysUtils\xln.exe"
    ) ELSE IF EXIST "%~d0Distributives\Soft\PreInstalled\utils\xln.exe" (
        SET xlnexe="%~d0Distributives\Soft\PreInstalled\utils\xln.exe"
    ) ELSE SET "xlnexe=verify error"
    EXIT /B
)

>wget -d https://go.skype.com/windows.desktop.download
DEBUG output created by Wget 1.19.1 on mingw32.

Reading HSTS entries from https://go.skype.com/windows.desktop.download/.wget-hsts
URI encoding = 'CP1251'
converted 'https://go.skype.com/windows.desktop.download' (CP1251) -> 'https://go.skype.com/windows.desktop.download' (UTF-8)
--2018-11-08 17:01:21--  https://go.skype.com/windows.desktop.download
Resolving go.skype.com (go.skype.com)... seconds 30.00, Winsock error: 0
40.118.109.53
Caching go.skype.com => 40.118.109.53
Connecting to go.skype.com (go.skype.com)|40.118.109.53|:443... seconds 30.00, Winsock error: 0
connected.
Created socket 3.
Releasing 0x029bcff0 (new refcount 1).
Initiating SSL handshake.
seconds 30.00, Winsock error: 0
Handshake successful; connected socket 3 to SSL handle 0x029bfd60
certificate:
  subject: CN=go.skype.com
  issuer:  CN=Microsoft IT TLS CA 4,OU=Microsoft IT,O=Microsoft Corporation,L=Redmond,ST=Washington,C=US
X509 certificate successfully verified and matches host go.skype.com

---request begin---
HEAD /windows.desktop.download HTTP/1.1
User-Agent: Wget/1.19.1 (mingw32)
Accept: */*
Accept-Encoding: identity
Host: go.skype.com
Connection: Keep-Alive

---request end---
HTTP request sent, awaiting response... seconds 30.00, Winsock error: 0

---response begin---
HTTP/1.1 405 Method Not Allowed
Cache-Control: no-cache
Pragma: no-cache
Allow: GET
Content-Length: 80
Content-Type: application/json; charset=utf-8
Expires: -1
Strict-Transport-Security: max-age=31536000; includeSubDomains
Date: Thu, 08 Nov 2018 14:01:23 GMT

---response end---
405 Method Not Allowed
Registered socket 3 for persistent reuse.
Converted file name 'windows.desktop.download' (UTF-8) -> 'windows.desktop.download' (CP1251)
Parsed Strict-Transport-Security max-age = 31536000, includeSubDomains = true
Added new HSTS host: go.skype.com:443 (max-age: 31536000, includeSubdomains: true)
URI content encoding = 'utf-8'
2018-11-08 17:01:21 ERROR 405: Method Not Allowed.
