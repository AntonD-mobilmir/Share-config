@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF NOT DEFINED xlnexe CALL "..\..\..\..\profiles$\Share\config\_Scripts\find_exe.cmd" xlnexe xln.exe c:\SysUtils\xln.exe "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\xln.exe" || EXIT /B -1
IF NOT DEFINED exe7z CALL "..\..\..\..\profiles$\Share\config\_Scripts\find7zexe.cmd" || EXIT /B -1
SET "gitdst=%USERPROFILE%\Git\Share-config\Rarus_ShopBTS_InitialBase"
SET "linkMasks=*.cmd *.ahk *.reg *.txt *.url *.xml"
)
(
MKDIR "%gitdst%" 2>NUL

%exe7z% x -aoa -o"%gitdst%\Rarus_Scripts" -- Rarus_Scripts.7z
%exe7z% x -aoa -o"%gitdst%\D_1S_Rarus_ShopBTS_ShopBTS_Add" -- D_1S_Rarus_ShopBTS\ShopBTS_Add.7z
%exe7z% x -aoa -o"%gitdst%\MailLoader-unpacked-dist" -xr!*.exe -xr!*.chm -- MailLoader\dist.7z
PUSHD "%srcpath%" && (
    FOR %%I IN (%linkMasks%) DO %xlnexe% "%%~I" "%gitdst%\%%~I"
    SET "basePrefix="
    FOR /D %%A IN (*.*) DO CALL :LinkSubdir "%%~A"
    POPD
)
EXIT /B
)
:LinkSubdir <subPath>
(
    PUSHD "%baseSrc%%basePrefix%%~1" && (
	SETLOCAL
	SET "basePrefix=%basePrefix%\%~1"
	FOR %%I IN (%linkMasks%) DO (
	    MKDIR "%gitdst%%basePrefix%\%~1" 2>NUL
	    %xlnexe% "%%~I" "%gitdst%%basePrefix%\%~1\%%~I"
	)
	FOR /D %%A IN (*.*) DO CALL :LinkSubdir "%%~A"
	ENDLOCAL
	POPD
    )
EXIT /B
)