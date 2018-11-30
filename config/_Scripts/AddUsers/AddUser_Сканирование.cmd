@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

    %SystemRoot%\System32\net.exe USER "Сканирование" /Add /FULLNAME:"Сканирование (без пароля)" /USERCOMMENT:"Вход без пароля для доступа к сканеру" /passwordchg:no /passwordreq:no || EXIT /B
    %SystemRoot%\System32\wbem\wmic.exe path Win32_UserAccount where Name='Сканирование' set PasswordExpires=false

    IF EXIST "D:\Users\*.*" CALL "%~dp0..\FindAutoHotkeyExe.cmd" "%~dp0..\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"
EXIT /B
)
