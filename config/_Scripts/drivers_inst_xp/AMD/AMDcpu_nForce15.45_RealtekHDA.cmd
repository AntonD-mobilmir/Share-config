@REM coding:OEM
IF NOT DEFINED exe7z CALL "%~dp0..\..\..\find7zexe.cmd" || EXIT /B

CALL "%~dp0AMDcpu_RealtekHDA.cmd"
REM В последнюю очередь потому, что после его установки происходит автоматическая перезагрузка
CALL "\\Srv0\Distributives\Drivers\nVidia\nForce\XP\_install.cmd"
