@(REM coding:CP866
    IF NOT DEFINED md5sumexe CALL "%~dp0find_exe.cmd" md5sumexe %SystemDrive%\SysUtils\kliu\md5sum.exe "%DstDirWIB%\md5sum.exe" "\\Srv0.office0.mobilmir\profiles$\Share\Programs\md5sum.exe"
    SET "DstDirWIB=\\AcerAspire7720G.office0.mobilmir\wbadmin-Backups\WindowsImageBackup"
    FOR /f "usebackq tokens=3*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname"`) DO SET "Hostname=%%~J"
)
(
    IF NOT DEFINED md5sumexe CALL "%~dp0find_exe.cmd" md5sumexe %SystemDrive%\SysUtils\kliu\md5sum.exe "%DstDirWIB%\md5sum.exe" "\\Srv0.office0.mobilmir\profiles$\Share\Programs\md5sum.exe"
    START "Запись MD5" %comspec% /C "( %md5sumexe% -r "%DstDirWIB%\%Hostname%\*" >"%DstDirWIB%\%Hostname%-checksums.md5" ) && MOVE /Y "%DstDirWIB%\%Hostname%-checksums.md5" "%DstDirWIB%\%Hostname%\checksums.md5""
)
