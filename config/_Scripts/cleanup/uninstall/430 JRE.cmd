@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
    SET "JREDistFound="
)
FOR %%A IN ("%ProgramFiles32%" "%ProgramFiles64%") DO IF EXIST "%%~A\Java" (
    IF NOT DEFINED JREDistFound (
        FOR /F "usebackq delims=" %%B IN (`DIR /S /B "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\otn-pub\java\jdk\*.exe"`) DO SET "JREDistFound=1"
        IF NOT DEFINED JREDistFound EXIT /B
    )
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\jre_install.cmd"

    ECHO %DATE% %TIME% Удаление JRE
    CALL "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\jre6_uninstall.cmd"
    CALL "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\jre7_uninstall.cmd"
    %AutohotkeyExe% "%SoftSourceDir%\System\Virtual Machines Sandboxes\Sun Java\uninstall.ahk"
    EXIT /B
)
