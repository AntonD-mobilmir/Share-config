;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet SystemDrive, SystemDrive

GoodDirs =
(LTrim
$Recycle.Bin\
BOOT\
Common_Scripts\
Documents and Settings\
Local_Scripts\
PerfLogs\
Program Files (x86)\
Program Files\
ProgramData\
Recovery\
squid\
System Volume Information\
SysUtils\
Users\
Windows\

)

GoodFiles =
(LTrim
autoexec.bat
bootmgr
BOOTNXT
config.sys
swapfile.sys
hiberfil.sys

)

foundFiles := Object()
foundDirs := Object()
showList=

Loop Files, %SystemDrive%\*.*, D
{
    If (!InStr(GoodDirs, A_LoopFileName . "\`n")) {
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

If (showList) {
    dest:="D:\ProgramData"
    MsgBox 0x33, %A_ScriptName%, На %SystemDrive% обнаружены папки и файлы`, которых нет в списке стандартных. Переместить в D:\ProgramData? (Да = переместить`, Нет = удалить):`n%showList%
    IfMsgBox Cancel
	ExitApp
    IfMsgBox No
	dest:=""
    
    Try {
	If (dest)
	    FileCreateDir %dest%
	For i, item in foundDirs {
	    If (dest)
		FileMoveDir %SystemDrive%\%item%, % dest . "\" . item
	    Else
		FileRemoveDir %SystemDrive%\%item%, 1
	}
	For i, item in foundFiles {
	    FileSetAttrib -RSH, %SystemDrive%\%item%, 1
	    If (dest)
		FileMove %SystemDrive%\%item%, %dest%
	    Else
		FileDelete %SystemDrive%\%item%
	}
    } catch e {
	Throw e
    }
}

AppendShowList(ByRef item, ByRef lst) {
    static c:=0, item20
    If (item) {
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
