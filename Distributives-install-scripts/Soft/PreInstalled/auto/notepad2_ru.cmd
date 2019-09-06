@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED ErrorCmd (
        SET "ErrorCmd=SET ErrorPresence=1"
        SET "ErrorPresence="
    )

    IF NOT DEFINED exe7z (
        SET "utilsdir=%~dp0..\utils\"
        IF NOT DEFINED exename7za (
            SET "exename7za=7za.exe"
            IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "exename7za=7za64.exe"
            IF DEFINED PROCESSOR_ARCHITEW6432 SET "exename7za=7za64.exe"
        )
    )
)
(
    IF NOT DEFINED exe7z SET exe7z="%utilsdir%%exename7za%"

    SET "RunPathVar=ProgramFiles"
    SET "lProgramFiles=%ProgramFiles%"
    IF DEFINED ProgramFiles^(x86^) (
        SET "lProgramFiles=%ProgramFiles(x86)%"
        SET "RunPathVar=ProgramFiles^(x86^)"
    )
)
(
    %exe7z% x -aoa -y -o"%lProgramFiles%\Notepad2" -- "%srcpath%%~n0.7z" || %ErrorCmd%

    ASSOC .txt=notepad2-txtfile
    FTYPE notepad2-txtfile=^"%%%RunPathVar%%%\Notepad2\Notepad2.exe^" %%1

    ECHO N|REG ADD "HKEY_CLASSES_ROOT\.txt\ShellNew" /v "NullFile" /d ""
    ECHO N|REG ADD "HKEY_CLASSES_ROOT\notepad2-txtfile\DefaultIcon" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\system32\imageres.dll,-102"
    REG ADD "HKEY_CLASSES_ROOT\Applications\notepad2.exe\shell\open\command" /ve /d """"%%%RunPathVar%%%\Notepad2\notepad2.exe""" """%%1"""" /f
    REG ADD "HKEY_CLASSES_ROOT\Applications\notepad2.exe\shell\edit\command" /ve /d """"%%%RunPathVar%%%\Notepad2\notepad2.exe""" """%%1"""" /f
    REG ADD "HKEY_CLASSES_ROOT\*\OpenWithList\Notepad2.exe" /f
    IF NOT DEFINED ErrorPresence EXIT /B 0
)
EXIT /B %ErrorPresence%
