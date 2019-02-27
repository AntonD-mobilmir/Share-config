;Remove old files
;                                             by logicdaemon@gmail.com
;                                                       logicdaemon.ru
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
;CC BY-SA 4.0 <http://creativecommons.org/licenses/by-sa/4.0/>
#NoEnv

If cleanfn := IsFunc("CleanupDir") ? Func("CleanupDir") : Func("CleanupDirSimple")

For i, path in A_Args
    cleanfn.Call(path)

CleanupDirSimple(ByRef path) {
    CreationTimeHorinzon =
    CreationTimeHorinzon += -31, Days
    
    If (!path)
        Throw Exception("path is empty")
    Loop Files, %path%\*.*, R ; All files
        If ( A_LoopFileTimeCreated < CreationTimeHorinzon )
            FileDelete %A_LoopFileFullPath%
}

#include *i %A_AppDataCommon%\mobilmir.ru\Common_Scripts\del_old_tempfiles.ahk
