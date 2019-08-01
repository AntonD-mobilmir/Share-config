;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

global flog, SystemDrive
EnvGet SystemDrive, SystemDrive

If (!IsObject(flog := FileOpen(logfn := A_Temp . "\" . A_ScriptName . ".log", "w-w"))) {
    Throw Exception(A_LastError, "FileOpen", "При попытке открыть " . logfn)
}

GoodDirs =
(LTrim
$Recycle.Bin
BOOT
Documents and Settings
Intel
PerfLogs
Program Files
Program Files (x86)
ProgramData
Recovery
System Volume Information
SysUtils
Users
Windows

)

GoodFiles =
(LTrim
autoexec.bat
bootmgr
BOOTNXT
config.sys
swapfile.sys
hiberfil.sys
bootTel.dat

)

TrashDirs =
(LTrim
Intel
)

TrashFiles =
(LTrim
UkLog.dat
)

Loop
{
    done:=1
    foundFiles := Object()
    foundDirs := Object()
    showList=

    flog.WriteLine(A_Now . " Запущен поиск мусора на " . SystemDrive)
    Loop Parse, TrashDirs, `n, `r
        If (InStr(FileExist(SystemDrive "\" A_LoopField), "D")) {
            FileSetAttrib -RSH, %SystemDrive%\%A_LoopField%
            FileRemoveDir %SystemDrive%\%A_LoopField%, 1
        }
    Loop Parse, TrashFiles, `n, `r
        If (FileExist(SystemDrive "\" A_LoopField)) {
            FileSetAttrib -RSH, %SystemDrive%\%A_LoopField%
            FileDelete %SystemDrive%\%A_LoopField%
        }
    
    Loop Files, %SystemDrive%\*.*, D
    {
	If (!InStr(GoodDirs, A_LoopFileName . "`n")) {
	    foundDirs.Push(A_LoopFileName)
	    AppendShowList(A_LoopFileName . "\", showList)
	}
    }

    Loop Files, %SystemDrive%\*.*, F
    {
	If (!InStr(GoodFiles, A_LoopFileName . "`n")) {
	    foundFiles.Push(A_LoopFileName)
	    AppendShowList(A_LoopFileName, showList)
	}
    }

    AppendShowList("", showList)

    reqExitCode=127
    If (showList) {
	dest:="D:\ProgramData"
	MsgBox 0x33, %A_ScriptName%, На %SystemDrive% обнаружены папки и файлы`, которых нет в списке стандартных. Переместить их в %dest%? (Да = переместить`, Нет = открыть командную строку):`n%showList%
	IfMsgBox Cancel
	    break
	IfMsgBox No
	{
	    writeoutList=
	    FileAppend %A_Now%`n,%A_Temp%\excessFilesList.txt
	    For i, item in foundDirs
		FileAppend %item%\`n,%A_Temp%\excessFilesList.txt
	    For i, item in foundFiles
		FileAppend %item%`n,%A_Temp%\excessFilesList.txt
	    
	    RunWait %comspec% /K "ECHO Чтобы удалить оставшиеся файлы и папки`, введите EXIT 222. При другом коде возврата будет выполнена повторная проверка.&ECHO Список обнаруженных файлов записан в "`%TEMP`%\excessFilesList.txt"", A_Temp
	    If (ErrorLevel==222) {
		dest:=""
	    } Else {
		done:=0
		continue
	    }
	}
	
	; Перемещение или удаление
	Try {
	    If (dest)
		FileCreateDir %dest%
	    For i, item in foundDirs {
		Try {
		    If (FileExist(fp := SystemDrive . "\" . item)) {
			If (dest)
			    FileMoveDir %fp%, % dest . "\" . item
			Else
			    FileRemoveDir %fp%, 1
		    }
		} Catch e {
		    done := 0
		}
	    }
	    For i, item in foundFiles {
		Try {
		    If (FileExist(fp := SystemDrive . "\" . item)) {
			FileSetAttrib -RSH, %fp%, 1
			If (dest)
			    FileMove %fp%, %dest%
			Else
			    FileDelete %fp%
		    }
		} Catch e {
		    done := 0
		}
	    }
	} catch e {
	    Throw e
	}
    }
} Until done
flow.WriteLine(A_Now . " Завершено.")
flog.Close()
ExitApp

AppendShowList(ByRef item, ByRef lst) {
    static c:=0, item20:=""
    If (lst=="") {
	c:=0
	item20=
    }
    
    If (item) {
	flog.WriteLine(item)
	If (c++ < 20)
	    lst .= "`n" . item
	Else If (c==20)
	    item20 := item
    } Else {
	If (c == 20)
	    lst .= "`n" . item20
	If (c > 20) 
	    lst .= "`n… +" . c-19
    }
}
