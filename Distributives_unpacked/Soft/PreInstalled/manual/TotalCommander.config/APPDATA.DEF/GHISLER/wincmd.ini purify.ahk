;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

skipKeys :=      { "Configuration": { "AutoUpdateCheckDate": ""
                                    , "AutoUpdateInformedVersion": "" } }

If (A_Args.Length())
    args := A_Args
Else
    args := [A_ScriptDir "\wincmd.ini"]
For i, inipath in args {
    SplitPath inipath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    out := FileOpen((OutDir ? OutDir "\" : "") OutNameNoExt ".pure." OutExtension, "w", "UTF-16")
    keepSection := 1 ; to keep everything before first section
    Loop Read, %inipath%
    {
	If (RegExMatch(A_LoopReadLine, "S)^\[(?P<sectName>.+)\]$", m)) { ; Section start
	    keepSection := IsSectionKept(msectName)
            If (keepSection) ; otherwise whole section is skipped and we do not care about keys
                fitlerKeys := skipKeys[msectName]
        }
	
	If (!keepSection)
            continue
        
        If (!fitlerKeys.HasKey(Trim(SubStr(A_LoopReadLine, 1, InStr(A_LoopReadLine, "=")-1))))
	    out.Write(A_LoopReadLine . "`n")
    }
    out.Close()
}

Exit

StartsWith(s1, s2) {
    return SubStr(s1, 1, StrLen(s2))=s2
}

IsSectionKept(ByRef name) {
    static skipSectionsF := { "NewFileHistory": ""
                            , "RenameSearchReplace": ""
                            , "RenameSearchFind": ""
                            , "RenameTemplates": ""
                            , "Selection": ""
                            , "SearchIn": ""
                            , "SearchName": ""
                            , "MkDirHistory": ""
                            , "Command line history": ""
                            , "SearchText": "" }
                            ;, "1440x900 (8x16)": ""
                            ;, "1280x1024 (8x16)": ""
                            ;, "1920x1080 (8x16)": ""
                            ;, "1920x1200 (8x16)": "" }
         , skipSectionsR := { "A)\d+x\d+ \(\d+x\d+\)": "" }
    
    If (skipSectionsF.HasKey(name))
        return false
    For regex in skipSectionsR {
        If (name ~= regex)
            return false
    }
    return true
}
