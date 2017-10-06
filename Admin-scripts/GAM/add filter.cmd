@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

rem https://github.com/jay0lee/GAM/wiki/ExamplesEmailSettings#create-a-filter
rem ECHO Creating filter fo all users. There is no way to list or remove filters administratively! & PAUSE& CALL gam.cmd all users filter from "*linkedin.com" label 

CALL gam.cmd user anticode@mobilmir.ru filter from "*linkedin.com" label Junk

rem from <email>|to <email>|subject <words>|haswords <words>|nowords <words>|musthaveattachment
rem   label <label name>|markread|archive|star|forward <email address>|trash|neverspam
PAUSE
