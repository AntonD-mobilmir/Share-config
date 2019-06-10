;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

Loop %0%
{
    outFName := %A_Index%
    SplitPath outFName, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    out := FileOpen(OutNameNoExt ".pure." OutExtension, "w", "UTF-16")
    keepSection := 1
    Loop Read, %1%
    {
	If (RegExMatch(A_LoopReadLine, "S)^\[(?P<sectName>.+)\]$", m)) ; Section start
	    keepSection := IsSectionKept(msectName)
	
	If (keepSection)
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
    static skipSectionsR := { "A)\d+x\d+ \(\d+x\d+\)": "" }
    
    If (skipSectionsF.HasKey(name))
        return false
    For regex in skipSectionsR {
        If (name ~= regex)
            return false
    }
    return true
}
