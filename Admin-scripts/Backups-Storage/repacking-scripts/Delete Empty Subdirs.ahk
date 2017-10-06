#NoEnv

If %0%
    Loop %0%
    {
	arg := %A_Index%
	cleanup(arg)
    }
Else
    cleanup("\\?\" . A_WorkingDir)

cleanup(dir) {
    Loop %dir%\*,2,1
    {
	IfNotExist %A_LoopFileFullPath%\*
	{
	    FileRemoveDir %A_LoopFileFullPath%
	    If ErrorLevel
		FileAppend Cannot remove dir %A_LoopFileFullPath%`n,*,CP866
	    Else
		FileAppend %A_LoopFileFullPath%`n,*,CP866
	}
    }
}
