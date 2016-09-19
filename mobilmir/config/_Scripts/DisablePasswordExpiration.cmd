@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

net accounts /maxpwage:unlimited
rem wmic PATH Win32_UserAccount WHERE Name='%USER%' SET PasswordExpires=false
