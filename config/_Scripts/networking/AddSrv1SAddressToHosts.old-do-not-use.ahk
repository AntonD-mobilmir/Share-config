;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance off

hostsFile=%A_WinDir%\system32\drivers\etc\hosts
hostsFileBackup=%hostsFile%.%A_Now%

FileMove %hostsFile%,%hostsFileBackup%

Loop Read, %hostsFileBackup%, %hostsFile%
{
    If A_LoopReadLine Not Contains Srv1S,172.22.2.100
	FileAppend %A_LoopReadLine%`n
}

FileAppend `n172.22.2.17	Srv1S`n172.22.2.17	Srv1S.office0.mobilmir`n,%hostsFile%
