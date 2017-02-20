@(REM coding:CP866
    REM by LogicDaemon <www.logicdaemon.ru>
    REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF DEFINED PROCESSOR_ARCHITEW6432 (
	"%SystemRoot%\SysNative\cmd.exe" /C %0 %*
	EXIT /B
    )
    rem ECHO OFF
    SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    FOR /f "usebackq tokens=3*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname"`) DO SET "Hostname=%%~J"
    IF NOT DEFINED PassFilePath (
	IF EXIST "C:\Users\Install\Install-pwd.txt" (
	    SET "PassFilePath=C:\Users\Install\Install-pwd.txt"
	) ELSE IF EXIST "%USERPROFILE%\Install-pwd.txt" (
	    SET "PassFilePath=%USERPROFILE%\Install-pwd.txt"
	)
    )

    IF NOT DEFINED includes SET "includes=-allCritical"
    SET "DstBaseDir=%~1"
    REM Windows 8+ cannot restore from compressed images
    CALL "%~dp0CheckWinVer.cmd" 6.2 && SET "DontCompressLocal=1"
    IF NOT DEFINED DstBaseDir SET /P "DstBaseDir=�㪢� ⮬� ��� �⥢�� ����� ��� १�ࢭ�� ����� (��� ����祪): "
)
IF "%DstBaseDir:~-1%"=="\" SET "DstBaseDir=%DstBaseDir:~0,-1%"
(
    SET "DstDirWIB=%DstBaseDir%\WindowsImageBackup"
    IF /I "%DstBaseDir%"=="R:" SET "CopyToR=0"
    IF NOT DEFINED CopyToR IF EXIST "R:\WindowsImageBackup\%Hostname%\*" (
	    ECHO ����� �� R: �� �㤥� ᮧ����, �.�. � ���� �����祭�� 㦥 ���� ��ࠧ %Hostname%.
	    SET "CopyToR=0"
	) ELSE IF EXIST R:\ SET /P "CopyToR=������� ����� ��ࠧ� �� R: ? [1=��] "
)
    IF NOT DEFINED md5sumexe CALL "%~dp0find_exe.cmd" md5sumexe %SystemDrive%\SysUtils\kliu\md5sum.exe "\\Srv0.office0.mobilmir\profiles$\Share\Program Files\md5sum.exe" "%DstDirWIB%\md5sum.exe"
(
    MKDIR "%DstDirWIB%" 2>NUL
    %SystemRoot%\System32\wbadmin.exe START BACKUP -backupTarget:"%DstBaseDir%" %includes% -quiet
    
    IF DEFINED PassFilePath CALL :CopyEchoPassFilePath
    rem previous thing inine instead of CALL causes this:
    rem 	The syntax of the command is incorrect.
    rem 	C:\WINDOWS\system32>    DIR /AD /B "R:\WindowsImageBackup\IT-Test-E7500lga775\Backup*">>
    
    ECHO ������ �㬬 MD5
    rem ����஢���� ��ࠫ���쭮 � ����⮬ MD5: ����� �१ START, � ��᫥ ����஢���� ��४�਩ �஢�ઠ: ����� MD5 �����稫, ����஢���� MD5 䠩��

    IF DEFINED md5sumexe START "������ MD5" /MIN %comspec% /C "( %md5sumexe% -r "%DstDirWIB%\%Hostname%\*" >"%DstDirWIB%\%Hostname%-checksums.md5" ) && MOVE /Y "%DstDirWIB%\%Hostname%-checksums.md5" "%DstDirWIB%\%Hostname%\checksums.md5""

    IF "%CopyToR%"=="1" (
	CALL :CopyImageTo R:
	CALL :CompressAndDefrag R:
    )
    CALL :CompressAndDefrag "%DstBaseDir%"

    EXIT /B
)
:CopyEchoPassFilePath
IF NOT DEFINED AutohotkeyExe CALL "%~dp0FindAutoHotkeyExe.cmd"
(
    COPY /B /Y "%PassFilePath%" "%DstDirWIB%\%Hostname%\password.txt"
    IF DEFINED AutohotkeyExe START "" %AutohotkeyExe% "%~dp0AddUsers\ReadPwd_PostToFormWithBackupName.ahk" "%PassFilePath%" "%DstDirWIB%\%Hostname%"
    CALL :DirToPassFile "%DstDirWIB%\%Hostname%\Backup*"
EXIT /B
)

:CompressAndDefrag <target>
(
    CALL :IfUNC %1 && (
	START "���⨥ %~1" %SystemRoot%\System32\compact.exe /C /EXE:LZX /S:%1
	EXIT /B
    )
    IF "%DontCompressLocal%"=="1" EXIT /B
    ECHO ����� ᦠ�� � ���ࠣ����樨 %1
    IF EXIST "%~dp0compress and defrag.cmd" START "Compressing and Defragging %~1" /LOW /MIN %comspec% /C "%~dp0compress and defrag.cmd" %*
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
(
    IF EXIST "%~1\WindowsImageBackup\%Hostname%" (
	ECHO ����� "%~1\WindowsImageBackup\%Hostname%" 㦥 �������. �� ᮤ�ন��� �㤥� ��१���ᠭ�.
	MOVE /Y "%~1\WindowsImageBackup\%Hostname%" "%~1\WindowsImageBackup\%Hostname%.%RANDOM%"
    )

    ECHO ����஢���� ��ࠧ� � "%~1\WindowsImageBackup\%Hostname%"
    MKDIR "%~1\WindowsImageBackup\%Hostname%" 2>NUL
    XCOPY "%DstDirWIB%\%Hostname%" "%~1\WindowsImageBackup\%Hostname%" /I /G /H /R /E /K /O /B
    IF DEFINED PassFilePath CALL :DirToPassFile "%~1\WindowsImageBackup\%Hostname%\Backup*"
    
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

    ECHO �������� ����砭�� ����� MD5
)
:DirToPassFile <path>
(
    DIR /AD /B /O-D %1 >>"%PassFilePath%"
EXIT /B
)
:waitmore
(
    PING 127.0.0.1 -n 2 >NUL
    IF NOT EXIST "%DstDirWIB%\%Hostname%\checksums.md5" IF EXIST "%DstDirWIB%\%Hostname%-checksums.md5" GOTO :waitmore
    COPY /Y /D /B "%DstDirWIB%\%Hostname%\checksums.md5" "%~1\WindowsImageBackup\%Hostname%\checksums.md5"
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

rem WBADMIN START BACKUP -backupTarget:f: -include:e:,d:\mountpoint,
rem \\?\Volume{cc566d14-44a0-11d9-9d93-806e6f6e6963}\
