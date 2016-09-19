#NoEnv
#SingleInstance force

RemoveTarget=%A_StartMenuCommon%\BitTorrent Sync.lnk
EndTime := A_TickCount + 300000

While A_TickCount < EndTime
{
    IfExist %RemoveTarget%
	break
    
    Sleep 998
}

FileDelete %RemoveTarget%
TrayTip Removing BTSync shortcut, Result %ERRORLEVEL% Removing %RemoveTarget%

Sleep 5000
