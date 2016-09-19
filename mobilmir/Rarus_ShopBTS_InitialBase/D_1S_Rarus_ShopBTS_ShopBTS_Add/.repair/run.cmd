rem coding:CP866
rem "C:\Program Files\1Cv77\BIN\1cv7s.exe" CONFIG /M /D"%~dp0.." /@"%~dp0savedata.ini"
"C:\Program Files\1Cv77\BIN\1cv7s.exe" CONFIG /M /D"%~dp0.." /@"%~dp0repair.ini"

CALL "C:\Local_Scripts\1srunwait.cmd" /m /dd:\1S\Rarus\ShopBTS /nПродавец /p
