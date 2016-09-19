;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance off

dest := "d:\1S\Rarus\ShopBTS\Exchange"

nArg = %0%
If (nArg) {
    Loop %0%
    {
	Loop Files, % %A_Index%
	{
	    If (   RegexMatch(A_LoopFileName,"TS_.._\d{6}_\d{6}.*\.7z")
		|| RegexMatch(A_LoopFileName,"TS_\d{6}_\d{6}.*\.7z")) {
                TrayTip,, Распаковка %A_LoopFileName% в Exchange, 0x21
		Unpack(A_LoopFileLongPath, dest)
	    } Else {
		FileMove %A_LoopFileLongPath%, %dest%
		If (ErrorLevel)
                    TrayTip,, Ошибка при перемещениии файла %A_LoopFileName% в Exchange, 0x23
                Else
                    TrayTip,, Перемещение файла %A_LoopFileName% в Exchange успешно, 0x21
            }
	}
    }
    Sleep 3000
} Else {
    Run %A_WinDir%\explorer.exe "%dest%", %A_WinDir%
}

ExitApp

Unpack(arc, dest) {
    static exe7z := find7zGUIorAny()
    RunWait "%exe7z%" x -o"%dest%" -- "%arc%", %A_Temp%
}

find7zexe(exename="7z.exe", paths*) {
    ;key, value, flag "this is path to exe (only use directory)"
    regPaths := [["HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command",,1]
		,["HKEY_CURRENT_USER\Software\7-Zip", "Path"]
		,["HKEY_LOCAL_MACHINE\Software\7-Zip", "Path"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe", "Path"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe",,1]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "InstallLocation"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "UninstallString", 1] ]
    
    bakRegView := A_RegView
    For i,regpath in regPaths
    {
	SetRegView 64
	RegRead currpath, % regpath[1], % regpath[2]
	SetRegView %bakRegView%
	If (regpath[3]) 
	    SplitPath currpath,,currpath
	Try return Check7zDir(exename, Trim(currpath,""""))
    }
    
    findexefunc=findexe
    If(IsFunc(findexefunc)) {
	EnvGet ProgramFilesx86,ProgramFiles(x86)
	EnvGet SystemDrive,SystemDrive
	Try return %findexefunc%(exename, ProgramFiles . "\7-Zip", ProgramFilesx86 . "\7-Zip", SystemDrive . "\Program Files\7-Zip", SystemDrive . "\Arc\7-Zip")
	Try return %findexefunc%("7za.exe", SystemDrive . "\Arc\7-Zip")
    }
    
    For i,path in paths {
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%exename%
	    IfExist %fullpath%
		return fullpath
	}
    }
    
    Throw exename " not found"
}

Check7zDir(exename,dir7z) {
    If(SubStr(dir7z,0)=="\")
	dir7z:=SubStr(dir7z,1,-1)
    exe7z=%dir7z%\%exename%
    IfNotExist %exe7z%
	Throw exename " not found in " . dir7z
    return exe7z
}

find7zaexe(paths:="") {
    If(paths=="")
	paths := []
    paths.push("\Distributives\Soft\PreInstalled\utils", "D:\Distributives\Soft\PreInstalled\utils","W:\Distributives\Soft\PreInstalled\utils", "\\localhost\Distributives\Soft\PreInstalled\utils", "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils","\\192.168.1.80\Distributives\Soft\PreInstalled\utils")
    return find7zexe("7za.exe",paths*)
}

find7zGUIorAny() {
    Try	return find7zexe("7zg.exe")
    Try return find7zexe()
    return find7zaexe()
}
