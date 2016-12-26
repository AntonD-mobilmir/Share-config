rem Fake "move" command implementation.
rem 
rem Thank's to Edward Goldobin
rem 
rem If you preferred archiver hasn't possibility move files to archive you 
rem can use below described method:
rem 
rem >>I have a suggestion how to implement "move files to archive" with BIX
rem >>archiver. In multiarc.ini, under [BIX] you add:
rem >>
rem >>Move=c:\Program Files\wincmd\Packer plug-ins\milti\bixmov.bat %PQ %AQ 
rem >%FQ
rem >>
rem >>And the content of bixmov.bat is:

@"%1" -r0 -y a "%2" "%3"
if ERRORLEVEL==1 GOTO :end
@del "%3"
:end
