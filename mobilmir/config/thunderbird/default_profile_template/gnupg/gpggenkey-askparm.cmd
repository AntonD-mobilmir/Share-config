@REM coding:OEM
@ECHO OFF

SET /P username=Имя пользователя (пусто=%username%): 
SET /P mailaddress=адрес e-mail: 

CALL gpggenkey-main.cmd %username% %mailaddress%
