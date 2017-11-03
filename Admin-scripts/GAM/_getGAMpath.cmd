@(REM coding:CP866
    IF EXIST "%USERPROFILE%\GAM\gam.exe" (
	SET GAMexe="%USERPROFILE%\GAM\gam.exe"
	SET "GAMpath=%USERPROFILE%\GAM"
    )
    SET prefix=
    @FOR /F "usebackq delims=" %%A IN (`DIR /b /O-N /AD "GAM-*"`) DO @(
	SET "GAMpath=%~dp0%%~A\src"
	SET GAMexe="%~dp0..\WinPython\python-2.7.13.amd64\python.exe" "%~dp0%%~A\src\gam.py"
	EXIT /B
    )
)
