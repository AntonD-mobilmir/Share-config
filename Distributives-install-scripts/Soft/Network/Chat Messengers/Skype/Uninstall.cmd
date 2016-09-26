@REM coding:OEM

rem Skype 4.2.169
MsiExec.exe /X{D103C4BA-F905-437A-8049-DB24763BBE36} /quiet /norestart

rem Skype 5.1
MsiExec.exe /X{9C538746-C2DC-40FC-B1FB-D4EA7966ABEB} /quiet /norestart
rem Skype 5.3
MsiExec.exe /X{F1CECE09-7CBE-4E98-B435-DA87CDA86167} /quiet /norestart

rem user Skype installations
MsiExec.exe /X{F1CECE09-7CBE-4E98-B435-DA87CDA86167} /quiet /norestart

rem Skype Business (msi distributive)
MsiExec.exe /X{1845470B-EB14-4ABC-835B-E36C693DC07D} /quiet /norestart
