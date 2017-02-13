;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

argc=%0%
If (argc) {
    Loop %argc%
    {
	path:=%A_Index%
	Loop Files, %path%, D
	{
	    cleanupDealerBeelineDir(A_LoopFileFullPath)
	}
    }
} Else {
    cleanupDealerBeelineDir("d:\dealer.beeline.ru")
}

ExitApp

cleanupDealerBeelineDir(dir) {
    backupWorkDir=%A_WorkingDir%
    Loop %Dir%, 2
    {
	SetWorkingDir %A_LoopFileFullPath%
	FileDelete criacx.cab
	FileDelete dealer.beeline.ru.cmd
	FileDelete favicon.ico (16×16).ico
	FileDelete remote_register.cmd
	FileDelete update_dealer_beeline_activex.cmd
	FileDelete сделать ярлык для Билайн Дилер Он-Лайн.ahk
	FileRemoveDir bin
	
	; Remove logs and static data
	Loop *, 2
	{
	    FileRemoveDir %A_LoopFileFullPath%\LOG, 1
	    FileRemoveDir %A_LoopFileFullPath%\DATA\HELP, 1
	}
	
	; Remove empty dirs
	Loop *, 2, 1
	{
	    curPath:=A_LoopFileFullPath
	    While curPath
	    {
		FileRemoveDir %curPath%
		SplitPath curPath, , curPath
	    }
	}
    }
    SetWorkingDir %backupWorkDir%
}
