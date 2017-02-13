@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

FOR /D %%D IN ("%ProgramFiles%\LibreOffice *") DO CALL :compactLODir %%D
IF DEFINED ProgramFiles^(x86^) FOR /D %%D IN ("%ProgramFiles(x86)%\LibreOffice *") DO CALL :compactLODir %%D

EXIT /B

:compactLODir <dir>
    %windir%\System32\compact.exe /C /EXE:LZX /S:%*
    IF ERRORLEVEL 1 %windir%\System32\compact.exe /C /S:%* *.aff *.bmp *.class *.dat *.db *.db_ *.dct *.dic *.dll *.exe *.ht *.html *.idx *.js *.key *.py *.pyd *.txt *.ui *.xcd *.xcu *.xml *.xsl
EXIT /B
