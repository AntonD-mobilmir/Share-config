#NoEnv

skipSchedule := 1 ; Для случая, когда в командной строке не будет аргументов
Loop %0%
{
    arg := %A_Index%
    flag := SubStr(arg, 1,1)
    If (flag == "/" || flag == "-") {
	mode .= SubStr(arg,2)
	;%mode%=1
	If (arg="/skipSchedule")
	    skipSchedule:=1
	Else If (arg="/autoupdate")
	    skipSchedule:=autoupdate:=1
	Else If (arg="/install")
	    skipSchedule:=0
	Else
	    Throw Exception("Неправильный аргумент командной строки", arg)
    }
}

ShopBTSDir=d:\1S\Rarus\ShopBTS
PostConfigDir=%ShopBTSdir%\ExtForms\post
exe7z := find7z()

RunWait "%exe7z%" x -aoa -o"%ShopBTSdir%" -- "%A_ScriptDir%\ShopBTS_Add.7z",,Min UseErrorLevel
If (!ErrorLevel) {
    FileGetTime timeArchShopBTSAdd, %A_ScriptDir%\ShopBTS_Add.7z
    FileDelete %PostConfigDir%\ShopBTS_Add_ver.txt
    FileAppend %timeArchShopBTSAdd%, %PostConfigDir%\ShopBTS_Add_ver.txt, UTF-8
    postForm := 1
}
If (!(FileExist("C:\SysUtils\sendemail.exe") || FileExist(ShopBTSdir . "\sendemail.exe"))) {
    Run "%exe7z%" x -aoa -o"%ShopBTSdir%" -- "%A_ScriptDir%\ShopBTS_Add_Utils.7z",,Min UseErrorLevel
}
If (!FileExist(PostConfigDir . "\sendemail.cfg") && FileExist(PostConfigDir . "\blat.cfg") ) {
    FileRead blatcfg, %PostConfigDir%\blat.cfg
    ;blat.cfg: 
    ;-f dt@k.mobilmir.ru -u dt@k.mobilmir.ru -pw KAsb23jkasH37sAs

    Loop Parse, blatcfg, %A_Space%`r,`n
    {
	If (A_LoopField=="")
	    continue
	If nextfield
	{
	    %nextfield%=%A_LoopField%
	    nextfield=
	} Else If (A_LoopField="-f") {
	    nextfield=emailFrom
	} Else If (A_LoopField="-u") {
	    nextfield=userName
	} Else If (A_LoopField="-pw") {
	    nextfield=password
	} Else
	    Throw Exception("Не удалось разобрать blat.cfg", "Значение ключа неизвестно", A_LoopField)
	    ;Формат файла blat.cfg не соответствует ожидаемому, автоматический перенос информации в sendemail.cfg невозможен. Выполните перенос вручную.
    }

    If (!userName && emailFrom)
	userName=%emailFrom%

    If (userName="" || password="")
	Throw Exception("Не удалось разобрать blat.cfg", "В файле blat.cfg не найдена необходимая информация. Запишите в sendemail.cfg вручную.", userName ? "password" : "userName")
    
    FileAppend %userName%`n%password%`n, %PostConfigDir%\sendemail.cfg, CP1251
}

If (!skipSchedule)
    RunWait %comspec% /C %A_ScriptDir%\..\_shedule_rsend_queue.cmd, %A_Temp%, Min UseErrorLevel

bakWorkingDir := A_WorkingDir
SetWorkingDir %PostConfigDir%

FileDelete OutgoingText\loan_scans_Список
If (FileExist("OutgoingText\nobackupwarning")) {
    FileGetTime timeNBW, OutgoingText\nobackupwarning
    ageNBW=
    EnvSub ageNBW, timeNBW, Days
    If (ageNBW>3)
	FileRemoveDir OutgoingText\nobackupwarning, 1
}

Loop Files, OutgoingFiles\*.*, DFR
    RecordOlder(A_LoopFileName, A_LoopFileTimeCreated)
Loop Files, OutgoingText\*.*, DFR
    RecordOlder(A_LoopFileFullPath, A_LoopFileTimeCreated)

ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
FileAppend,
( LTrim
    anton.derbenev@rarus.robots.mobilmir.ru
    Проверка отправки уведомлений из 1С-Рарус с компьютера %A_ComputerName%
    Проверочное сообщение после обновления скриптов отправки.
    Пользователь, от имени которого запущен скрипт: %A_UserName%
    Время: %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%
    Командная строка: %ScriptRunCommand%
), OutgoingText\%A_ScriptName%.%A_Now%.txt, CP1251

SetWorkingDir %bakWorkingDir%

If (postForm) {
    Try deptID := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_SharedMailUserId.cmd", "MailUserId")
    If (!deptID)
	FileReadLine deptID, %PostConfigDir%\sendemail.cfg, 1
    mode :=  ( mode ? mode : "manual" ) . " (" . A_UserName . ")"
    PostGoogleForm("https://docs.google.com/a/mobilmir.ru/forms/d/e/1FAIpQLSeP5T_GDbGh_SZ5gOaxa-WrTKvt2cGuj9DGCHWXnOvGPqV_yg/formResponse"
		    , { "entry.615879702":	A_ComputerName
		      , "entry.67493091":	deptID
		      , "entry.1314177838":	mode
		      , "entry.1721746842":	timeArchShopBTSAdd
		      , "entry.625970379":	RecordOlder() } )
}

ExitApp

RecordOlder(name:="",date:="") {
    static nameOldest, dateOldest
    
    If (name) {
	If (!dateOldest || dateOldest > date) {
	    nameOldest:=name
	    dateOldest:=date
	    return 1
	}
	return 0
    } Else {
	If (nameOldest) {
	    age=
	    EnvSub age, dateOldest, days
	    return nameOldest . " (" . age . "дн.)"
	} Else {
	    return
	}
    }
}

find7z() {
    Try return GetPathForFile("7zG.exe", paths*)
    paths := ["c:\Program Files\7-Zip", "c:\Program Files (x86)\7-Zip", "c:\Arc\7-Zip"]
    paths.Push("D:\Distributives\Soft\utils", "W:\Distributives\Soft\utils", "\\localhost\Distributives\Soft\utils")
    Try return GetPathForFile("7za.exe", paths*)
    Try return GetPathForFile("7z.exe", paths*)
}

GetPathForFile(file, paths*) {
    For i,path in paths {
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%file%
	    IfExist %fullpath%
		return fullpath
	}
    }
    
    Throw "Not found " . file
}

#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\PostGoogleForm.ahk
#include \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
