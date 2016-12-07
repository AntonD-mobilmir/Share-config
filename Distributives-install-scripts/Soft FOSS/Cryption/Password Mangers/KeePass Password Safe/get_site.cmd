@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "noarchmasks=*.zip *.exe *.7z *.rar *.xpi *.msi *.u3p *.plg *.plgx"
SET "moreDirs="
)
SET wgetSideCMD=CALL "%ProgramData%\mobilmir.ru\Common_Scripts\wget_the_site.cmd"
(
%wgetSideCMD% keepass.info
IF NOT EXIST "%~dp0keepass.info\extensions" EXIT /B

SET "srcpath=%srcpath%keepass.info\extensions\"
%wgetSideCMD% gogogadgetscott.info http://gogogadgetscott.info/keepass/twofishcipher/ http://gogogadgetscott.info/keepass/titledisplay/
%wgetSideCMD% www.gbuffer.net http://www.gbuffer.net/kxch
%wgetSideCMD% www.aliasbailbonds.com http://www.aliasbailbonds.com/KeeForm/item/keeform-a-form-filler-for-keepass
%wgetSideCMD% keefox.org
%wgetSideCMD% pwm2keepass.sourceforge.net
rem %wgetSideCMD% sourceforge.net https://sourceforge.net/projects/pronouncepwgen/ https://sourceforge.net/projects/keepass-favicon/
%wgetSideCMD% rdc-keepass-plugin.appspot.com
)
