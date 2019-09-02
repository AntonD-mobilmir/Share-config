@(REM coding:CP866
    REM by LogicDaemon <www.logicdaemon.ru>
    REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    %SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
    
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
            ECHO Копия на R: не будет создана, т.к. в месте назначения уже есть образ %Hostname%.
            SET "copyToR=0"
    )
    IF NOT DEFINED copyToR IF EXIST R:\ SET /P "copyToR=Сделать копию образа на R: ? [1=да] "
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
    
    ECHO Запись контрольных сумм
    rem копирование параллельно с расчётом: запуск через START, и после копирования директорий проверка: когда 7-zip закончил записывать контрольные суммы, копирование файла   
    IF DEFINED exe7z START "Расчет контрольных сумм для %dstDirWIB%\%Hostname%" /MIN %comspec% /C "%exe7z% h -sccUTF-8 -scrc* -r "%dstDirWIB%\%Hostname%\*" >"%dstDirWIB%\%Hostname%-7zchecksums.txt" 2>&1 && MOVE /Y "%dstDirWIB%\%Hostname%-7zchecksums.txt" "%dstDirWIB%\%Hostname%\7zchecksums.txt""
    
    CALL :CompressAndDefrag "%dstBaseDir%"
    IF DEFINED copyBackup (
	CALL :CopyImageTo "%copyBackup%"
	CALL :CompressAndDefrag "%copyBackup%"
    ) 
)
ECHO %DATE% %TIME% Ожидание окончания записи контрольных сумм "%dstDirWIB%\%Hostname%\7zchecksums.txt"
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
CALL "%~dp0FindAutoHotkeyExe.cmd"
(
    COPY /B /Y "%PassFilePath%" "%dstDirWIB%\%Hostname%\password.txt"
    IF DEFINED AutohotkeyExe START "" %AutohotkeyExe% "%~dp0AddUsers\ReadPwd_PostToFormWithBackupName.ahk" "%PassFilePath%" "%dstDirWIB%\%Hostname%"
    CALL :DirToPassFile "%dstDirWIB%\%Hostname%\Backup*"
EXIT /B
)
:CompressAndDefrag <target>
@(
    CALL :IfUNC %1 && (
        START "Сжатие %~1" /MIN /LOW %SystemRoot%\System32\compact.exe /C /EXE:LZX /S:%1
        EXIT /B
    )
    IF NOT "%DontCompressLocal%"=="1" (
        ECHO Запуск сжатия и дефрагментации %1
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
    ECHO Копирование образа в "%~1\WindowsImageBackup\%Hostname%"
    IF EXIST "%~1\WindowsImageBackup\%Hostname%" (
	ECHO Папка "%~1\WindowsImageBackup\%Hostname%" уже существует. Она будет переименована.
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
    %SystemRoot%\System32\icacls.exe "%~1\WindowsImageBackup\%Hostname%" /grant "*S-1-5-32-544:(OI)(CI)F" /grant "*S-1-5-18:(OI)(CI)F" /grant "*S-1-5-32-551:(OI)(CI)F" /grant "*S-1-3-0:(OI)(CI)F" /C /L
    %SystemRoot%\System32\icacls.exe "%~1\WindowsImageBackup\%Hostname%" /inheritance:r /C /L
    %SystemRoot%\System32\icacls.exe "%~1\WindowsImageBackup\%Hostname%" /setowner "*S-1-5-18" /T /C /L
    %SystemRoot%\System32\icacls.exe "%~1\WindowsImageBackup\%Hostname%\*" /reset /T /C /L
    START "Копирование образа в %~1\WindowsImageBackup\%Hostname%" /MIN %SystemRoot%\System32\robocopy.exe "%dstDirWIB%\%Hostname%" "%~1\WindowsImageBackup\%Hostname%" /MIR /DCOPY:%robocopyDcopy% /TBD /ETA
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
    SET /P "dstBaseDir=Место назначения для резервной копии (здесь указывать без кавычек, см. -backupTarget в справке wbAdmin): "
    IF NOT DEFINED dstBaseDir EXIT /B 1
    CALL :SetAndCheckDstDirWIB && EXIT /B
    ECHO Попробуйте ещё раз, либо введите пустую строку для отмены создания образа.
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
        RD "%dstDirWIB%\checkdir.tmp"
        IF DEFINED netHost IF DEFINED netShare IF NOT DEFINED netShareRemounted (
            SET "netShareRemounted=1"
            NET USE "\\%netHost%" /DELETE
            NET USE "\\%netHost%\%destShare%" /DELETE
            NET USE "\\%netHost%\%destShare%" /PERSISTENT:NO && GOTO :CheckdstDirWIBRetry
        )
        ECHO Невозможно создать "%dstDirWIB%\checkdir.tmp\checkflag.tmp", поэтому указанный путь "%dstDirWIB%" нельзя использовать для сохранения образа.
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
    ECHO Ошибка wbAdmin: %ErrorLevel%
    ECHO Скрипт был запущен со следующими параметрами: %*
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

rem Синтаксис: WBADMIN START BACKUP
rem     [-backupTarget:{<целевой_том_архивации> | <целевая_сетевая_папка>}]
rem     [-include:<включаемые_тома>]
rem     [-allCritical]
rem     [-user:<имя_пользователя>]
rem     [-password:<пароль>]
rem     [-noInheritAcl]
rem     [-noVerify]
rem     [-vssFull | -vssCopy]
rem     [-quiet]

rem Описание: создание архива с указанными параметрами. Если параметры не указаны
rem и включена ежедневная архивация по расписанию, создается архив с параметрами
rem архивации по расписанию.

rem Параметры

rem -backupTarget   Расположение хранения архива для этой операции. Необходимо
rem                 указать букву диска (f:), путь на основе GUID в формате
rem                 \\?\Volume{GUID} или UNC-путь к удаленной общей папке
rem                 (\\<имя_сервера>\<имя_общего_ресурса>\).
rem                 По умолчанию архив сохраняется по следующему адресу:
rem                 \\<имя_сервера>\<имя_общего_ресурса>\
rem                 WindowsImageBackup\<имя_архивируемого_компьютера>\.
rem                 Важно! Если архив для одного и того же компьютера сохраняется
rem                 в одну и ту же удаленную общую папку несколько раз, то
rem                 предыдущая версия архива перезаписывается. Кроме того, в случае
rem                 сбоя операции архивации возможна потеря архива, поскольку
rem                 старая версия уже перезаписана, а новая непригодна для
rem                 использования. Чтобы избежать подобной ситуации, для
rem                 упорядочения архивов рекомендуется создавать в удаленной общей
rem                 папке вложенные папки. В этом случае вложенным папкам
rem                 потребуется в два раза больше места по сравнению с родительской
rem                 папкой.

rem -include        Разделенный запятыми список элементов, которые включаются в
rem                 архив. Допускается включение нескольких файлов, папок или
rem                 томов. Путь к тому можно указать с использованием буквы диска
rem                 тома, точки подключения тома или имени тома на основе GUID.
rem                 Если используется имя тома на основе GUID, то оно должно
rem                 завершаться символом обратной косой черты (\). При указании
rem                 пути к файлу в имени файла можно использовать подстановочный
rem                 знак (*). Используется только с параметром -backupTarget.

rem -allCritical    Автоматическое включение в архив всех критических томов, т.е.
rem                 томов, которые содержат файлы и компоненты операционной
rem                 системы, а также любых других элементов, заданных с помощью
rem                 параметра -include. Этот параметр рекомендуется использовать
rem                 при создании архива для восстановления исходного состояния
rem                 системы или восстановления состояния системы. Используется
rem                 только с параметром -backupTarget.

rem -user           Имя пользователя, имеющего доступ с правом записи в общую
rem                 сетевую папку, если архив должен располагаться в общей сетевой
rem                 папке.

rem -password       Пароль для имени пользователя, указанного в параметре -user.

rem -noInheritAcl   Применение разрешений списка управления доступом,
rem                 соответствующих заданным с помощью параметров -user и -password
rem                 учетным данным, к папке \\<имя_сервера>\<имя_общего_ресурса>\
rem                 WindowsImageBackup\<архивируемый_компьютер>\ (папка, в которой
rem                 содержится архив). Для получения доступа к архиву необходимо
rem                 ввести эти учетные данные или учетные данные члена группы
rem                 "Администраторы" или "Операторы архива" на компьютере с общей
rem                 папкой. Если параметр -noInheritAcl не используется, то по
rem                 умолчанию разрешения списка управления доступом удаленной общей
rem                 папки применяются для папки <архивируемый_компьютер>. В
rem                 результате любой пользователь, имеющий доступ к удаленной общей
rem                 папке, может получить доступ к этому архиву.

rem -noVerify       Если этот параметр задан, то проверка архивов, записываемых на
rem                 съемный носитель, например DVD-диск, не выполняется. Если этот
rem                 параметр не используется, записываемые на съемный носитель
rem                 архивы проверяются на наличие ошибок.

rem -vssFull        Если задан этот параметр, то выполняется полная архивация с
rem                 помощью службы теневого копирования томов. Журнал каждого
rem                 архивируемого файла обновляется, чтобы отразить факт архивации.
rem                 Если этот параметр не указан, то с помощью команды
rem                 WBADMIN START BACKUP выполняется копирующая архивация, а
rem                 журналы архивируемых файлов при этом не обновляются.
rem                 Внимание! Не используйте этот параметр, если для архивации
rem                 приложений, расположенных на томах создаваемого архива,
rem                 используется программа, отличная от системы архивации данных
rem                 Windows Server. В противном случае может быть нарушена
rem                 целостность добавочных, разностных и других архивов,
rem                 создаваемых другой программой архивации.

rem -vssCopy        Если задан этот параметр, выполняется копирующая архивация с
rem                 помощью службы теневого копирования томов. Журналы архивируемых
rem                 файлов при этом не обновляются. Это значение используется по
rem                 умолчанию.

rem -quiet          Выполнение команды без отображения приглашений для
rem                 пользователя.

rem Пример:

rem WBADMIN START BACKUP -backupTarget:f: -include:e:,d:\mountpoint, \\?\Volume{cc566d14-44a0-11d9-9d93-806e6f6e6963}\
