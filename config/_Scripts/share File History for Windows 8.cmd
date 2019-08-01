@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

SETLOCAL ENABLEEXTENSIONS

    IF NOT DEFINED targetDir (
	SET "targetDir=R:\File History"
	SET "guessedTargetDir=1"
    )
    SET "shareName=File History$"
)
:tryAgain
(
    MKDIR "%targetDir%"
    IF NOT EXIST "%targetDir%" (
	IF DEFINED guessedTargetDir (SET "targetDir=" & GOTO :AskAnotherDir)
	EXIT /B
    )

    %SystemRoot%\system32\compact.exe /C "%targetDir%"
    rem ATTRIB +H %targetDir%
    %SystemRoot%\system32\NET.exe SHARE "%shareName%"="%targetDir%" /GRANT:Users,FULL /REMARK:"������ ��� �����쭮� ���ਨ 䠩���"
    %SystemRoot%\system32\NET.exe SHARE "%shareName%"="%targetDir%" /GRANT:���짮��⥫�,FULL /REMARK:"������ ��� �����쭮� ���ਨ 䠩���"

    CALL "%~dp0Security\FSACL_FileHistory.cmd" "%targetDir%"
    EXIT /B
)
:AskAnotherDir
(SETLOCAL
    IF NOT DEFINED Unattended IF "%RunInteractiveInstalls%"=="0" SET "Unattended=1"
    IF DEFINED Unattended EXIT /B 1
    ECHO �� 㤠���� ᮧ���� "%targetDir%".
    ECHO ������ ����� �����, � ���ன �ॡ���� �।��⠢��� ��騩 ����� � ����ந�� ��ࠬ���� ������᭮��, ��� 㪠��� ������ ��ப� ^(������ Enter^) ��� �⬥��.
    SET /P "targetDir=> "
    ECHO Entered targetDir="%targetDir%"
    IF NOT DEFINED targetDir EXIT /B 1
)
CALL :checktargetDir "%targetDir%" || CALL :checktargetDir %targetDir%
(
ENDLOCAL
SET "targetDir=%targetDir%"
GOTO :tryAgain
)
:checktargetDir <path>
(
    IF EXIST "%~1" SET "targetDir=%~1" & EXIT /B 0
EXIT /B 1
)
