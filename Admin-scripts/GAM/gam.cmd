@(REM coding:OEM
IF NOT DEFINED GAMexe CALL "%~dp0_getGAMpath.cmd"
)
@%GAMexe% %*
