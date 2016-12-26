@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

FOR /R %%I IN (*.w?x) DO (
    PUSHD "%%~dpI" && "c:\Arc\upx\upx.exe" -d "%%~nxI" && DEL "%%~dpnI.w?~"
    POPD
)
