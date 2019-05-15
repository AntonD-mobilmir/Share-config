@(REM coding:CP866
    IF EXIST "%USERPROFILE%\GAM\gam.exe" (
	SET GAMexe="%USERPROFILE%\GAM\gam.exe"
	SET "GAMpath=%USERPROFILE%\GAM"
    )
    @FOR /F "usebackq delims=" %%A IN (`DIR /b /O-N /AD "%LOCALAPPDATA%\Programs\Google Apps Manager (GAM)\GAM-*"`) DO @(
	SET "GAMpath=%LOCALAPPDATA%\Programs\Google Apps Manager (GAM)\%%~A\src"
	SET GAMpy="%LOCALAPPDATA%\Programs\Google Apps Manager (GAM)\%%~A\src\gam.py"
	GOTO :FoundPy
    )
    @FOR /F "usebackq delims=" %%A IN (`DIR /b /O-N /AD "GAM-*"`) DO @(
	SET "GAMpath=%~dp0%%~A\src"
	SET GAMpy="%~dp0%%~A\src\gam.py"
	GOTO :FoundPy
    )
)

:FoundPy
@(
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-N /AD "%LOCALAPPDATA%\Programs\WinPython3\python-*"`) DO @(
	SET GAMexe="%LOCALAPPDATA%\Programs\WinPython3\%%~A\python.exe" %GAMpy%
	EXIT /B
    )
)
