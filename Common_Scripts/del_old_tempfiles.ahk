;Remove old files from %TEMP%
;                                             by logicdaemon@gmail.com
;                                                       logicdaemon.ru
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

CleanupDir(A_Temp)

dirDownloads := GetKnownFolderByGUID("{374DE290-123F-4565-9164-39C4925E467B}")
rmvSubdir := "Старые файлы, скоро будут автоматически удалены"
exclDownloads := {"desktop.ini": "", "": "R"}

CleanupDir(dirDownloads "\" rmvSubdir, 93, 93,, exclDownloads)
CleanupDir(dirDownloads, 31, 31, dirDownloads "\" rmvSubdir, exclDownloads)

ExitApp

CleanupDir(dir, CreationAge := 31, ModificationAge := 7, moveDest := "", exclusions := "") {
    CreationTimeHorinzon =
    CreationTimeHorinzon += -CreationAge, Days
    ModificationTimeHorinzon =
    ModificationTimeHorinzon += -ModificationAge, Days
    
    Loop Files, %dir%\*, FR ; All files first
    {
        If (moveDest && SubStr(A_LoopFileFullPath, 1, StrLen(moveDest) + 1) = moveDest "\")
            continue
        If (exclusions && (exclusions.HasKey(exclKey := A_LoopFileName) || exclusions.HasKey(exclKey := ""))) {
            attr := exclusions[exclKey]
            attrMatch := 1
            Loop Parse, attr
                If (!InStr(A_LoopFileAttrib, attr)) {
                    attrMatch := 0
                    break
                }
            If (attrMatch)
                continue
        }
        If ( A_LoopFileTimeModified < ModificationTimeHorinzon && A_LoopFileTimeCreated < CreationTimeHorinzon) 
            If (moveDest) {
                baseDestPath := destPath := moveDest SubStr(A_LoopFileFullPath, StrLen(dir) + 1)
                SplitPath destPath,, outDir, outExtension, outNameNoExt
                outExtension := outExtension ? ("." outExtension) : ""
                While (FileExist(destPath))
                    destPath := outDir "\" outNameNoExt " (" A_Index ")" outExtension
                FileCreateDir %outDir%
                FileMove %A_LoopFileLongPath%, %destPath%
            } Else {
                If A_LoopFileAttrib contains R,H,S
                    FileSetAttrib -RHS ; if file omitted, the current file of the innermost enclosing File-Loop will be used instead
                FileDelete %A_LoopFileFullPath%
            }
    }
    CheckIfEmptyThenRemove(dir)
}

CheckIfEmptyThenRemove(dir) {
    Loop Files, %dir%\*.*, D
        CheckIfEmptyThenRemove(A_LoopFileFullPath)

    Loop Files, %dir%\*.*, DF
        return ; At lest one file or subdir found, don't remove this dir, cont with next
    FileRemoveDir %dir%
}

GetKnownFolderByGUID(ByRef folderGUID) { ;http://www.autohotkey.com/forum/viewtopic.php?t=68194 
    VarSetCapacity(mypath,(A_IsUnicode ? 2 : 1)*1025) 
    
    SetGUID(rfid, folderGUID)
    r := DllCall("Shell32\SHGetKnownFolderPath", "UInt", &rfid, "UInt", 0, "UInt", 0, "UIntP", mypath)
    return (r or ErrorLevel) ? 0 : StrGet(mypath,,"UTF-16") 
} 

SetGUID(ByRef GUID, String) { 
    VarSetCapacity(GUID, 16, 0) 
    StringReplace,String,String,-,,All 
    NumPut("0x" . SubStr(String, 2,  8), GUID, 0,  "UInt")   ; DWORD Data1 
    NumPut("0x" . SubStr(String, 10, 4), GUID, 4,  "UShort") ; WORD  Data2 
    NumPut("0x" . SubStr(String, 14, 4), GUID, 6,  "UShort") ; WORD  Data3 
    Loop, 8 
	NumPut("0x" . SubStr(String, 16+(A_Index*2), 2), GUID, 7+A_Index,  "UChar")  ; BYTE  Data4[A_Index] 
} 
