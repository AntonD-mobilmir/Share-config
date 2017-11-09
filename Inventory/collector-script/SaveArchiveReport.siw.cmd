@REM coding:OEM
REM Configuration and security policy collecting script
REM using SIW (System Information for Windows by Gabriel Topala)
REM                                      http://www.gtopala.com/
REM and secedit.exe

SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

rem START "LanSweeper" /MIN %comspec% /C "\\192.168.1.80\profiles$\Share\software_update\scripts\!LanSweeper scan.cmd"

SET find_execmd="%~dp0..\..\config\_Scripts\find_exe.cmd"

IF NOT DEFINED exe7z CALL %find_execmd% exe7z 7z.exe "%SystemDrive%\Arc\7-Zip\7z.exe" "%ProgramFiles%\7-Zip\7z.exe" || CALL %find_execmd% exe7z 7za.exe "d:\Distributives\Soft\PreInstalled\utils\7za.exe" "W:\Distributives\Soft\PreInstalled\utils\7za.exe" "\\192.168.1.80\Distributives\Soft\PreInstalled\utils\7za.exe" "\\Srv0\Distributives\Soft\PreInstalled\utils\7za.exe" "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\7za.exe" || PAUSE

SET ctime=%TIME::=%
REM %TIME% не всегда возвращает 2 цифры часов
SET datetime=%DATE:~-4,4%%DATE:~-7,2%%DATE:~-10,2%_%ctime:~,6%

REM not using %COMPUTERNAME% because it's always uppercase
FOR /F "usebackq delims=" %%I IN (`hostname`) DO SET hostname=%%I
SET ReportPath=%srcpath%Reports

%exe7z% x -aoa -o"%TEMP%\siw" -- "%srcpath%siw.7z" siw.exe
PUSHD "%TEMP%\siw"
    siw.exe /log /nodriver /s:16809985 /h:1455083 /n:25
    secedit /export /CFG "SecurityPolicy-%HOSTNAME%.inf"
    secedit /export /mergedpolicy /CFG "SecurityPolicy-ADMerged-%HOSTNAME%.inf"

    %exe7z% a -mx=9 -m0=LZMA2:a=2:d26:fb=273 -- "%ReportPath%\%hostname% %datetime%.7z" *.html *.inf *.pwd && (DEL *.html & DEL *.inf)
    DEL siw.exe
    DEL siw_init.xml
POPD
RD /Q "%TEMP%\siw"

EXIT /B
