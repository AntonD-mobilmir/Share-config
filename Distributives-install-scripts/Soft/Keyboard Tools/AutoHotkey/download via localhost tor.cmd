@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "torBrowserDir=%LocalAppData%\Programs\Tor Browser\Browser\TorBrowser"
)
(
START "" /B "%torBrowserDir%\Tor\tor.exe" --defaults-torrc "%torBrowserDir%\Data\Tor\torrc-defaults" -f "%torBrowserDir%\Data\Tor\torrc" DataDirectory "%torBrowserDir%\Data\Tor" GeoIPFile "%torBrowserDir%\Data\Tor\geoip" GeoIPv6File "%torBrowserDir%\Data\Tor\geoip6" +__ControlPort 9151 +__SocksPort "127.0.0.1:9150 IPv6Traffic PreferIPv6 KeepAliveIsolateSOCKSAuth"
PING -n 5 127.0.0.1 >NUL
curl -x socks://127.0.0.1:9150 --remote-name-all -JRL https://autohotkey.com/download/ahk-install.exe
rem  -O, --remote-name   Write output to a file named as the remote file
rem      --remote-name-all  Use the remote file name for all URLs
)
