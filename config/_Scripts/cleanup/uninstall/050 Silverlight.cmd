@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ECHO %DATE% %TIME% Удаление SilverLight
%SystemRoot%\System32\MsiExec.exe /X{89F4137D-6C26-4A84-BDB8-2E5A4BB71E00} /qn /norestart
)
