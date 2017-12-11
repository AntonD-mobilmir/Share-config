;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

cmdlSwitches := {"-": "endsw" ; -- or /- to accept all following args as filenames (stop processing further switches)
		,"debug": "debug"
		,"d": "debug"
		,"silent": "silent"
		,"s": "silent"}

tmp = %A_Temp%\%A_ScriptName%-tmpchecksums.txt
Try
    exe7z:=find7zexe()
Catch
    exe7z:=find7zaexe()

argc = %0%
If (argc) {
    Loop %0%
    {
	argv := %A_Index%
	flag := SubStr(argv, 1,1)
	If (!endsw && (flag == "/" || flag == "-")) {
	    cmdlSwitchesValue := SubStr(argv, 2, 2) != "no"
	    cmdlSwitchesName := SubStr(argv, cmdlSwitchesValue ? 2 : 4) ; skip "no" if starts with it
	    If (cmdlSwitches.HasKey(cmdlSwitchesName)) {
		varName := cmdlSwitchesName[cmdlSwitchesName]
		%varName% := cmdlSwitchesValue
	    } Else
		Throw Exception("Неизвестный аргумент",, argv)
	} Else {
	    Loop Files, %argv%
	    {
		oldHashes := Read7zHashOut(A_LoopFileFullPath, oldTitles)
		oldTitleIdx := []
		For i, oldTitle in oldTitles
		    oldTitleIdx[oldTitle] := i
		nameColumn := oldHashes[1].Length()
		For i, oldHash in oldHashes {
		    cd := ""
		    If (FileExist(fname := (cd := A_LoopFileDir) "\" oldHash[nameColumn]) || FileExist(fname := oldHash[nameColumn])) {
			MsgBox fname: %fname%`ncd: %cd%	
			RunWait %comspec% /C ""%exe7z%" h -sccUTF-8 -scrc* -r "%fname%" >"%tmp%"", %cd%
			For i, newHash in Read7zHashOut(tmp, newTitles) {
			    If (!IsObject(colMap)) {
				colMap := []
				For i, title in newTitles
				    If (oldTitleIdx.HasKey(title))
					colMap[i] := oldTitleIdx[title]
				If (!colMap.Length())
				    Throw Exception("Среди хэшей, рассчитываемых 7-Zip, нет хэшей, записанных в файл",, A_LoopFileFullPath "`nСтарые хэши: " ObjectToText(oldTitles) "`nНовые хэши: " ObjectToText(newTitles))
			    }
			    ;MsgBox % ObjectToText(oldTitles) "`n" ObjectToText(oldHash) "`n" ObjectToText(colMap) "`n" ObjectToText(newTitles) "`n" ObjectToText(newHash)
			    For newCol, oldCol in colMap
				If (newHash[newCol] != oldHash[oldCol])
				    Warning(oldTitles[oldCol] " mismatch for """ fname """: old " oldHash[oldCol] ", new " newHash[newCol])
			}
		    } Else
			Warning("File not found: " fname)
		}
	    }
	}
    }
}
ExitApp

Warning(text) {
    global silent
    FileAppend %text%, *, CP1
    If (!silent)
	MsgBox %text%
}

ObjectToText(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}

#include <Read7zHashOut>
