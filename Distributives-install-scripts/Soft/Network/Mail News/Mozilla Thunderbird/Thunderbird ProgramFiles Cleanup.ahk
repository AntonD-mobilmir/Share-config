#NoEnv

EnvGet ProgramFiles_x86, ProgramFiles(x86)
IfExist %ProgramFiles_x86%
    MTProgramFilesDir=%ProgramFiles_x86%\Mozilla Thunderbird
Else
    MTProgramFilesDir=%ProgramFiles%\Mozilla Thunderbird

IfNotExist %MTProgramFilesDir%\*.moz-upgrade
    Exit

RegRead PendMoves, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\Session Manager, PendingFileRenameOperations
If PendMoves
{
    FileAppend Pending moves detected. Won't do anything until reboot., *, CP866
    Exit 32767 ; There are pending rename operations, wait for reboot
}

SetWorkingDir %MTProgramFilesDir%
FileDelete *.moz-delete
If ErrorLevel
{
    RepeatOnNextBoot=1
    FileAppend Cannot delete %ErrorLevel% files with mask "*.moz-delete". Scheduling move on reboot., *, CP866
    Loop *.moz-delete
	DllCall("MoveFileEx", "Str", A_LoopFileLongPath, "Str", "", "UInt", 0x4) ; 0x4 = MOVEFILE_DELAY_UNTIL_REBOOT
}

Loop *.moz-upgrade
{
    SplitPath A_LoopFileLongPath,OutFileName,,, OutNameNoExt
    FileMove %OutFileName%, %OutNameNoExt%, 1
    If ErrorLevel
    {
	RepeatOnNextBoot=1
	FileAppend Cannot rename "%OutFileName%". Scheduling move on reboot., *, CP866
	DllCall("MoveFileEx", "Str", A_LoopFileLongPath, "Str", "", "UInt", 0x4) ; 0x4 = MOVEFILE_DELAY_UNTIL_REBOOT
    }
}

If RepeatOnNextBoot
    Exit 32767
Else 
    Exit
