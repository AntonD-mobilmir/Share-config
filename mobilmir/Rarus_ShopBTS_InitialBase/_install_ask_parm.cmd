@REM coding:OEM

START "ShopBTS_InitialBase" /WAIT %comspec% /C "%~dp0_install_Rarus.cmd"
CALL "%~dp0_RarusMail.cmd"

EXIT /B
