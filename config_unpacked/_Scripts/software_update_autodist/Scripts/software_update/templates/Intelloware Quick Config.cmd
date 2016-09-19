@(REM coding:CP866
IF NOT EXIST "%ProgramFiles%\Quick Config\Quick Config.exe" IF NOT EXIST "%ProgramFiles(x86)%\Quick Config\Quick Config.exe" EXIT /B 1
%AutohotkeyExe% /ErrorStdOut "%Distributives%\Soft\Network\Configuration\Intelloware Quick Config\install.ahk"
)
