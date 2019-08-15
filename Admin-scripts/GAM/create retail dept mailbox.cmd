@(REM coding:CP866
REM для https://trello.com/c/T65sBlNF/7-основная-учётная-запись-e-mail
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF DEFINED unattended (
        SET "ErrorCmd=ECHO Error!"
    ) ELSE (
        SET "ErrorCmd=PAUSE"
    )

    SET "mailgroupsDomain=mobilmir.ru"
    rem SET "monGroupsDomain=status.mobilmir.ru"

    CALL :SetOrAsk deptEmail "Логин отдела (если домен не указан, то zel.mobilmir.ru)" %1
    CALL :SetOrAsk deptName "Название отдела" %2
    CALL :SetOrAsk deptSector "Номер сектора (если неизвестен, оставьте пустым)" %3
    SET "deptLastName=(розничный отдел)"
    SET "org=/Розничные отделы"

    IF NOT DEFINED GenPasswordAhk (
        FOR /F "usebackq tokens=1* delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :CheckAutohotkeyExe %%J
        FOR /D %%A IN ("%USERPROFILE%\Dropbox\Backups" "\\Srv1S-B.office0.mobilmir\Users\Public\Shares") DO IF EXIST "%%~A\profiles$\Share\config\_Scripts\Lib\GenPassword.ahk" (
            SET GenPasswordAhk="%%~A\profiles$\Share\config\_Scripts\Lib\GenPassword.ahk"
            IF NOT DEFINED AutohotkeyExe CALL "%%~A\profiles$\Share\config\_Scripts\FindAutoHotkeyExe.cmd"
        )
    )
)
(
    FOR /F "tokens=1* delims=@" %%A IN ("%deptEmail%") DO (
        SET "deptLogin=%%~A"
        SET "mailboxDomain=%%~B"
    )
    IF NOT DEFINED mailboxDomain SET "mailboxDomain=zel.mobilmir.ru"

    IF "%deptSector%"=="0" SET "deptSector="

    SET "newPasswd="
    rem since Autohotkey is quoted, and FOR uses CMD /C syntax, another set of quotes required around whole command including parameters
    IF DEFINED AutoHotkeyExe FOR /F "usebackq delims=" %%A IN (`"%AutoHotkeyExe% %GenPasswordAhk% 20 "0-9a-zA-Z@#$*_=+[]{}~;'\:,./?-""`) DO @IF NOT DEFINED newPasswd SET "newPasswd=%%~A"
)
@(
    SET "passwdArg="
    IF DEFINED newPasswd SET passwdArg=password "%newPasswd%"
    IF DEFINED deptSector (
        SET "sectGroup=depts%deptSector%@%mailgroupsDomain%"
        rem SET "monAddr=depts%deptSector%-co@%monGroupsDomain%"
    ) ELSE (
        SET "sectGroup=retail-depts@%mailgroupsDomain%"
        rem SET "monAddr=depts-co@%monGroupsDomain%"
    )
)
(
    CALL "%~dp0switchdomain.cmd" %mailboxDomain% || (%ErrorCmd% & EXIT /B)
    rem gam create user <email address> firstname <First Name> lastname <Last Name> password <Password> [suspended on|off] [changepassword on|off] [gal on|off] [admin on|off] [sha] [md5] [crypt] [nohash] [org <Org Name>]
    rem If not set, firstname and lastname will default to "Unknown" and password will default to a random, 25-character string
    rem suspended off, AKA active is the default
    rem changepassword off is the default
    rem gal on is the default, gal=Global Address List
    rem By default, if neither sha1, crypt or md5 are specified, GAM will do a sha1 hash of the provided password and send the hash instead of the plain text password for an additional layer of security.
    rem     However, when hashes are sent, Google is unable to ensure password length and strength so it's possible to set passwords that do not conform to Google's length requirement this way. The optional parameter nohash disables GAM's automatic hashing of the password (password is still sent over encrypted HTTPS) so that Google can evaluate the length and strength of the password.
    rem     Optional parameter org moves the user into the desired Organizational Unit.
    ECHO Создание учётной записи %deptLogin%@%mailboxDomain%
    CALL "%~dp0gam.cmd" create user "%deptLogin%" firstname "%deptName%" lastname "%deptLastName%" org "%org%" %passwdArg% || (%ErrorCmd% & CALL :AddErrors "creating user")
    
    IF /I "%mailgroupsDomain%" NEQ "%mailboxDomain%" (
        CALL "%~dp0switchdomain.cmd" %mailgroupsDomain% || (%ErrorCmd% & CALL :AddErrors "switching domain to %mailboxDomain%")
        
        ECHO Создание группы %deptLogin%@%mailgroupsDomain%
        CALL "%~dp0gam.cmd" create group "%deptLogin%" name "%deptName% %deptLastName%" || (%ErrorCmd% & CALL :AddErrors "creating group %deptLogin%@%mailgroupsDomain%")
        CALL "%~dp0gam.cmd" update group "%deptLogin%" add member user "%deptLogin%@%mailboxDomain%" || (%ErrorCmd% & CALL :AddErrors "adding %deptLogin% to group %deptLogin%@%mailboxDomain%")
    )
    ECHO Добавление в %sectGroup%@%mailboxDomain%
    CALL "%~dp0gam.cmd" update group "%sectGroup%" add member user "%deptLogin%" || (%ErrorCmd% & CALL :AddErrors "adding %deptLogin% to %sectGroup%")
    
    rem ECHO Смена домена на %monGroupsDomain%
    rem CALL "%~dp0switchdomain.cmd" %monGroupsDomain% || (%ErrorCmd% & EXIT /B)
    rem gam create group <group email> [name <Group Name>] [description <Group Description>]
    rem https://github.com/jay0lee/GAM/wiki/GAM3GroupSettings
    rem ECHO Создание группы depts-co-%deptLogin%
    rem CALL "%~dp0gam.cmd" create group "depts-co-%deptLogin%" name "Контроль розничных отделов: %deptName%" ||(%ErrorCmd% & CALL :AddErrors "creating depts-co-%deptLogin%")
    REM who_can_post_message anyone_can_post send_message_deny_notification true allow_google_communication false is_archived false max_message_bytes 25M spam_moderation_level allow who_can_view_group all_in_domain_can_view
    REM при попытках изменения большей части свойств появляется:
    rem ERROR: 401: Domain cannot use Api, Groups service is not installed. - authError
    REM но по умолчанию в группу может отправлять кто угодно, так что всё ок
    
    rem IF NOT DEFINED errors (
    rem     REM gam update group <group email> add owner|member|manager [notsuspended] {user <email address> | group <group address> | ou|ou_and_children <org name> | file <file name> | all users} 
    rem     ECHO Добавление dept-forwarding-setup в depts-co-%deptLogin%
    rem     CALL "%~dp0gam.cmd" update group "depts-co-%deptLogin%" add member user dept-forwarding-setup ||(%ErrorCmd%)
    rem     ECHO.
    rem     ECHO Настройте пересылку из ящика отдела на адрес depts-co-%deptLogin%@%monGroupsDomain%
    rem     ECHO ^(см. https://trello.com/c/T65sBlNF/7-e-mail^)
    rem     IF NOT DEFINED Unattended (
    rem         PAUSE
    rem         ECHO Удаление dept-forwarding-setup из depts-co-%deptLogin%
    rem         CALL "%~dp0gam.cmd" update group "depts-co-%deptLogin%" remove user dept-forwarding-setup ||(%ErrorCmd%)
    rem         ECHO Добавление %monAddr%
    rem         CALL "%~dp0gam.cmd" update group "depts-co-%deptLogin%" add member user "%monAddr%" ||(%ErrorCmd% & CALL :AddErrors "adding %monAddr% to depts-co-%deptLogin%")
    rem     )
    rem )
    
    (
        IF DEFINED errors (
            CALL :EchoErrors
            ECHO ! %deptLogin%	%newPasswd%
        ) ELSE (
            ECHO %deptLogin%	%newPasswd%
        )
    )>>"%~dpn0.log"
EXIT /B %errors%
)

:SetOrAsk <varname> <prompt> <value>
(
    IF "%~3"=="" (
        IF NOT DEFINED unattended SET /P "%~1=%~2: "
    ) ELSE (
	SET "%~1=%~3"
    )
EXIT /B
)

:CheckAutohotkeyExe <path>
(
    IF NOT EXIST %1 EXIT /B 1
    SET AutohotkeyExe=%1
EXIT /B
)

:AddErrors
(
    SET "errors=%errors%, %~1"
EXIT /B
)
:EchoErrors
@(
    ECHO %errors:~2%
EXIT /B
)
