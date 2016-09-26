@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

REM http://www.74k.org/java-uninstall-remove-guids-strings

REM 7u80
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F03217080FF} /qn /norestart

REM 7u72
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F03217072FF} /qn /norestart

REM 7u76
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F03217076FF} /qn /norestart

REM Uninstall Java 7 Update 67
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F03217067FF} /qn /norestart

REM Uninstall Java 7 Update 65
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F03217065FF} /qn /norestart

REM Uninstall Java 7 Update 60
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F03217060FF} /qn /norestart

REM Uninstall Java 7 Update 55
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217055FF} /qn /norestart

REM Uninstall Java 7 Update 51
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217051FF} /qn /norestart

REM Uninstall Java 7 Update 45
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217045FF} /qn /norestart

REM Uninstall Java 7 Update 40
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217040FF} /qn /norestart

REM Uninstall Java 7 Update 40 ? 64 bit
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F86417040FF} /qn /norestart

REM Uninstall Java 7 Update 25 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417025FF} /qn /norestart

REM Uninstall Java 7 Update 25
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217025FF} /qn /norestart

REM Uninstall Java 7 Update 21 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417021FF} /qn /norestart

REM Uninstall Java 7 Update 21
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217021FF} /qn /norestart

REM Uninstall Java 7 Update 17 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417017FF} /qn /norestart

REM Uninstall Java 7 Update 17
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217017FF} /qn /norestart

REM Uninstall Java 7 Update 16 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417016FF} /qn /norestart

REM Uninstall Java 7 Update 16
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217016FF} /qn /norestart

REM Uninstall Java 7 Update 15 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417015FF} /qn /norestart

REM Uninstall Java 7 Update 15
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217015FF} /qn /norestart

REM Uninstall Java 7 Update 14 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417014FF} /qn /norestart

REM Uninstall Java 7 Update 14
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217014FF} /qn /norestart

REM Uninstall Java 7 Update 13 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417013FF} /qn /norestart

REM Uninstall Java 7 Update 13
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217013FF} /qn /norestart

REM Uninstall Java 7 Update 12 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417012FF} /qn /norestart

REM Uninstall Java 7 Update 12
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217012FF} /qn /norestart

REM Uninstall Java 7 Update 11 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417011FF} /qn /norestart

REM Uninstall Java 7 Update 11
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217011FF} /qn /norestart

REM Uninstall Java 7 Update 10 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417010FF} /qn /norestart

REM Uninstall Java 7 Update 10
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217010FF} /qn /norestart

REM Uninstall Java 7 Update 9 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417009FF} /qn /norestart

REM Uninstall Java 7 Update 9
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217009FF} /qn /norestart

REM Uninstall Java 7 Update 8 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417008FF} /qn /norestart

REM Uninstall Java 7 Update 8
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217008FF} /qn /norestart

REM Uninstall Java 7 Update 7 ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417007FF} /qn /norestart

REM Uninstall Java 7 Update 7
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217007FF} /qn /norestart

REM Uninstall Java 7 Update 6
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217006FF} /qn /norestart

REM Uninstall Java 7 Update 6  ? 64 bit
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F86417006FF} /qn /norestart

REM Uninstall Java 7 Update 5
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F83217005FF} /qn /norestart

REM Uninstall Java 7 Update 5  ? 64 bit
msiexec.exe /X {26A24AE4-039D-4CA4-87B4-2F86417005FF} /qn /norestart

REM Uninstall Java 7 Update 4 ? 64 bit
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F86417004FF} /qn /norestart

REM Uninstall Java 7 Update 4
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217004FF} /qn /norestart

REM Uninstall Java 7 Update 3 ? 64 bit
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F86417003FF} /qn /norestart

REM Uninstall Java 7 Update 3
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217003FF} /qn /norestart

REM Uninstall Java 7 Update 2 ? 64 bit
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F86417002FF} /qn /norestart

REM Uninstall Java 7 Update 2
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217002FF} /qn /norestart

REM Uninstall Java 7 Update 1 ? 64 bit
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F86417001FF} /qn /norestart

REM Uninstall Java 7 Update 1
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83217001FF} /qn /norestart
