@REM coding:OEM

SCHTASKS /Create /TN "mobilmir\run_wsusoffline_multiple_times" /XML "%~dp0run_wsusoffline_multiple_times.xml" /RU "%username%" /F || PAUSE
XCOPY "%~dp0run_wsusoffline_multiple_times.cmd" "%TEMP%" /Y
CALL "%~dp0run_wsusoffline_multiple_times.cmd" 3
CALL "%TEMP%\run_wsusoffline_multiple_times.cmd"
