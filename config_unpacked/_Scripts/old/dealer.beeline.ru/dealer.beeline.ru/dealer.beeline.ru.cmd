@REM coding:OEM
@ECHO OFF
REM Script to pre-create directoried for Beeline Dealer ActiveX software
REM                    by logicdaemon@gmail.com for Tsifrograd-Stavropol
REM                                                     logicdaemon.ru

SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%

cscript //B //Nologo xcacls.vbs "%APPDATA%\Microsoft\Crypto\RSA\*.*" /F /T /S /I ENABLE

SET DealerPointCode=%1
SET DealerCode=%DealerPointCode:~,4%

IF "%DealerPointCode%"=="" (
  ECHO Код точки должен быть указан как параметр командной строки
  "сделать ярлык для Билайн Дилер Он-Лайн.ahk"
  PAUSE >NUL
  EXIT /B
)

REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs" /v "RegDir" /d "%srcpath%%DealerPointCode%\DATA\REG\\" /f
REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs" /v "SuspendDir" /d "%srcpath%%DealerPointCode%\DATA\SUSPEND\\" /f
REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs" /v "ArchDir" /d "%srcpath%%DealerPointCode%\DATA\ARCH\\" /f
REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs" /v "HelpDir" /d "%srcpath%%DealerPointCode%\DATA\HELP\\" /f
REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs" /v "LogDir" /d "%srcpath%%DealerPointCode%\LOG\\" /f
REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs" /v "TemplateDir" /d "%srcpath%%DealerPointCode%\DATA\TEMPLATE\\" /f
REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs" /v "ImportDir" /d "%srcpath%%DealerPointCode%\DATA\IMPORT\\" /f
REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs" /v "ExportDir" /d "%srcpath%%DealerPointCode%\DATA\EXPORT\\" /f

REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\System" /v "DealerCode" /d "%DealerCode%" /f
REG ADD "HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\System" /v "DealerPointCode" /d "%DealerPointCode%" /f

IF NOT EXIST "%srcpath%%DealerPointCode%" MKDIR "%srcpath%%DealerPointCode%"

SET selfname=%~dpnx0
FOR /F "usebackq tokens=1 delims=]" %%I IN (`find /n "-!!! Directory list-" "%selfname%"`) DO SET skiplines=%%I
REM next line gets from 2nd character to the EOL
SET skiplines=%skiplines:~1%

ECHO ON
FOR /F "usebackq skip=%skiplines% tokens=*" %%I IN ("%selfname%") DO (
  IF "%%I"=="." GOTO :exitfor
  IF NOT EXIST "%srcpath%%DealerPointCode%\%%I" MKDIR "%srcpath%%DealerPointCode%\%%I"
)
:exitfor
IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%
SET IEpath=%ProgramFiles%\Internet Explorer\iexplore.exe

FOR /F "usebackq delims=." %%I IN (`c:\SysUtils\lbrisar\getver.exe "%IEpath%"`) DO SET IEver=%%I
IF "%IEver%" EQU "8" SET cmdlnopt=-noframemerging

START "" "%IEpath%" %cmdlnopt% https://dealer.beeline.ru/

rem use command line option -noframemerging for IE8
rem about -noframemerging see http://blogs.msdn.com/b/askie/archive/2009/05/08/session-management-within-internet-explorer-8-0.aspx
rem in short: certificate is not re-requested if HKCU\Software\Microsoft\Internet Explorer\Main\FrameMerging = 1

EXIT /B

REM next line is "Begin-of-List" marker
REM -!!! Directory list-
DATA
DATA\ARCH
DATA\EXPORT
DATA\HELP
DATA\IMPORT
DATA\REG
DATA\REG\ERROR
DATA\REG\OK
DATA\REG\READY
DATA\REG\SENT
DATA\SUSPEND
DATA\TEMPLATE
LOG
.
REM DO NOT REMOVE last dot
REM as it is "End-of-List" marker
