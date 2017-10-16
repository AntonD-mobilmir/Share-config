@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED xlnexe CALL "..\..\..\..\profiles$\Share\config\_Scripts\find_exe.cmd" xlnexe xln.exe c:\SysUtils\xln.exe "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\xln.exe" || EXIT /B -1
IF NOT DEFINED exe7z CALL "..\..\..\..\profiles$\Share\config\_Scripts\find7zexe.cmd" || EXIT /B -1
)
(
PUSHD "%~dp0"
    FOR %%I IN (*.cmd *.ahk) DO %xlnexe% %%I "%USERPROFILE%\Git\Share-config\Rarus_ShopBTS_InitialBase\%%~I"
POPD
%exe7z% x -aoa -o"%USERPROFILE%\Git\Share-config\Rarus_ShopBTS_InitialBase\Rarus_Scripts" -- Rarus_Scripts.7z
%exe7z% x -aoa -o"%USERPROFILE%\Git\Share-config\Rarus_ShopBTS_InitialBase\D_1S_Rarus_ShopBTS_ShopBTS_Add" -- D_1S_Rarus_ShopBTS\ShopBTS_Add.7z
%exe7z% x -aoa -o"%USERPROFILE%\Git\Share-config\Rarus_ShopBTS_InitialBase\MailLoader-unpacked-dist" -xr!*.exe -xr!*.chm -- MailLoader\dist.7z
)
