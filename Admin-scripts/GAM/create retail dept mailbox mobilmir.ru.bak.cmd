@(REM coding:CP866
REM для https://trello.com/c/T65sBlNF/7-основная-учётная-запись-e-mail
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET "pd=mobilmir.ru"
)
@(
CALL :SetOrAsk deptLogin "Логин отдела (без @%pd%)" %1
CALL :SetOrAsk deptName "Название отдела" %2
CALL :SetOrAsk deptSector "Номер сектора (если неизвестен, оставьте пустым)" %3
SET "deptLastName=(розничный отдел)"
SET "org=/Розничные отделы"
)
(
    IF "%deptSector%"=="0" SET "deptSector="
    IF DEFINED deptSector (
        SET "sectGroup=depts%deptSector%@%pd%"
        SET "monAddr=depts%deptSector%-co@status.%pd%"
    ) ELSE (
        SET "sectGroup=retail-depts@%pd%"
        SET "monAddr=depts-co@%pd%"
    )
)
(
    CALL switchdomain.cmd %pd%
    rem gam create user <email address> firstname <First Name> lastname <Last Name> password <Password> [suspended on|off] [changepassword on|off] [gal on|off] [admin on|off] [sha] [md5] [crypt] [nohash] [org <Org Name>]
    rem If not set, firstname and lastname will default to "Unknown" and password will default to a random, 25-character string
    rem suspended off, AKA active is the default
    rem changepassword off is the default
    rem gal on is the default, gal=Global Address List
    rem By default, if neither sha1, crypt or md5 are specified, GAM will do a sha1 hash of the provided password and send the hash instead of the plain text password for an additional layer of security.
    rem     However, when hashes are sent, Google is unable to ensure password length and strength so it's possible to set passwords that do not conform to Google's length requirement this way. The optional parameter nohash disables GAM's automatic hashing of the password (password is still sent over encrypted HTTPS) so that Google can evaluate the length and strength of the password.
    rem     Optional parameter org moves the user into the desired Organizational Unit.
    ECHO Создание пользователя %deptLogin%
    CALL gam.cmd create user "%deptLogin%" firstname "%deptName%" lastname "%deptLastName%" org "%org%" || PAUSE
    ECHO Добавление в %sectGroup%
    CALL gam.cmd update group "%sectGroup%" add member user "%deptLogin%" ||PAUSE
    
    ECHO Смена домена на status.%pd%
    CALL switchdomain.cmd status.%pd% >NUL
    rem gam create group <group email> [name <Group Name>] [description <Group Description>]
    rem https://github.com/jay0lee/GAM/wiki/GAM3GroupSettings
    ECHO Создание группы depts-co-%deptLogin%
    CALL gam.cmd create group "depts-co-%deptLogin%" name "Контроль розничных отделов: %deptName%" ||PAUSE
    REM who_can_post_message anyone_can_post send_message_deny_notification true allow_google_communication false is_archived false max_message_bytes 25M spam_moderation_level allow who_can_view_group all_in_domain_can_view
    REM при попытках изменения большей части свойств появляется:
    rem ERROR: 401: Domain cannot use Api, Groups service is not installed. - authError
    REM но по умолчанию в группу может отправлять кто угодно, так что всё ок
    
    rem gam update group <group email> add owner|member|manager [notsuspended] {user <email address> | group <group address> | ou|ou_and_children <org name> | file <file name> | all users} 
    ECHO Добавление dept-forwarding-setup в depts-co-%deptLogin%
    CALL gam.cmd update group "depts-co-%deptLogin%" add member user dept-forwarding-setup ||PAUSE
    ECHO.
    ECHO Настройте пересылку из ящика отдела на адрес depts-co-%deptLogin%@status.%pd%
    ECHO ^(см. https://trello.com/c/T65sBlNF/7-e-mail^)
    PAUSE
    ECHO Удаление dept-forwarding-setup из depts-co-%deptLogin%
    CALL gam.cmd update group "depts-co-%deptLogin%" remove user dept-forwarding-setup ||PAUSE
    ECHO Добавление %monAddr%
    CALL gam.cmd update group "depts-co-%deptLogin%" add member user "%monAddr%" ||PAUSE
    IF NOT ERRORLEVEL 1 (
	ECHO Всё готово!
	PAUSE
    )
EXIT /B
)

:SetOrAsk <varname> <prompt> <value>
(
    IF "%~3"=="" (
	SET /P "%~1=%~2: "
    ) ELSE (
	SET "%~1=%~3"
    )
EXIT /B
)
