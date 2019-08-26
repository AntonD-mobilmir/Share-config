@(REM coding:CP866
    REM by LogicDaemon <www.logicdaemon.ru>
    REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    %SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO ��ਯ� "%~f0" ��� �ࠢ ����������� �� ࠡ�⠥� & PING -n 30 127.0.0.1 >NUL & EXIT /B )
    
    IF DEFINED PROCESSOR_ARCHITEW6432 (
	"%SystemRoot%\SysNative\cmd.exe" /C %0 %*
	EXIT /B
    )
    SETLOCAL ENABLEEXTENSIONS
    IF NOT "%~2"=="" SET "copyBackup=%~2"

    SET "robocopyDcopy=DAT"
    CALL "%~dp0CheckWinVer.cmd" 8 || SET "robocopyDcopy=T"
    
    FOR /f "usebackq tokens=3*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname"`) DO SET "Hostname=%%~J"
    IF NOT DEFINED PassFilePath (
	IF EXIST "C:\Users\Install\Install-pwd.txt" (
	    SET "PassFilePath=C:\Users\Install\Install-pwd.txt"
	) ELSE IF EXIST "%USERPROFILE%\Install-pwd.txt" (
	    SET "PassFilePath=%USERPROFILE%\Install-pwd.txt"
	)
    )
    
    IF NOT DEFINED includes SET "includes=-allCritical"
    SET "dstBaseDir=%~1"
    REM Windows 8+ cannot restore from compressed images
    CALL "%~dp0CheckWinVer.cmd" 6.2 && SET "DontCompressLocal=1"
    IF NOT DEFINED dstBaseDir (
        CALL :AcquireDstBaseDir
    ) ELSE (
        CALL :SetAndCheckDstDirWIB || EXIT /B
        SET "wbAdminQuiet=-quiet"
    )
)
@IF /I "%dstBaseDir%" NEQ "R:" IF NOT DEFINED copyBackup (
        IF NOT DEFINED copyToR IF EXIST "R:\WindowsImageBackup\%Hostname%\*" (
            ECHO ����� �� R: �� �㤥� ᮧ����, �.�. � ���� �����祭�� 㦥 ���� ��ࠧ %Hostname%.
            SET "copyToR=0"
    )
    IF NOT DEFINED copyToR IF EXIST R:\ SET /P "copyToR=������� ����� ��ࠧ� �� R: ? [1=��] "
)
@(
    IF /I "%dstBaseDir%" NEQ "R:" IF NOT DEFINED copyBackup IF "%copyToR%"=="1" SET "copyBackup=R:"
    IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd"
)
@(
    MKDIR "%dstDirWIB%" 2>NUL
    %SystemRoot%\System32\wbadmin.exe START BACKUP -backupTarget:"%dstBaseDir%" %includes% %wbAdminQuiet%
    IF ERRORLEVEL 1 CALL :wbAdminError || EXIT /B
    COPY /B /Y "%ProgramData%\mobilmir.ru\trello-id.txt" "%dstDirWIB%\%Hostname%\"
    MKDIR "%dstDirWIB%\%Hostname%\Logs"
    COPY /B /Y "%SystemRoot%\Logs\WindowsBackup\*.*" "%dstDirWIB%\%Hostname%\Logs\"
    
    IF DEFINED PassFilePath CALL :CopyEchoPassFilePath
    rem previous thing inine instead of CALL causes this:
    rem 	The syntax of the command is incorrect.
    rem 	C:\WINDOWS\system32>    DIR /AD /B "R:\WindowsImageBackup\IT-Test-E7500lga775\Backup*">>
    
    ECHO ������ ����஫��� �㬬
    rem ����஢���� ��ࠫ���쭮 � ����⮬: ����� �१ START, � ��᫥ ����஢���� ��४�਩ �஢�ઠ: ����� 7-zip �����稫 �����뢠�� ����஫�� �㬬�, ����஢���� 䠩��   
    IF DEFINED exe7z START "����� ����஫��� �㬬 ��� %dstDirWIB%\%Hostname%" /MIN %comspec% /C "%exe7z% h -sccUTF-8 -scrc* -r "%dstDirWIB%\%Hostname%\*" >"%dstDirWIB%\%Hostname%-7zchecksums.txt" 2>&1 && MOVE /Y "%dstDirWIB%\%Hostname%-7zchecksums.txt" "%dstDirWIB%\%Hostname%\7zchecksums.txt""
    
    CALL :CompressAndDefrag "%dstBaseDir%"
    IF DEFINED copyBackup (
	CALL :CopyImageTo "%copyBackup%"
	CALL :CompressAndDefrag "%copyBackup%"
    ) 
)
ECHO %DATE% %TIME% �������� ����砭�� ����� ����஫��� �㬬 "%dstDirWIB%\%Hostname%\7zchecksums.txt"
:waitmore
@(
    @IF NOT EXIST "%dstDirWIB%\%Hostname%\7zchecksums.txt" IF EXIST "%dstDirWIB%\%Hostname%-7zchecksums.txt" (
        PING 127.0.0.1 -n 15 >NUL
        GOTO :waitmore
    )
    IF DEFINED copyBackup COPY /Y /D /B "%dstDirWIB%\%Hostname%\7zchecksums.txt" "%copyBackup%\WindowsImageBackup\%Hostname%\7zchecksums.txt"
    
    EXIT /B
)
:CopyEchoPassFilePath
IF NOT DEFINED AutohotkeyExe CALL "%~dp0FindAutoHotkeyExe.cmd"
(
    COPY /B /Y "%PassFilePath%" "%dstDirWIB%\%Hostname%\password.txt"
    IF DEFINED AutohotkeyExe START "" %AutohotkeyExe% "%~dp0AddUsers\ReadPwd_PostToFormWithBackupName.ahk" "%PassFilePath%" "%dstDirWIB%\%Hostname%"
    CALL :DirToPassFile "%dstDirWIB%\%Hostname%\Backup*"
EXIT /B
)
:CompressAndDefrag <target>
@(
    CALL :IfUNC %1 && (
        START "���⨥ %~1" /MIN /LOW %SystemRoot%\System32\compact.exe /C /EXE:LZX /S:%1
        EXIT /B
    )
    IF NOT "%DontCompressLocal%"=="1" (
        ECHO ����� ᦠ�� � ���ࠣ����樨 %1
        START "Compressing and Defragging %~1" /LOW /MIN %comspec% /C ""%~dp0compress and defrag WindowsImageBackup.cmd" %1"
    )
EXIT /B
)
:IfUNC <path>
(
    SETLOCAL
    SET "t=%~1"
)
(
    ENDLOCAL
    IF "%t:~0,2%"=="\\" EXIT /B 0
    EXIT /B 1
)
:CopyImageTo <path>
@(
    ECHO ����஢���� ��ࠧ� � "%~1\WindowsImageBackup\%Hostname%"
    IF EXIST "%~1\WindowsImageBackup\%Hostname%" (
	ECHO ����� "%~1\WindowsImageBackup\%Hostname%" 㦥 �������. ��� �㤥� ��२��������.
	CALL :AppendTimeToDirName "%~1\WindowsImageBackup\%Hostname%"
    ) ELSE IF NOT EXIST "%~1\WindowsImageBackup" (
        MKDIR "%~1\WindowsImageBackup" || CALL :SetErrorCheckdstDirWIB "MKDIR %~1\WindowsImageBackup"
    )
    MKDIR "%~1\WindowsImageBackup\%Hostname%" || CALL :SetErrorCheckdstDirWIB "MKDIR %~1\WindowsImageBackup\%Hostname%"
    rem when making local backup, WindowsImageBackup gets inherited permissions from root, and subfolder with actual backup: http://imgur.com/a/ttyqJ
    rem 	owned by SYSTEM
    rem 	Full access for Administrators, Backup Operators and CREATOR OWNER
    rem 	without inheritance
    rem Administrators=S-1-5-32-544
    rem SYSTEM=S-1-5-18
    rem Backup Operators=S-1-5-32-551
    rem CREATOR OWNER=S-1-3-0
    %SystemRoot%\System32\takeown.exe /A /R /D Y /F "%~1\WindowsImageBackup\%Hostname%"
    %SystemRoot%\System32\icacls.exe "%~1\WindowsImageBackup\%Hostname%" /reset /T /C /L
    %SystemRoot%\System32\icacls.exe "%~1\WindowsImageBackup\%Hostname%" /grant "*S-1-5-32-544:(OI)(CI)F" /grant "*S-1-5-18:(OI)(CI)F" /grant "*S-1-5-32-551:(OI)(CI)F" /grant "*S-1-3-0:(OI)(CI)F" /C /L
    %SystemRoot%\System32\icacls.exe "%~1\WindowsImageBackup\%Hostname%" /inheritance:r /C /L
    %SystemRoot%\System32\icacls.exe "%~1\WindowsImageBackup\%Hostname%" /setowner "*S-1-5-18" /T /C /L
    START "����஢���� ��ࠧ� � %~1\WindowsImageBackup\%Hostname%" /MIN %SystemRoot%\System32\robocopy.exe "%dstDirWIB%\%Hostname%" "%~1\WindowsImageBackup\%Hostname%" /MIR /DCOPY:%robocopyDcopy% /TBD /ETA
    IF DEFINED PassFilePath CALL :DirToPassFile "%~1\WindowsImageBackup\%Hostname%\Backup*"
EXIT /B
)
:DirToPassFile <path>
(
    DIR /AD /B /O-D "%~1" >>"%PassFilePath%" 2>&1
EXIT /B
)
:AcquireDstBaseDir
@(
    SET /P "dstBaseDir=���� �����祭�� ��� १�ࢭ�� ����� (����� 㪠�뢠�� ��� ����祪, �. -backupTarget � �ࠢ�� wbAdmin): "
    IF NOT DEFINED dstBaseDir EXIT /B 1
    CALL :SetAndCheckDstDirWIB && EXIT /B
    ECHO ���஡�� ��� ࠧ, ���� ������ ������ ��ப� ��� �⬥�� ᮧ����� ��ࠧ�.
    GOTO :AcquireDstBaseDir
)
:SetAndCheckDstDirWIB
@IF "%dstBaseDir:~-1%"=="\" SET "dstBaseDir=%dstBaseDir:~0,-1%"
@(
    IF "%dstBaseDir:~0,2%"=="\\" (
        CALL :SplitNetPath netHost netShare "%dstBaseDir%" || EXIT /B
    ) ELSE IF NOT "%dstBaseDir:~1,2%"==":" EXIT /B 1
    SET "dstDirWIB=%dstBaseDir%\WindowsImageBackup"
)
:CheckdstDirWIB
@SET "netShareRemounted="
:CheckdstDirWIBRetry
@(
    SET "ErrorCheckdstDirWIB="
    MKDIR "%dstDirWIB%\checkdir.tmp" 2>NUL || CALL :SetErrorCheckdstDirWIB "create dir"
    ECHO.>"%dstDirWIB%\checkdir.tmp\checkflag.tmp" || CALL :SetErrorCheckdstDirWIB "create file"
    IF NOT EXIST "%dstDirWIB%\checkdir.tmp\checkflag.tmp" (
        IF DEFINED netHost IF DEFINED netShare IF NOT DEFINED netShareRemounted (
            SET "netShareRemounted=1"
            NET USE "\\%netHost%" /DELETE
            NET USE "\\%netHost%\%destShare%" /DELETE
            NET USE "\\%netHost%\%destShare%" /PERSISTENT:NO && GOTO :CheckdstDirWIBRetry
        )
        ECHO ���������� ᮧ���� "%dstDirWIB%\checkdir.tmp\checkflag.tmp", ���⮬� 㪠����� ���� "%dstDirWIB%" ����� �ᯮ�짮���� ��� ��࠭���� ��ࠧ�.
        RD "%dstDirWIB%\checkdir.tmp"
        EXIT /B 1
    )
    DEL "%dstDirWIB%\checkdir.tmp\checkflag.tmp"
    RD "%dstDirWIB%\checkdir.tmp"
EXIT /B 0
)
:SetErrorCheckdstDirWIB
@(
    SET "ErrorCheckdstDirWIB=%ErrorCheckdstDirWIB%, %~1 Error: %ERRORLEVEL%"
EXIT /B
)
:SplitNetPath <hostVar> <shareVar> <path>
@(
    FOR /F "delims=\ tokens=1,2" %%A IN ("%~3") DO (
        IF "%%~A"=="" EXIT /B 1
        IF "%%~B"=="" EXIT /B 2
        SET "%~1=%%~A"
        SET "%~2=%%~B"
        EXIT /B
    )
EXIT /B 3
)
:wbAdminError
@(
    rem @SET "wbAdminError=%ErrorLevel%"
    FOR /R /D %%A IN ("%dstDirWIB%\%Hostname%\*.*") DO RD "%%~A" >NUL <NUL
    RD "%dstDirWIB%\%Hostname%" >NUL <NUL
    IF NOT EXIST "%dstDirWIB%\%Hostname%" RD "%dstDirWIB%" >NUL <NUL
    ECHO �訡�� wbAdmin: %ErrorLevel%
    ECHO ��ਯ� �� ����饭 � ᫥���騬� ��ࠬ��ࠬ�: %*
    IF NOT DEFINED wbAdminQuiet PAUSE
    EXIT /B %ErrorLevel%
)
:AppendTimeToDirName
@(SETLOCAL
    @SET "suffix="
    FOR /D %%A IN (%1) DO @SET "dtime=%%~tA"
)
    @SET "dtime=%dtime::=%"
    @SET "dtime=%dtime:/=%"
:AppendTimeToDirName_TryAnotherSuffix
    @IF EXIST "%~1.%dtime%" SET "suffix=.%RANDOM%"
@(
    IF EXIST "%~1.%dtime%%suffix%" GOTO :AppendTimeToDirName_TryAnotherSuffix
    MOVE /Y %1 "%~1\WindowsImageBackup\%Hostname%%suffix%"
ENDLOCAL
EXIT /B
)

rem ���⠪��: WBADMIN START BACKUP
rem     [-backupTarget:{<楫����_⮬_��娢�樨> | <楫����_�⥢��_�����>}]
rem     [-include:<����砥��_⮬�>]
rem     [-allCritical]
rem     [-user:<���_���짮��⥫�>]
rem     [-password:<��஫�>]
rem     [-noInheritAcl]
rem     [-noVerify]
rem     [-vssFull | -vssCopy]
rem     [-quiet]

rem ���ᠭ��: ᮧ����� ��娢� � 㪠����묨 ��ࠬ��ࠬ�. �᫨ ��ࠬ���� �� 㪠����
rem � ����祭� ���������� ��娢��� �� �ᯨᠭ��, ᮧ������ ��娢 � ��ࠬ��ࠬ�
rem ��娢�樨 �� �ᯨᠭ��.

rem ��ࠬ����

rem -backupTarget   ��ᯮ������� �࠭���� ��娢� ��� �⮩ ����樨. ����室���
rem                 㪠���� �㪢� ��᪠ (f:), ���� �� �᭮�� GUID � �ଠ�
rem                 \\?\Volume{GUID} ��� UNC-���� � 㤠������ ��饩 �����
rem                 (\\<���_�ࢥ�>\<���_��饣�_�����>\).
rem                 �� 㬮�砭�� ��娢 ��࠭���� �� ᫥���饬� �����:
rem                 \\<���_�ࢥ�>\<���_��饣�_�����>\
rem                 WindowsImageBackup\<���_��娢��㥬���_��������>\.
rem                 �����! �᫨ ��娢 ��� ������ � ⮣� �� �������� ��࠭����
rem                 � ���� � �� �� 㤠������ ����� ����� ��᪮�쪮 ࠧ, �
rem                 �।���� ����� ��娢� ��१����뢠����. �஬� ⮣�, � ��砥
rem                 ᡮ� ����樨 ��娢�樨 �������� ����� ��娢�, ��᪮���
rem                 ���� ����� 㦥 ��१���ᠭ�, � ����� ���ਣ���� ���
rem                 �ᯮ�짮�����. �⮡� �������� �������� ���樨, ���
rem                 㯮�冷祭�� ��娢�� ४��������� ᮧ������ � 㤠������ ��饩
rem                 ����� �������� �����. � �⮬ ��砥 �������� ������
rem                 ���ॡ���� � ��� ࠧ� ����� ���� �� �ࠢ����� � த�⥫�᪮�
rem                 ������.

rem -include        ���������� �����묨 ᯨ᮪ ����⮢, ����� ��������� �
rem                 ��娢. ����᪠���� ����祭�� ��᪮�쪨� 䠩���, ����� ���
rem                 ⮬��. ���� � ⮬� ����� 㪠���� � �ᯮ�짮������ �㪢� ��᪠
rem                 ⮬�, �窨 ������祭�� ⮬� ��� ����� ⮬� �� �᭮�� GUID.
rem                 �᫨ �ᯮ������ ��� ⮬� �� �᭮�� GUID, � ��� ������
rem                 ���������� ᨬ����� ���⭮� ��ᮩ ���� (\). �� 㪠�����
rem                 ��� � 䠩�� � ����� 䠩�� ����� �ᯮ�짮���� ����⠭�����
rem                 ���� (*). �ᯮ������ ⮫쪮 � ��ࠬ��஬ -backupTarget.

rem -allCritical    ��⮬���᪮� ����祭�� � ��娢 ��� ����᪨� ⮬��, �.�.
rem                 ⮬��, ����� ᮤ�ঠ� 䠩�� � ���������� ����樮����
rem                 ��⥬�, � ⠪�� ���� ��㣨� ����⮢, �������� � �������
rem                 ��ࠬ��� -include. ��� ��ࠬ��� ४��������� �ᯮ�짮����
rem                 �� ᮧ����� ��娢� ��� ����⠭������� ��室���� ���ﭨ�
rem                 ��⥬� ��� ����⠭������� ���ﭨ� ��⥬�. �ᯮ������
rem                 ⮫쪮 � ��ࠬ��஬ -backupTarget.

rem -user           ��� ���짮��⥫�, ����饣� ����� � �ࠢ�� ����� � �����
rem                 �⥢�� �����, �᫨ ��娢 ������ �ᯮ�������� � ��饩 �⥢��
rem                 �����.

rem -password       ��஫� ��� ����� ���짮��⥫�, 㪠������� � ��ࠬ��� -user.

rem -noInheritAcl   �ਬ������ ࠧ�襭�� ᯨ᪠ �ࠢ����� ����㯮�,
rem                 ᮮ⢥������� ������� � ������� ��ࠬ��஢ -user � -password
rem                 ���� �����, � ����� \\<���_�ࢥ�>\<���_��饣�_�����>\
rem                 WindowsImageBackup\<��娢��㥬�_��������>\ (�����, � ���ன
rem                 ᮤ�ন��� ��娢). ��� ����祭�� ����㯠 � ��娢� ����室���
rem                 ����� �� ���� ����� ��� ���� ����� 童�� ��㯯�
rem                 "������������" ��� "������� ��娢�" �� �������� � ��饩
rem                 ������. �᫨ ��ࠬ��� -noInheritAcl �� �ᯮ������, � ��
rem                 㬮�砭�� ࠧ�襭�� ᯨ᪠ �ࠢ����� ����㯮� 㤠������ ��饩
rem                 ����� �ਬ������� ��� ����� <��娢��㥬�_��������>. �
rem                 १���� �� ���짮��⥫�, ����騩 ����� � 㤠������ ��饩
rem                 �����, ����� ������� ����� � �⮬� ��娢�.

rem -noVerify       �᫨ ��� ��ࠬ��� �����, � �஢�ઠ ��娢��, �����뢠���� ��
rem                 �ꥬ�� ���⥫�, ���ਬ�� DVD-���, �� �믮������. �᫨ ���
rem                 ��ࠬ��� �� �ᯮ������, �����뢠��� �� �ꥬ�� ���⥫�
rem                 ��娢� �஢������� �� ����稥 �訡��.

rem -vssFull        �᫨ ����� ��� ��ࠬ���, � �믮������ ������ ��娢��� �
rem                 ������� �㦡� ⥭����� ����஢���� ⮬��. ��ୠ� �������
rem                 ��娢��㥬��� 䠩�� ����������, �⮡� ��ࠧ��� 䠪� ��娢�樨.
rem                 �᫨ ��� ��ࠬ��� �� 㪠���, � � ������� �������
rem                 WBADMIN START BACKUP �믮������ ��������� ��娢���, �
rem                 ��ୠ�� ��娢��㥬�� 䠩��� �� �⮬ �� �����������.
rem                 ��������! �� �ᯮ���� ��� ��ࠬ���, �᫨ ��� ��娢�樨
rem                 �ਫ������, �ᯮ�������� �� ⮬�� ᮧ��������� ��娢�,
rem                 �ᯮ������ �ணࠬ��, �⫨筠� �� ��⥬� ��娢�樨 ������
rem                 Windows Server. � ��⨢��� ��砥 ����� ���� ����襭�
rem                 楫��⭮��� ���������, ࠧ������ � ��㣨� ��娢��,
rem                 ᮧ�������� ��㣮� �ணࠬ��� ��娢�樨.

rem -vssCopy        �᫨ ����� ��� ��ࠬ���, �믮������ ��������� ��娢��� �
rem                 ������� �㦡� ⥭����� ����஢���� ⮬��. ��ୠ�� ��娢��㥬��
rem                 䠩��� �� �⮬ �� �����������. �� ���祭�� �ᯮ������ ��
rem                 㬮�砭��.

rem -quiet          �믮������ ������� ��� �⮡ࠦ���� �ਣ��襭�� ���
rem                 ���짮��⥫�.

rem �ਬ��:

rem WBADMIN START BACKUP -backupTarget:f: -include:e:,d:\mountpoint, \\?\Volume{cc566d14-44a0-11d9-9d93-806e6f6e6963}\
