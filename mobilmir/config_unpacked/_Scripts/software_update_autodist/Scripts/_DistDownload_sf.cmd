@REM coding:OEM
SET distcleanup=1

rem %1 project name http://sourceforge.net/projects/<name>
rem %2 file name mask

CALL "%~dp0_DistDownload.cmd" http://sourceforge.net/projects/%1/files/latest/download %2 -m -l 1 -A "%~x2" -nd -H -D downloads.sourceforge.net -e "robots=off" -p --user-agent="Mozilla/5.0 (Windows NT 5.1; rv:0.0)"

REM Alternate download way (if there's only windows version):
rem CALL \Scripts\_DistDownload.cmd http://sourceforge.net/projects/%1/files/latest/download %2 -N -A "%~x2"
