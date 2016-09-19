@(REM coding:OEM

NET STOP wsearch
SC STOP wsearch
%SystemRoot%\System32\ping.exe 127.0.0.1 -n 5 >NUL
%SystemRoot%\System32\TASKKILL.exe /F /IM SearchIndexer.exe
%SystemRoot%\System32\TASKKILL.exe /F /IM SearchFilterHost.exe
%SystemRoot%\System32\TASKKILL.exe /F /IM SearchProtocolHost.exe

rem move "%programdata%\microsoft\search\data\applications\windows\Windows.edb" "%programdata%\microsoft\search\data\applications\windows\Windows.edb.bak"
FOR /D %%I IN ("%ProgramData%\Microsoft\Search\Data\Applications\Windows\*") DO RD /S /Q %%I
DEL /F /Q "%programdata%\microsoft\search\Data\Applications\Windows\*"

IF NOT "%~1"=="" EXIT /B
IF /I "%~1"=="/NOWAIT" EXIT /B
ECHO Далее служба индексирования будет перезапущена, и индекс начнёт восстанавливаться.
PAUSE
%SystemRoot%\System32\SC.exe START wsearch
)
