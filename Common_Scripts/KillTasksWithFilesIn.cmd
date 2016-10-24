@REM coding:OEM
FOR /F "usebackq skip=4 tokens=3" %%I IN (`handle %*`) DO TASKKILL /PID %%~I
