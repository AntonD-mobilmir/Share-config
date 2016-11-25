@(REM coding:CP866
rem %AutohotkeyExe% /ErrorStdOut "%~dp0Remove PuntoSwitcher from Startup.ahk"
IF NOT EXIST "%ProgramFiles%\Yandex\Punto Switcher\punto.exe" IF NOT EXIST "%ProgramFiles(x86)%\Yandex\Punto Switcher\punto.exe" EXIT /B
CALL "%Distributives%\Soft\Keyboard Tools\Punto Switcher\install.cmd"
)
