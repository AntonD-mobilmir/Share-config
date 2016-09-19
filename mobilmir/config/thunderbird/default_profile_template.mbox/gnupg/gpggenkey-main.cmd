@REM coding:OEM

SETLOCAL
IF NOT "%~1"=="" SET username=%~1
IF NOT "%~2"=="" (
    SET mailaddress=%~2
) ELSE (
    SET mailaddress=%~1@mobilmir.ru
)

@CHCP 65001 >NUL & (
    ECHO Key-Type: RSA
    ECHO Subkey-Type: RSA
    ECHO Expire-Date: 0
    ECHO Name-Real: %username%
    ECHO Name-Comment: Цифроград-Ставрополь
    ECHO Name-Email: %mailaddress%
) | gpg --gen-key --batch & CHCP 866

SET gpgbackuppath=\\AcerAspire7720G\gnupg keys backup$\%mailaddress% %username%@%COMPUTERNAME% %DATE% %RANDOM%
MKDIR "%gpgbackuppath%"
COPY /B "%APPDATA%\gnupg\*.gpg" "%gpgbackuppath%"
