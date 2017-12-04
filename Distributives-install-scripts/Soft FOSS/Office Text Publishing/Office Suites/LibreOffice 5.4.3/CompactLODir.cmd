@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

FOR /D %%D IN ("%ProgramFiles%\LibreOffice *") DO CALL :compactLODir %%D
IF DEFINED ProgramFiles^(x86^) FOR /D %%D IN ("%ProgramFiles(x86)%\LibreOffice *") DO CALL :compactLODir %%D
EXIT /B
)
:compactLODir <dir>
(
    START "" /B /WAIT /LOW %windir%\System32\compact.exe /C /EXE:LZX /S:%*
    IF ERRORLEVEL 1 START "" /B /WAIT /LOW %windir%\System32\compact.exe /C /S:%* *.aff *.bmp *.class *.dat *.db *.db_ *.dct *.dic *.dll *.exe *.ht *.html *.idx *.js *.key *.py *.pyd *.txt *.ui *.xcd *.xcu *.xml *.xsl
EXIT /B
)
