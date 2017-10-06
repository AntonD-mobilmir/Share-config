@(REM coding:CP866
    IF EXIST "D:\Users\Karina.Razuvaeva\GAM\gam.exe" (
	SET GAMexe="D:\Users\Karina.Razuvaeva\GAM\gam.exe"
	SET "GAMpath=D:\Users\Karina.Razuvaeva\GAM"
    )
    SET prefix=
    @FOR /F "usebackq delims=" %%A IN (`DIR /b /O-N /AD "GAM-*"`) DO @(
	SET "GAMpath=%~dp0%%~A"
	SET GAMexe="%~dp0..\WinPython\python-2.7.13.amd64\python.exe" "%~dp0%%~A\src\gam.py"
	EXIT /B
    )
)
