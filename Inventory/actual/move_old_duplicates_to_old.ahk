#NoEnv

ext = .7z
extLen := StrLen(ext)

SetWorkingDir %A_ScriptDir%
oldDest = ..\old\

files := Object()

Try {
    RotateLogs(A_ScriptFullPath "-errors.log", A_ScriptFullPath ".log")
    Loop Files, *%ext%, R
    {
	hostname := SubStr(A_LoopFileName, 1, InStr(A_LoopFileName, " ")-1)
	If (!IsObject(files[hostname])) {
	    files[hostname] := props := {Dirs: Object(), c: 1}
	} Else {
	    props := files[hostname]
	    props.c++
	}
	props.Dirs[A_LoopFileDir] := -1
	If (props.latest < A_LoopFileTimeModified)
	    props.latest := A_LoopFileTimeModified
    }

    lstRmv := {}

    For hostname,props in files
	If (props.c==1)
	    lstRmv[hostname] := 1
    For hostname in lstRmv
	files.Delete(hostname)
    c:=0
    For hostname in files
	c++
    If (c) {
	Log(ObjectToText(files))
    } Else {
	Log("No duplicate hostnames found")
	ExitApp
    }

    For hostname,props in files {
	;MsgBox % hostname ": " ObjectToText(props)
	For dir in props.Dirs {
	    Loop Files, %dir%\%hostname%*%ext%
	    {
		If (A_LoopFileTimeModified < props.latest) {
		    Try {
			If (!InStr(FileExist(curDst := oldDest . dir), "D"))
			    FileCreateDir %curDst%
			FileMove %A_LoopFileFullPath%, %oldDest%%A_LoopFileFullPath%
			If (FileExist(txtPath := SubStr(A_LoopFileFullPath, 1, -extLen) ".txt"))
			    FileMove %txtPath%, %oldDest%%txtPath%
		    } Catch e {
			If (!IsObject(e))
			    e := Exception(e)
			Log("Error " ObjectToText(e) ", current file: " A_LoopFileFullPath ", current hostname: " hostname ", props: " props, 1)
		    }
		}
	    }
	}
    }
} Catch e {	
    Log(ObjectToText(e), 1)
    ExitApp 1
}
ExitApp

Log(text, err:=0) {
    fileText := A_Now "`t" (err ? "!" err "`t" : "") text "`n"
    Try FileAppend %fileText%, *, CP1
    Try FileAppend %fileText%, %A_ScriptFullPath%.log
    If (err)
	FileAppend %fileText%, %A_ScriptFullPath%-errors.log
}

ObjectToText(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}

RotateLogs(paths*) {
    For i,path in paths {
	Try FileGetSize size, %path%, M
	If (size > 1)
	    FileMove %path%, %path%.bak, 1
    }
}
