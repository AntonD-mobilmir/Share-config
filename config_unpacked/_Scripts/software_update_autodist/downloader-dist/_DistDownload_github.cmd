@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

    CALL "%~dp0_GetWorkPaths.cmd"
)
:GetGithubLatestRelease <url> <distname-prefix> <distname-suffix>
rem IF NOT DEFINED workdir SET "workdir=%~dp0temp\"
(
    IF NOT EXIST "%workdir%" MKDIR "%workdir%"
    rem CURL still ignores server filename. Have no idea what to do with it. So it'll be only used as backup.
    rem -J, --remote-header-name  Use the header-provided filename (H)
    rem -k, --insecure      Allow connections to SSL sites without certs (H)
    rem -L, --location      Follow redirects (H)
    rem -o, --output FILE   Write to FILE instead of stdout
    rem -#, --progress-bar  Display transfer progress as a progress bar
    rem -p, --proxytunnel   Operate through a HTTP proxy tunnel (using CONNECT)
    rem -O, --remote-name   Write output to a file named as the remote file
    rem     --remote-name-all  Use the remote file name for all URLs
    rem -R, --remote-time   Set the remote file's time on the local output
    rem -z, --time-cond TIME   Transfer based on a time condition
    curl.exe -L -o "%workdir%latest" %1 || EXIT /B
    FIND %3 "%workdir%latest" | find "/%~2" >"%workdir%wget-input.html"
    FC /A /T /0 "%workdir%wget-input.html" "%workdir%wget-input-prev.html" >NUL && EXIT /B
    CALL "%baseScripts%\_DistDownload.cmd" -- "%~2_latest_%~3" -F -i "%workdir%wget-input.html" -B "https://github.com/" -O"%workdir%%~2_latest_%~3"
    MOVE /Y "%workdir%wget-input.html" "%workdir%wget-input-prev.html"
    EXIT /B
)

