@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ECHO %DATE% %TIME% Удаление MSXML 4.0 SP2 ^(KB954430^)
%SystemRoot%\System32\MsiExec.exe /X{86493ADD-824D-4B8E-BD72-8C5DCDC52A71} /qn /norestart
)
(
ECHO %DATE% %TIME% Удаление MSXML 4.0 SP2 ^(KB973688^)
%SystemRoot%\System32\MsiExec.exe /X{F662A8E6-F4DC-41A2-901E-8C11F044BDEC} /qn /norestart
)
(
ECHO %DATE% %TIME% Удаление MSXML 4.0 SP3 Parser ^(KB2758694^)
%SystemRoot%\System32\MsiExec.exe /X{1D95BA90-F4F8-47EC-A882-441C99D30C1E} /qn /norestart
)
