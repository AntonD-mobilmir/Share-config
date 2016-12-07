@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

SET lProgramFiles=%ProgramFiles%
IF DEFINED ProgramFiles(x86) SET lProgramFiles=%ProgramFiles(x86)%
"%lProgramFiles%\GPGshell\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
rem /LOG=filename
