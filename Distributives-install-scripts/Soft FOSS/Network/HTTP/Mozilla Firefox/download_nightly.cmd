@REM coding:OEM
START "" /WAIT /B /D"%srcpath%temp" wget -rl1 -np -N -e robots=off -Afirefox-*.en-US.win32.installer.exe http://ftp.mozilla.org/pub/mozilla.org/firefox/nightly/latest-mozilla-central/
