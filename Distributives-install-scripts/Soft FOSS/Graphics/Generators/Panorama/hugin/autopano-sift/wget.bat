@Echo Off
setlocal

set sitename=user.cs.tu-berlin.de
set URL=http://user.cs.tu-berlin.de/~nowozin/autopano-sift/

rem set http_proxy=http://Srv-Net:3128/
rem set ftp_proxy=http://Srv-Net:3128/
rem -c		### contunue downloading files
rem -a wget.log	### write all output to that log
rem -t 64	### 64 retries
rem -N		### use timestamping
rem -R <url>	### do not download

if not exist %sitename% start "Unpacking site..." /wait /D"%~dp0" rar x -r %sitename%.rar *.* %sitename%\

start "Downloading %sitename%" /wait /D"%~dp0" wget.exe -w 5 --random-wait --waitretry=300 -N -w 0 --progress=bar -rH -x -E -e robots=off -k -K -p -D %sitename% -np %URL%

start "Packing %sitename%" /wait /D"%~dp0" rar m -as -r -ep1 %sitename%.rar %sitename%\*.*

rd /q %~dp0\%sitename%
