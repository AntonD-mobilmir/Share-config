(REM coding:CP866
    REM !!! --- add new versions GUIDs to jre*_uids.txt
    IF DEFINED log SET "JREInstallLog=%log%-msi.log"

    CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6 || EXIT /B
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "installjre64bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "installjre64bit=1"

:repeat
(
    SET "uidsFile=jre8_uids.txt"
    IF DEFINED installjre64bit SET "uidsFile=jre8_uids_64-bit.txt"
    rem LibreOffice даже версии 5.4.4 не работает с JRE9 -- IF DEFINED installjre64bit SET "uidsFile=jre9_uids.txt"
    rem LibreOffice даже версии 5.4.4 не работает с JRE9, так что JRE9 можно безопасно удалять
    IF DEFINED installjre64bit CALL "%Distributives%\Soft\System\Virtual Machines Sandboxes\Sun Java\jre_uninstall_common.cmd" "%Distributives%\Soft\System\Virtual Machines Sandboxes\Sun Java\jre9_uids.txt"
)
(
    rem Проверка, не установлена ли сейчас последняя версия
    FOR /F "usebackq eol=# tokens=1" %%A IN ("%Distributives%\Soft\System\Virtual Machines Sandboxes\Sun Java\%uidsFile%") DO (
	IF NOT "%%~A"=="" (
	    REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{%%A}" /v "DisplayName"
	    REM if key not exist, there will be errorlevel 1.
	    IF ERRORLEVEL 1 (
		CALL "%Distributives%\Soft\System\Virtual Machines Sandboxes\Sun Java\jre_install.cmd"
		REM map ErrorLevel 1 to 1001, all other errors returned as-is
		IF ERRORLEVEL 1 IF NOT ERRORLEVEL 2 EXIT /B 1001
	    )
	    REM If no error, JRE of this version is already installed.
	    REM only read first line [which must have last version]
	    EXIT /B
	)
    )
    IF DEFINED installjre64bit FOR /D %%A IN ("%ProgramFiles(x86)%\LibreOffice *") DO IF EXIST "%%~A\program\soffice.bin" (
	rem установлен 32-битный LibreOffice, для нормальной работы нужна 32-битная JRE
	SET "installjre64bit="
	GOTO :repeat
    )
)
