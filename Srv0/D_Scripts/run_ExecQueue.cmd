@(REM coding:CP866
    ECHO %~f0 started %DATE% %TIME%
    FOR %%A IN ("%~dp0\ExecQueue\*.cmd") DO (
        (
        ECHO Starting %%~A
        CALL "%%~A"
        ) >>"d:\var\log\ExecQueue\%%~nxA.log" 2>&1
        IF ERRORLEVEL 1 (
            MOVE /Y "%%~A" "%~dp0ExecQueue.error\"
            CALL :AppendErrorToLog "%%~A" "d:\var\log\ExecQueue\%%~nxA.log"
        ) ELSE (
            MOVE /Y "%%~A" "%~dp0ExecQueue.done\"
        )
    )
    ECHO %~f0 finished %DATE% %TIME%
    EXIT /B
)

:AppendErrorToLog
(
    ECHO %1 finished with error %ERRORLEVEL%, see details in %2
    (
        ECHO.
        ECHO Error: %ERRORLEVEL%
    ) >>%2
EXIT /B
)
