@(REM coding:CP866
REM Reads list of hostnames, outputs list of corresponding IP addresses.
REM Lists all addresses of round-robing hosts (parses output of nslookup for each host).
REM Requires unix-style find utility.
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS

REM /Add to add new IPs to existing list

SET tmplist="%TEMP%\%~n0.%RANDOM%.tmp"
SET tmplistuniq="%TEMP%\%~n0.%RANDOM%.tmp.uniq"

SET "CopyOldList="
SET "AddMode=Default"
)
:nextarg
SET "opt=%~1"
IF "%opt:~,1%"=="/" (
    CALL :ProcessSwitch%opt:~1%
    SHIFT
    GOTO :nextarg
)
(
    SET "input=%1"
    SET "output=%2"

)
(
    IF DEFINED CopyOldList (
	COPY /Y %output% %tmplist%
    ) ELSE DEL %tmplist%
    FOR /F "usebackq eol=# delims=" %%I IN (%input%) DO CALL :AddByHostname %%I

    rem uniq works only for non-unique lines standing one next to each other (sorted list) -- uniq %tmplist% allowed_by_hostnames.ip-list.uniq
    rem but sort can remove duplicates on its own
    "%SystemDrive%\SysUtils\UnxUtils\sort.exe" -us %tmplist% >%tmplistuniq%

    DEL %tmplist%
    IF DEFINED output (
	MOVE /Y %tmplistuniq% %output%
    ) ELSE (
	TYPE %tmplistuniq%
	DEL %tmplistuniq%
    )

    EXIT /B
)
:AddByHostname
(
    ECHO Resolving %1...>&2
    SET "CurrentHostname=%1"
    SET "AddressEncountered=0"
    IF NOT "%~1"=="" FOR /F "usebackq skip=2 tokens=1*" %%J IN (`nslookup %1`) DO CALL :AddAfterFlag "%%~J" "%%K"
EXIT /B
)
:AddAfterFlag
(
    IF "%~1"=="Aliases:" (
	rem No more addresses
	SET "AddressEncountered=0"
	EXIT /B
    )
    
    rem 1st address on >=2nd line in multi-line addresses string
    rem it can contain ", " at the end
    IF "%AddressEncountered%"=="1" FOR /F "delims=," %%L IN (%1) DO CALL :AddIP%AddMode% %%~L
    
    IF %1=="Address:" (
	rem Single Address follows
	CALL :AddIP%AddMode% %~2
	EXIT /B
    )

    rem First line for multi-IP host
    IF %1=="Addresses:" SET AddressEncountered=1
    
    rem a line for multi-IP host
    IF %AddressEncountered%==1 FOR /F "delims=," %%L IN (%2) DO CALL :AddIP%AddMode% %%~L
EXIT /B
)
:AddIPDefault
(
    IF NOT "%~1"=="127.0.0.1" (
	ECHO %*
    ) >>%tmplist%
EXIT /B
)
:AddIPHostColonIP
(
    IF NOT "%~1"=="127.0.0.1" (
	ECHO %CurrentHostname%:%*
    ) >>%tmplist%
EXIT /B
)
:ProcessSwitchAdd
(
    SET "CopyOldList=1"
EXIT /B
)
:ProcessSwitchHostColonIP
(
    SET "AddMode=HostColonIP"
EXIT /B
)
