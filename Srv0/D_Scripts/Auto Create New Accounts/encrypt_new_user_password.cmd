@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS

    rem Init
    SET "ErrorCmd=EXIT /B 1"
    SET "Hostname=Srv0"
    SET "GNUPGHOME=%APPDATA%\gnupg"
    SET "configDir=x:\Shares\profiles$\Share\config\"
    SET gpgrcpt=-r "535A11463B4577A5B3D38421861A68CCE91EA97A" -r "B28F3A61BD82291F1F5391820F8FA3D03EB7AB7D"
    SET "dirGPGout=d:\Scripts\Auto Create New Accounts\pwd.gpg"

    SET "genid=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=% %RANDOM%"

    SET "newUsername=%~1"
    SET "plainPwdPath=%~2"
)
@(
    IF NOT EXIST "%dirGPGout%" MKDIR "%dirGPGout%"

    SET gpgencOut="%dirGPGout%\%newUsername%@%Hostname% %genid%.txt.gpg"
    SET gpgServerCopy="\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\AutoCreatedUsers\%newUsername%@%Hostname% %genid%.txt.gpg"
    
    IF EXIST "c:\SysUtils\gnupg\gpg.exe" (
        SET gpgexe="c:\SysUtils\gnupg\gpg.exe"
    ) ELSE (
        CALL "%configDir%_Scripts\preparegpgexe.cmd"
    )
    IF NOT EXIST "%GNUPGHOME%" CALL "%configDir%_Scripts\genGpgKeyring.cmd"
)
@(
    DEL %gpgencOut% 2>NUL
    %gpgexe% --batch -a %gpgrcpt% -o %gpgencOut% -e "%plainPwdPath%"
    START "Copying gpg-encrypted password to Srv1S-B" /MIN %comspec% /C "COPY /Y /B %gpgencOut% %gpgServerCopy%"
    "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" "%configDir%_Scripts\AddUsers\submitEncryptedPassword.ahk" "%newUsername%" %gpgencOut%
    
    EXIT /B
)
