@REM coding:CP866
FOR /R "%~dp0" %%I IN ("reg-%COMPUTERNAME%-*.txt") DO FOR /F "usebackq delims=" %%J IN ("%%~I") DO PUSHD "%%~dpI" && ( REG EXPORT %%J /Y & POPD )
