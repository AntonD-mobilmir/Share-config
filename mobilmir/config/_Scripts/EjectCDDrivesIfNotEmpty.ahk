;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

DriveGet ListLettersCD, List, CDROM

Loop Parse, ListLettersCD
{
    DriveGet StatusCD, StatusCD, %A_LoopField%:
    If StatusCD != open
	Drive Eject, %A_LoopField%:
}
