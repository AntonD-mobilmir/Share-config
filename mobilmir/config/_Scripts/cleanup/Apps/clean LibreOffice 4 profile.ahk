;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

Global flags

Loop %0% ; for each argument
{
    CurrentArg := %A_Index%
    If (SubStr(CurrentArg, 1, 1) == "/") { ; it's a switch
	StringLower CurrentArg, CurrentArg
	flags .= "," . SubStr(CurrentArg, 2)
    } Else { ; otherwise it's dir-path
	fDirInArgs := true
	Loop %CurrentArg%, 2
	    CleanLOProfile(CheckIfLOProfile(A_LoopFileFullPath))
    }
}

If (!fDirInArgs) ; if there were no dir-paths in args, process current dir
    CleanLOProfile(A_AppData . "\LibreOffice\4\user")

CleanLOProfile(dir) {

    FileDelete %dir%\*.tmp
    FileDelete %dir%\config\javasettings_Windows_x86.xml
    FileRemoveDir %dir%\backup, 1
    FileRemoveDir %dir%\extensions, 1
    FileRemoveDir %dir%\uno_packages, 1
    
    RemoveEmptyWithSubdirs(dir)
}

CheckIfLOProfile(dir) {
    return CheckIfProfile("registrymodifications.xcu", dir, "\LibreOffice\4\user")
}

CheckIfProfile(file, dir, subpath="") {
    IfExist %dir%\%file%
	return dir
    
    If (SubStr(subpath,1,1) == "\")
	subpath := SubStr(subpath, 2)
    Loop Parse, subpath, \
    {
	subPos += StrLen(A_LoopField) + 1
	IfExist %dir%\%A_LoopField%
	    return CheckIfProfile(file, dir . "\" . A_LoopField, SubStr(subpath, subPos + 1))
    }
    
    return false
}

If2(a,b) {
    If a
	return a
    return b
}

RemoveEmptyWithSubdirs(dir) {
    Loop Files, %dir%\*, D
    {
	RemoveEmptyWithSubdirs(A_LoopFileFullPath)
    }
    FileRemoveDir %A_LoopFileFullPath%
}