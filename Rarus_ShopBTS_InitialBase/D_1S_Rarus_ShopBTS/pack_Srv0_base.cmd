@REM coding:CP866
SET "srcdistPath=D:\Старый ПК\Диск W\1С Базы\Бза Для установки на отделы\ShopBTS\"

CALL "\\Srv0\profiles$\Share\config\_Scripts\find7zexe.cmd"

SET "z7zswitchesLZMA2=-mx=9 -m0=LZMA2:a=2:fb=273 -mqs=on"
SET "today=%DATE:~-4,4%%DATE:~-7,2%%DATE:~-10,2%"

SET "DLLsArcName=%~dp0ShopBTS_Add_DLLs.7z"
rem SET MainBaseArcName=%~dp0ShopBTS_InitialBase_251+MD%today%.7z
SET "MainBaseArcName=ShopBTS_InitialBase_251+MD-auto-daily.7z"

START "" /B /WAIT /D"%srcdistPath:~0,-1%" %exe7z% a -r %z7zswitchesLZMA2% -ir@"%~dpn0.dlllist.txt" "%DLLsArcName%" || (PAUSE & EXIT /B 32767)

IF EXIST "%~dp0%MainBaseArcName%" MOVE /Y "%~dp0%MainBaseArcName%" "%~dp0..\D_1S_Rarus_ShopBTS_old\%MainBaseArcName%.bak"
%exe7z% a -r %z7zswitchesLZMA2% -xr0@"%~dpn0.excludelist.txt" -xr0@"%~dpn0.dlllist.txt" "%~dp0%MainBaseArcName%" "%srcdistPath%*" || (PAUSE & EXIT /B 32767)
rem FOR %%I IN ("%~dp0ShopBTS_InitialBase_251+MD*.7z") DO IF NOT "%%~I"=="%~dp0%MainBaseArcName%" DEL "%%~I"
