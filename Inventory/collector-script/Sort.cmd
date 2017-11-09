@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "ReportsSource=%~dp0Reports\"
SET "ReportsDest=\\Srv0\profiles$\Share\Inventory\actual\"
)
(
FOR /D %%I IN ("%ReportsDest%RetailDepts\*") DO (
    IF EXIST "%ReportsSource%%%~nxI-*.7z" FOR %%J IN ("%ReportsSource%%%~nxI-k *.7z" "%ReportsSource%%%~nxI-2 *.7z" "%ReportsSource%%%~nxI-3 *.7z" "%ReportsSource%%%~nxI-nb *.7z") DO MOVE "%%~J" "%%~I\"
)
FOR %%I IN ("%ReportsSource%*.7z") DO (
    SET "pathReport=%%~fI"
    SET "nameReport=%%~nxI"
    REM since filename is like "bmts-2  20160829_135506.7z" or "lenovo-b570e TVID=599172161 20160204_130506.7z", following will pass two or three args, first of which is hostname
    CALL :PutReportToAppropriateDir %%~nI || (ECHO No destination found for "%%~nI">&2)
)
EXIT /B
)
:PutReportToAppropriateDir
(
    IF "%~1"=="%hostReport%" (
	IF DEFINED destPath GOTO :DoMove
	EXIT /B
    )
    SET "hostReport=%~1"

    IF /I "%nameReport:~0,2%"=="IT"			SET "destPath=%ReportsDest%office\IT\" & GOTO :DoMove
    
    IF /I "%nameReport:~0,4%"=="HRM-"			SET "destPath=%ReportsDest%office\HRM\" & GOTO :DoMove
    IF /I "%nameReport:~0,4%"=="NRG-"			SET "destPath=%ReportsDest%NRG\" & GOTO :DoMove
    IF /I "%nameReport:~0,4%"=="Svc-"			SET "destPath=%ReportsDest%mmsvc\" & GOTO :DoMove

    IF /I "%nameReport:~0,5%"=="Kassa"			SET "destPath=%ReportsDest%office\FinDept\" & GOTO :DoMove
    IF /I "%nameReport:~0,5%"=="sklad"			SET "destPath=%ReportsDest%office\Warehouse\" & GOTO :DoMove

    IF /I "%nameReport:~0,6%"=="Lawyer"			SET "destPath=%ReportsDest%office\lawyers\" & GOTO :DoMove

    IF /I "%nameReport:~0,7%"=="ComDept"		SET "destPath=%ReportsDest%office\" & GOTO :DoMove
    IF /I "%nameReport:~0,7%"=="CommOps"		SET "destPath=%ReportsDest%office\CommOps\" & GOTO :DoMove
    IF /I "%nameReport:~0,7%"=="FinDept"		SET "destPath=%ReportsDest%office\FinDept\" & GOTO :DoMove
    IF /I "%nameReport:~0,7%"=="priemka"		SET "destPath=%ReportsDest%mmsvc\" & GOTO :DoMove
    IF /I "%nameReport:~0,7%"=="SecCab-"		SET "destPath=%ReportsDest%office\Security\" & GOTO :DoMove

    IF /I "%nameReport:~0,8%"=="ConfRoom"		SET "destPath=%ReportsDest%office\shared\" & GOTO :DoMove
    IF /I "%nameReport:~0,8%"=="MSICX420"		SET "destPath=%ReportsDest%office\RetailMgr\" & GOTO :DoMove
    IF /I "%nameReport:~0,8%"=="MSIU140 "		SET "destPath=%ReportsDest%office\directors\" & GOTO :DoMove

    IF /I "%nameReport:~0,9%"=="iRU-Brava"		SET "destPath=%ReportsDest%office\shared\" & GOTO :DoMove
    IF /I "%nameReport:~0,9%"=="RetailMgr"		SET "destPath=%ReportsDest%office\RetailMgr\" & GOTO :DoMove
    IF /I "%nameReport:~0,9%"=="Warehouse"		SET "destPath=%ReportsDest%office\Warehouse\" & GOTO :DoMove
    
    IF /I "%nameReport:~0,10%"=="SecOffice-"		SET "destPath=%ReportsDest%office\Security\" & GOTO :DoMove

    IF /I "%nameReport:~0,11%"=="Bookkeeping"		SET "destPath=%ReportsDest%office\FinDept\" & GOTO :DoMove
    IF /I "%nameReport:~0,11%"=="KMV-CashCab"		SET "destPath=%ReportsDest%office\FinDept\" & GOTO :DoMove
    IF /I "%nameReport:~0,11%"=="KMV-ProdMgr"		SET "destPath=%ReportsDest%office\ComDept\" & GOTO :DoMove

    IF /I "%nameReport:~0,12%"=="CtrlRevDept-"		SET "destPath=%ReportsDest%office\FinDept\" & GOTO :DoMove
    IF /I "%nameReport:~0,12%"=="ProdManagers"		SET "destPath=%ReportsDest%office\ComDept\" & GOTO :DoMove
    IF /I "%nameReport:~0,12%"=="TT-DDG-HP635"		SET "destPath=%ReportsDest%office\ComDept\" & GOTO :DoMove

    IF /I "%nameReport:~0,13%"=="KMV-RetailMgr"		SET "destPath=%ReportsDest%office\RetailMgr\" & GOTO :DoMove

    IF /I "%nameReport:~0,15%"=="Boss-secretary "	SET "destPath=%ReportsDest%office\Adm\" & GOTO :DoMove
    IF /I "%nameReport:~0,12%"=="basement-01 "		SET "destPath=%ReportsDest%office\Adm\" & GOTO :DoMove
    IF /I "%nameReport:~0,11%"=="AsusPro5DI " 		SET "destPath=%ReportsDest%office\Adm\" & GOTO :DoMove
    
    IF /I "%nameReport:~0,15%"=="AcerAspire7720G"	SET "destPath=%ReportsDest%office\IT\office0\" & GOTO :DoMove
    IF /I "%nameReport:~0,9%"=="srv-inet "		SET "destPath=%ReportsDest%office\IT\office0\" & GOTO :DoMove
    IF /I "%nameReport:~0,5%"=="Srv0 "			SET "destPath=%ReportsDest%office\IT\office0\" & GOTO :DoMove
    IF /I "%nameReport:~0,14%"=="testpc-old-bb "	SET "destPath=%ReportsDest%office\IT\office0\" & GOTO :DoMove
    IF /I "%nameReport:~0,15%"=="Warehouse-Kassa"	SET "destPath=%ReportsDest%office\FinDept\" & GOTO :DoMove
    SET "destPath="
)
(   REM don't remove blockend-blockstart, for hostReport variable become available
    REM fallback --- if no predefined dest found, search by filename
    FOR /R "%ReportsDest%" %%A IN ("%hostReport% *.7z") DO IF EXIST %%A SET "destPath=%%~dpA" & GOTO :DoMove
EXIT /B 1
)
:DoMove
(
    IF EXIST "%destPath%" ( 
	ECHO Перемещение "%nameReport%" в "%destPath%"
	MOVE "%pathReport%" "%destPath%"
	EXIT /B
    ) ELSE (
	ECHO Не существует папка "%destPath%" для перемещения "%nameReport%"
	EXIT /B 1
    )
)
