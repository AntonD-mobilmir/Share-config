@REM coding:OEM
@ECHO OFF

SET /P username=��� ���짮��⥫� (����=%username%): 
SET /P mailaddress=���� e-mail: 

CALL gpggenkey-main.cmd %username% %mailaddress%
