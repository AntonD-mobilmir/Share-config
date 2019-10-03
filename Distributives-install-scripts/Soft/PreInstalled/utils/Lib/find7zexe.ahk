;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

; include to auto-execute section to run this during initialization. Maybe define exe7z global beforehand.
Try
    exe7z:=find7zexe()
Catch
    exe7z:=find7zaexe()
If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    FileAppend %exe7z%`n,*,CP1
    
    Exit
}

find7zexe(exename:="7z.exe", paths*) {
    local regPaths, bakRegView, i, regpath, currpath, ProgramFilesx86, SystemDrive, path, fullpath
    ;key, value, flag "this is path to exe (only use directory)"
    regPaths := [["HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command",,1]
		,["HKEY_CURRENT_USER\Software\7-Zip", "Path"]
		,["HKEY_LOCAL_MACHINE\Software\7-Zip", "Path"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe", "Path"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe",,1]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "InstallLocation"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "UninstallString", 1] ]
    
    bakRegView := A_RegView
    For i,regpath in regPaths {
	SetRegView 64
	RegRead currpath, % regpath[1], % regpath[2]
	SetRegView %bakRegView%
	If (regpath[3]) 
	    SplitPath currpath,,currpath
	Try return Check7zDir(exename, Trim(currpath,""""))
    }
    
    If(IsFunc(("findexe"))) {
	EnvGet ProgramFilesx86,ProgramFiles(x86)
	EnvGet SystemDrive,SystemDrive
	Try return Func("findexe").Call(exename, ProgramFiles . "\7-Zip", ProgramFilesx86 . "\7-Zip", SystemDrive . "\Program Files\7-Zip", SystemDrive . "\Arc\7-Zip")
	Try return Func("findexe").Call("7za.exe", SystemDrive . "\Arc\7-Zip")
    }
    
    For i,path in paths {
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%exename%
	    If (FileExist(fullpath))
		return fullpath
	}
    }
    
    Throw exename " not found"
}

Check7zDir(exename,dir7z) {
    If(SubStr(dir7z,0)=="\")
	dir7z:=SubStr(dir7z,1,-1)
    If (!FileExist(exe7z := dir7z "\" exename))
	Throw Exception("File not found in dir",, """" exename """ in """ dir7z """")
    return exe7z
}

find7zaexe(paths*) {
    If(!IsObject(paths))
	paths := []
    paths.push(	  "\Distributives\Soft\PreInstalled\utils"
		, "D:\Distributives\Soft\PreInstalled\utils"
		, "\\localhost\Distributives\Soft\PreInstalled\utils"
		, "\\Srv1S-B.office0.mobilmir\Distributives\Soft\PreInstalled\utils"
		, "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils"
		, A_LineFile "\..\..\..\..\Soft\PreInstalled\utils")
    If (A_Is64bitOS)
        Try return find7zexe("7za64.exe", paths*)
    return find7zexe("7za.exe", paths*)
}

find7zGUIorAny(paths*) {
    Try return find7zexe("7zg.exe", paths*)
    Try return find7zexe("7z.exe", paths*)
    return find7zaexe(paths*)
}

;The FileName parameter may optionally be preceded by *i and a single space, which causes the program to ignore any failure to read the included file. For example: #Include *i SpecialOptions.ahk. This option should be used only when the included file's contents are not essential to the main script's operation.
#include *i %A_LineFile%\..\findexe.ahk
