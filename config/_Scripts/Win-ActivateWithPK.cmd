@(REM coding:CP866
rem https://trello.com/c/Y6uaH2WB/5-��⨢���-windows-ᮧ�����-��ࠧ�-��⥬�
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    SET "key=%~1"
    IF NOT DEFINED Unattended IF "%RunInteractiveInstalls%"=="0" SET "Unattended=1"
    IF NOT DEFINED key IF NOT DEFINED Unattended SET /P "key=����: "
    IF NOT DEFINED ErrorCmd (
	IF DEFINED Unattended (
	    SET "ErrorCmd=ping -n 30 127.0.0.1 >nul"
	) ELSE SET "ErrorCmd=(ECHO &PAUSE)"
    )
)
(
%SystemRoot%\System32\cscript.exe %windir%\System32\slmgr.vbs /ipk "%key%" || %ErrorCmd%
IF NOT ERRORLEVEL 1 (
    CLS
    ECHO ���� ��⠭����� � ॥���. �஢���� ��⨢���, � �᫨ ���믮����� - ������� ���࠭���� ���������.
    PAUSE
)
rem 	cscript.exe %windir%\System32\slmgr.vbs /ato &
rem ��뢠�� ������� ��⨢��� �� Win10 �� 1809Oct. 1809Oct ��� �⮣� ���� �� ��⨢������ ;-(
rem up 2019-01-24: ��宦�, �஬� 1809Oct � ��᫥����� ���������ﬨ :-/ ��� � ���� --- ᭮�� ������� ��⨢���.
rem up 2019-01-24: SET "Activate=1"
rem up 2019-01-24: CALL "%~dp0CheckWinVer.cmd" 10.0 && CALL "%~dp0CheckWinVer.cmd" 10.0.17763.134 || SET "Activate="
rem up 2019-01-24: IF DEFINED Activate %SystemRoot%\System32\cscript.exe %windir%\System32\slmgr.vbs /ato || %ErrorCmd%
%SystemRoot%\System32\cscript.exe %windir%\System32\slmgr.vbs /cpky || %ErrorCmd%
EXIT /B
)
