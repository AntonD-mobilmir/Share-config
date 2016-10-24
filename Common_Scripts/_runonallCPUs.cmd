@REM coding:OEM
START "" /D"%~dp1" %*
ping localhost -n 3 >nul
process.exe -a "%~nx1" 1111111111111111111111111111111
