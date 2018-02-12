@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED exe7z CALL "%~dp0..\..\..\..\config\_Scripts\find7zexe.cmd" 
IF NOT DEFINED exe7z CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\find7zexe.cmd" || EXIT /B -1
)
(
    FOR %%A IN ("Rarus_Scripts.7z" "D_1S_Rarus_ShopBTS\ShopBTS_Add.7z" "MailLoader\dist.7z") DO (
	RD /S /Q "%USERPROFILE%\Git\Share-config\Rarus_ShopBTS_InitialBase_unpacked\%%~nA"
	%exe7z% x -aoa -o"%USERPROFILE%\Git\Share-config\Rarus_ShopBTS_InitialBase_unpacked\%%~nA" -xr!*.exe -xr!*.chm -- "%~dp0%%~A"
    )
)
