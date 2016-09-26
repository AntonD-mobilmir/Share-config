;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet lProgramFiles, ProgramFiles(x86)
If (!lProgramFiles)
    EnvGet lProgramFiles, ProgramFiles

Uninstall("FreeVimager", "/s", lProgramFiles . "\FreeVimager")

Uninstall(name, switches, cleanupDir:=0) {
    SetRegView 32
    UninstallAllForCurrentRegView(name, switches, cleanupDir)
    If (A_Is64bitOS) {
	SetRegView 64
	UninstallAllForCurrentRegView(name, switches, cleanupDir)
    }
}

UninstallAllForCurrentRegView(name, switches, cleanupDir) {
    UninstallFromKey("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" . name, switches, cleanupDir)
    Loop Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, K
    {
	regKeyFullPath = %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%
	RegRead DisplayName, %regKeyFullPath%, DisplayName
	If (StartsWith(DisplayName, name))
	    UninstallFromKey(regKeyFullPath, switches, cleanupDir)
    }
}

UninstallFromKey(key, switches, cleanupDir) {
    RegRead UninstallString, %key%, QuietUninstallString
    If (UninstallString) {
	switches=
    } Else {
	RegRead UninstallString, %key%, UninstallString
;	"C:\Program Files (x86)\foobar2000\uninstall.exe" _?=C:\Program Files (x86)\foobar2000
	UninstallString := GetExecutablePathWithoutArguments(UninstallString)
    }
    
    If (!ErrorLevel && UninstallString) {
	RunWait %UninstallString% %switches%
	If (!ErrorLevel && cleanupDir) {
	    If (cleanupDir=-1)
		RegRead cleanupDir, %key%, InstallLocation
	    If (FileExist(cleanupDir))
		FileRemoveDir %cleanupDir%
	}
    }
}

StartsWith(longtext, shorttext) {
    return SubStr(longtext, 1, StrLen(shorttext)) == shorttext
}

GetExecutablePathWithoutArguments(CommandLine) {
    inQuote := 0
    currFragmentEnd := 1
    Loop Parse, CommandLine, %A_Space%%A_Tab%
    {
	If (!inQuote) {
	    currArgStart := currFragmentEnd
	    argNo++
	}
	currFragmentEnd += StrLen(A_LoopField)+1
	
	outerLoopField := A_LoopField
	Loop Parse, A_LoopField, "
	{
	    If (A_Index-1) ; for «"string"», first loop field is empty. If string is at EOL, last too.
		inQuote := !inQuote
	}

	If (inQuote) { ; this substring is part of quote (starting at currArgStart)
	    continue
	}
	; Else := If(!inQuote) { ; quote is just over or not started
	currArg := Trim(SubStr(CommandLine, currArgStart, currFragmentEnd - currArgStart))
	return currArg ; only first argument needed, it must be the program
    }
    
    return SubStr(CommandLine, skipChars)
}
