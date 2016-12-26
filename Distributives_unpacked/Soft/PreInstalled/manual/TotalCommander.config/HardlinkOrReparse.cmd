@REM coding:OEM
SET dst=%~2
FOR /F "usebackq delims=" %%I IN (%1) DO CALL :Link "%%I"
EXIT /B %ErrorsHappened%

:Link
    SET src=%~1
    CALL :getsrcdirname "%src:~0,-1%"
    IF %src:~-1%.==\. (
	"%COMMANDER_PATH%\xln.exe" -n "%src:~0,-1%" "%dst%%srcdirname%"
    ) ELSE (
	fsutil hardlink create "%dst%%~nx1" %1
    )
    IF ERRORLEVEL 1 (
	ECHO Error %ERRORLEVEL% linking %1
	SET ErrorsHappened=1
    )
EXIT /B

:getsrcdirname
    SET srcdirname=%~nx1
EXIT /B
