@REM config:OEM
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF NOT "%~1"=="" SET powertarget=%~1

CALL "%~dp0..\CheckWinVer.cmd" 6 || GOTO :configXP
powercfg -h off
EXIT /B

GOTO :config%WinVer%

:configXP
IF NOT DEFINED powertarget (
  powercfg.exe /QUERY
  ECHO.
  ECHO ----------------------------------------------------------------------
  ECHO  Укажите тип системы числом или введите название загружаемого профиля
  ECHO.
  ECHO   1. Настольный компьютер / рабочая станция  [office_desktop_default]
  ECHO   2. Ноутбук                                               [notebook]
  ECHO   3. Сервер                                                  [server]
  ECHO   4. Терминал приёма платежей                      [payment_terminal]
  ECHO ----------------------------------------------------------------------
  ECHO.
  SET /P powertarget=Ваш выбор [1]: 
)
IF %powertarget%.==.SET powertarget=1
IF %powertarget%==1 SET powertarget=office_desktop_default
IF %powertarget%==2 SET powertarget=notebook
IF %powertarget%==3 SET powertarget=server
IF %powertarget%==4 SET powertarget=payment_terminal
ECHO.
ECHO Выбранный профиль: %powertarget%

powercfg.exe /create %powertarget%||(ECHO Ошибка создания профиля.&SET pause=1)
powercfg.exe /IMPORT %powertarget% /FILE "%srcpath%%powertarget%.POW"||(ECHO Ошибка загрузки профиля.&SET pause=1)
powercfg.exe /SETACTIVE %powertarget%||(ECHO Ошибка при переключении на профиль.&SET pause=1)
powercfg.exe /QUERY
IF "%pause%"=="1" PAUSE

EXIT /B
