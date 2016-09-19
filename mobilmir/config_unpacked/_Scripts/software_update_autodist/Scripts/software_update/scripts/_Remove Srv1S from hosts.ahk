#NoEnv
#SingleInstance ignore

hostsFile=%A_WinDir%\system32\drivers\etc\hosts
hostsFileBackup=%hostsFile%.%A_Now%
hostsFileNew=%A_WinDir%\system32\drivers\etc\hosts.new%A_Now%

Loop Read, %hostsFile%, %hostsFileNew%
{
    If A_LoopReadLine Not Contains Srv1S,172.22.2.100
	FileAppend %A_LoopReadLine%`n
}

FileMove %hostsFile%,%hostsFileBackup%
FileMove %hostsFileNew%,%hostsFile%
