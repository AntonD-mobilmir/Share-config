@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "noarchmasks=*.exe *.zip *.gz *.bz2 *.rar"
SET "moreDirs="
)
CALL "%ProgramData%\mobilmir.ru\Common_Scripts\wget_the_site.cmd" www.pps.univ-paris-diderot.fr "http://www.pps.univ-paris-diderot.fr/~vouillon/unison/"
rem CALL wget_the_site alan.petitepomme.net http://alan.petitepomme.net/unison/index.html
rem CALL wget_the_site www.pps.jussieu.fr http://www.pps.jussieu.fr/~vouillon/unison/
