@REM coding:OEM

rem gpg --keyserver pool.sks-keyservers.net --recv-keys 0xE91EA97A
gpg --import "%~dp00xE91EA97A.asc"

rem Preparation:
rem gpg --homedir=GnuPG --edit-key 8C89AA71 trust quit
rem gpg --homedir=GnuPG --export-ownertrust >trust.asc

gpg --edit-key 0xE91EA97A trust sign tsign save quit
rem gpg --sign-key 0xE91EA97A
rem gpg --update-trustdb

gpg --keyserver pool.sks-keyservers.net --send-keys 0xE91EA97A
