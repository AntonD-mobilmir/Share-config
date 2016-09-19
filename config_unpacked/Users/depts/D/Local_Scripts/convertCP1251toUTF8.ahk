#NoEnv

If %0%
{
    CommandLine := DllCall( "GetCommandLine", "Str" )
    param=%1%
    CmdlArgs:= SubStr(CommandLine, InStr(CommandLine,param,1)-1)
    
    ConvertFiles(Trim(CmdlArgs))
}
Else {
    FileSelectFile srcFilesList, M,, Файлы для преобразования, Файлы XML (*.xml)
    Loop Parse, srcFilesList, `n
	If A_Index = 1
	    If A_LoopField
		srcDir=%A_LoopField%\
	Else
	    ConvertFiles(srcDir . A_LoopField)
}
    
Exit

;	Loop %0%
;	{
;	    CurrentFileNamePart:=%A_Index%
;	    FileName .= (FileName?" ":"") . CurrentFileNamePart
	    
;	    MsgBox Checking: %FileName%
;	    IfNotExist %FileName%
;		Continue
	    
;	    ConvertFiles(FileName)
;	    FileName=
;	}

ConvertFiles(srcMask) {
    Cycles=0
    Loop %srcMask%
    {
	Cycles++
	LoopFileDir=
	If A_LoopFileDir
	    LoopFileDir=%A_LoopFileDir%\
	dstName=%LoopFileDir%%A_LoopFileName%.UTF-8.xml
	srcName=%A_LoopFileFullPath%
	
	FileEncoding CP1251
	FileRead srcXML, %srcName%
	
	xml1251header=<?xml version="1.0" encoding="Windows-1251"?>
	If ( SubStr(srcXML,1,StrLen(xml1251header)) != xml1251header ) {
	    MsgBox 308, Проверка исходного файла, Исходный файл не похож на XML в кодировке 1251`, а скрипт разработан для преобразования только таких файлов.`nВсё равно продолжить?`n`n%srcName%
	    IfMsgBox No
		continue
	}

	FileEncoding UTF-8-RAW
	StringReplace srcXML, srcXML, encoding="Windows-1251", encoding="UTF-8"

	IfExist %dstName%
	{
	    If Not ReplaceSilently
	    {
		MsgBox 35, Сохранение обработанного файла, Файл уже существует`, заменить?`n`n%dstName%
		IfMsgBox Cancel
		    Exit

		IfMsgBox No
		    continue

		; IfMsgBox Yes 
		If Not AskedOnce
		{
		    AskedOnce=1
		} Else {
		    AskedOnce=-1
		    MsgBox 36, Сохранение обработанных файлов, Заменять все файлы без дополнительных вопросов?
		    IfMsgBox Yes
			ReplaceSilently=1
		}
	    }

	    FileDelete %dstName%
	}
	FileAppend %srcXML%, %dstName%
    }
    
    If (!Cycles)
	MsgBox По маске "%srcMask%" файлов не найдено.
}
