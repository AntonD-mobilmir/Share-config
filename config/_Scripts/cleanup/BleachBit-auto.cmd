@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || PAUSE
SET relpath=Soft\PreInstalled\manual\BleachBit-Portable-RUN.cmd
CALL :FindBleachBit Distributives "%~d0\Distributives" "%~dp0..\..\..\Distributives" D:\Distributives W:\Distributives \\Srv0.office0.mobilmir\Distributives

CALL "%Distributives%\%relpath%"
ECHO BleachBit finished
rem BleachBit, бывает работает, через планировщик. В этом случае explorer.exe закрывается у пользователя! TASKKILL /F /IM explorer.exe
ENDLOCAL
EXIT /B

rem CALL "\\Srv0.office0.mobilmir\profiles$\Share\Programs\BleachBit-Portable\_run_from_localtemp.cmd" -c --no-uac --preset

:FindBleachBit
  IF EXIST "%~2\%relpath%" (
    SET "%~1=%~2"
    EXIT /B 0
  )

  SHIFT /2
IF NOT "%~2"=="" GOTO :FindBleachBit
EXIT /B 1
