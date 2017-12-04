;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
EnvGet SystemRoot,SystemRoot

argc=%0%
If (argc) {
    Loop %argc%
	Loop Files, % %A_Index%, D
	    cleanupDealerBeelineDir(A_LoopFileFullPath)
} Else
    cleanupDealerBeelineDir("d:\dealer.beeline.ru")

ExitApp

cleanupDealerBeelineDir(dir) {
    backupWorkDir=%A_WorkingDir%
    Loop %Dir%, 2
    {
	SetWorkingDir %A_LoopFileFullPath%
	; Remove scripts and resources
	FileDelete beeline DOL2 fix dirs.ahk
	FileDelete beeline DOL2.ahk
	FileDelete beeline DOL2.stub.ahk
	FileDelete criacx.cab
	FileDelete dealer.beeline.ru.cmd
	FileDelete DOL2.template.7z
	FileDelete favicon.ico (16×16).ico
	FileDelete remote_register.cmd
	FileDelete update_dealer_beeline_activex in windir.cmd
	FileDelete update_dealer_beeline_activex.cmd
	FileDelete сделать ярлык для Билайн Дилер Он-Лайн.ahk
	FileDelete 32-bit CU.reg
	FileDelete 32-bit LM.reg
	
	FileRemoveDir reg, 1
	; unregister ActiveX component and remove bin
	If (FileExist("bin\criacx.ocx"))
	    RunWait %SystemRoot%\System32\regsvr32.exe /s /u bin\criacx.ocx
	FileRemoveDir bin, 1

	; Remove logs and static data
	FileDelete beeline DOL2 fix dirs.ahk.log
	FileDelete beeline DOL2.ahk.log
	FileDelete beeline DOL2.ahk.log.bak
	FileDelete delete ext stats.reg

	FileRemoveDir DOL2\LOGS, 1
	;FileRemoveDir DOL2\DATA\ARCH
	
	Loop *, 2
	{
	    FileRemoveDir %A_LoopFileFullPath%\LOG, 1
	    FileRemoveDir %A_LoopFileFullPath%\DATA\HELP, 1
	    FileDelete %A_LoopFileFullPath%\%A_LoopFileName%.reg
	    FileDelete %A_LoopFileFullPath%\%A_LoopFileName%.cmd
	}
	
	; Remove empty dirs
	Loop *, 2, 1
	{
	    curPath:=A_LoopFileFullPath
	    While (curPath) {
		FileRemoveDir %curPath%
		If (ErrorLevel)
		    break
		SplitPath curPath, , curPath
	    }
	}
    }
    SetWorkingDir %backupWorkDir%
}
