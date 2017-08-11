@(REM coding:CP866
IF NOT DEFINED LOCALAPPDATA SET "LOCALAPPDATA=%TEMP%"
)
SET "flagfile=%LOCALAPPDATA%\%~n0-tried-once.flag"
(
DEL /Q "%flagfile%"

IF DEFINED log SET "JREInstallLog=%log%-msi.log"

CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6 || EXIT /B

rem �஢�ઠ, �� ��⠭������ �� ᥩ�� ��᫥���� �����
FOR /F "usebackq eol=# tokens=1" %%A IN ("%Distributives%\Soft\System\Virtual Machines Sandboxes\Sun Java\jre8_uids.txt") DO (
    REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{%%A}" /v "DisplayName"
    REM if key not exist, it's not installed, and there will be errorlevel 1. If no error, it's already installed.
    IF NOT ERRORLEVEL 1 EXIT /B
    REM only read first line
    GOTO :endCheck
)
)
:endCheck
(
REM because jre8 does not uninstall previous JREs.
REM !!! --- edit the uninstall script to add new version ID
CALL "%Distributives%\Soft\System\Virtual Machines Sandboxes\Sun Java\jre8_install.cmd" && CALL "%Distributives%\Soft\System\Virtual Machines Sandboxes\Sun Java\jre8_uninstall.cmd" /LeaveLast
IF ERRORLEVEL 2 EXIT /B
IF ERRORLEVEL 1 EXIT /B 2
)