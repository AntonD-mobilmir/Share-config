@REM coding:OEM
IF NOT DEFINED exe7z CALL "%~dp0..\..\..\find7zexe.cmd" || EXIT /B

CALL "%~dp0AMDcpu_RealtekHDA.cmd"
REM � ��᫥���� ��।� ��⮬�, �� ��᫥ ��� ��⠭���� �ந�室�� ��⮬���᪠� ��१���㧪�
CALL "\\Srv0\Distributives\Drivers\nVidia\nForce\XP\_install.cmd"
