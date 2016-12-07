@REM coding:OEM
SET nightlydistpath=%~dp0temp\ftp.mozilla.org\pub\mozilla.org\thunderbird\nightly\latest-comm-1.9.2
FOR /F "usebackq delims=" %%I IN (`%SystemDrive%\SysUtils\UnxUtils\find.exe "%nightlydistpath%" -name *.win32*.exe`) DO %%I
