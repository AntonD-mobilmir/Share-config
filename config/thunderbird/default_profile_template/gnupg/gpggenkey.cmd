@REM coding:OEM
@ECHO OFF
rem for XP only: diskperf.exe -y
@CHCP 65001 >NUL & (
    ECHO Key-Type: RSA
    ECHO Subkey-Type: RSA
    ECHO Expire-Date: 0
    ECHO Name-Real: %username%
    ECHO Name-Comment: Цифроград-Ставрополь
    ECHO Name-Email: %username%@mobilmir.ru
) | gpg --gen-key --batch & CHCP 866

SET gpgbackuppath=\\AcerAspire7720G.office0.mobilmir\gnupg keys backup$\%USERNAME%@%COMPUTERNAME% %DATE% %time::=_%
MKDIR "%gpgbackuppath%"
COPY /B "%APPDATA%\gnupg\*.gpg" "%gpgbackuppath%"
