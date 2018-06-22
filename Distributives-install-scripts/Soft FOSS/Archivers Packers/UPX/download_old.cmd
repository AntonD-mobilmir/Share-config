@REM coding:OEM
SET srcpath=%~dp0

rem only downloads source
rem http://sourceforge.net/projects/upx/files/latest/download *w.zip -N -Aw.zip

SET distcleanup=0
CALL \Scripts\_DistDownload_sf.cmd upx *.zip
