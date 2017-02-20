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
    IF NOT DEFINED DstBaseDir SET /P "DstBaseDir=Буква тома или сетевая папка для резервной копии (без кавычек): "
)
IF "%DstBaseDir:~-1%"=="\" SET "DstBaseDir=%DstBaseDir:~0,-1%"
(
    SET "DstDirWIB=%DstBaseDir%\WindowsImageBackup"
    IF /I "%DstBaseDir%"=="R:" SET "CopyToR=0"
    IF NOT DEFINED CopyToR IF EXIST "R:\WindowsImageBackup\%Hostname%\*" (
	    ECHO Копия на R: не будет создана, т.к. в месте назначения уже есть образ %Hostname%.
	    SET "CopyToR=0"
	) ELSE IF EXIST R:\ SET /P "CopyToR=Сделать копию образа на R: ? [1=да] "
)
    IF NOT DEFINED md5sumexe CALL "%~dp0find_exe.cmd" md5sumexe %SystemDrive%\SysUtils\kliu\md5sum.exe "\\Srv0.office0.mobilmir\profiles$\Share\Program Files\md5sum.exe" "%DstDirWIB%\md5sum.exe"
(
    MKDIR "%DstDirWIB%" 2>NUL
    %SystemRoot%\System32\wbadmin.exe START BACKUP -backupTarget:"%DstBaseDir%" %includes% -quiet
    
    IF DEFINED PassFilePath CALL :CopyEchoPassFilePath
    rem previous thing inine instead of CALL causes this:
    rem 	The syntax of the command is incorrect.
    rem 	C:\WINDOWS\system32>    DIR /AD /B "R:\WindowsImageBackup\IT-Test-E7500lga775\Backup*">>
    
    ECHO Расчёт сумм MD5
    rem копирование параллельно с расчётом MD5: запуск через START, и после копирования директорий проверка: когда MD5 закончил, копирование MD5 файла

    IF DEFINED md5sumexe START "Запись MD5" /MIN %comspec% /C "( %md5sumexe% -r "%DstDirWIB%\%Hostname%\*" >"%DstDirWIB%\%Hostname%-checksums.md5" ) && MOVE /Y "%DstDirWIB%\%Hostname%-checksums.md5" "%DstDirWIB%\%Hostname%\checksums.md5""

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
	START "Сжатие %~1" %SystemRoot%\System32\compact.exe /C /EXE:LZX /S:%1
	EXIT /B
    )
    IF "%DontCompressLocal%"=="1" EXIT /B
    ECHO Запуск сжатия и дефрагментации %1
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
	ECHO Папка "%~1\WindowsImageBackup\%Hostname%" уже существует. Её содержимое будет перезаписано.
	MOVE /Y "%~1\WindowsImageBackup\%Hostname%" "%~1\WindowsImageBackup\%Hostname%.%RANDOM%"
    )

    ECHO Копирование образа в "%~1\WindowsImageBackup\%Hostname%"
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

    ECHO Ожидание окончания записи MD5
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

rem WBADMIN START BACKUP -backupTarget:f: -include:e:,d:\mountpoint,
rem \\?\Volume{cc566d14-44a0-11d9-9d93-806e6f6e6963}\
