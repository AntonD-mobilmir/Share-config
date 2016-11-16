;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance off
SetFormat IntegerFast, D

OnExit("ExitFunc")

global mainTitle := "Отправка сканов договоров в КРО"
     , settingsRegPath := "HKEY_CURRENT_USER\Software\mobilmir.ru\Rarus-Scripts\%A_ScriptName%"
     , outMailDir := A_ScriptDir . "\..\post\OutgoingText"
     , MailUserId, replyTo

; Create an ImageList so that the ListView can display some icons:
laNum = %1%
If (laNum)
    laNumState = ReadOnly

Gui Add, Text, xm section, № договора
Gui Add, Edit, ys x100 W300 vlaNum %laNumState%, %laNum%
Gui Add, Text, xm section, Вложения
Gui Add, ListView, ys x100 W300 AltSubmit vFilesListView gFilesList, Имя файла| |Размер (КБ)
LV_ModifyCol(1, 200)
LV_ModifyCol(1, "Logical")
LV_ModifyCol(2, 0)
LV_ModifyCol(2, "NoSort")
LV_ModifyCol(3, 79)
LV_ModifyCol(3, "Integer")

Gui Add, Button, x100 section vListViewAdd gSelectAddFiles, &Добавить отсканированный договор
Gui Add, Button, ys vListViewDel gDelItems, &Удалить
Gui Add, Button, x375 section Default vOKbtn, &OK
Gui Add, Text, xm section, Файлы можно перетаскивать на окно или добавлять кнопкой

Menu MenuSwitchView, Add, Таблица, ContextSwitchViewReport
Menu MenuSwitchView, Add, Список, ContextSwitchViewList

Menu ListViewContextMenu, Add, Открыть, ContextOpenFile
Menu ListViewContextMenu, Default, Открыть ; Make "Open" a bold font to indicate that double-click does the same thing.
Menu ListViewContextMenu, Add
Menu ListViewContextMenu, Add, Вид, :MenuSwitchView
Menu ListViewContextMenu, Add
Menu ListViewContextMenu, Add, Свойства, ContextProperties
Menu ListViewContextMenu, Add, Удалить, ContextDeleteRows

GuiControl Focus, ListViewAdd

Gui Show,, %mainTitle%

;SelectAddFiles()

Try MailUserId := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_SharedMailUserId.cmd", "MailUserId")
If (MailUserId) {
    replyTo := MailUserId . "@mobilmir.ru"
} Else {
    replyTo := "it-task-office@status.mobilmir.ru"
    FileReadLine MailUserId, %A_ScriptDir%\..\post\sendemail.cfg, 1
}

Exit

GuiEscape:
GuiClose:
ButtonCancel:
    If (!sent) {
	MsgBox 0x24, %mainTitle%, Договор ещё не отравлен. Отменить отправку?
	IfMsgBox No
	    return
    }
ExitApp 1

GuiSubmit:
ButtonOK:
    GuiControlGet FocusedControl, FocusV
    If (FocusedControl == "FilesListView") { ; Default button, activates when Enter pressed
	GoTo ContextOpenFile
	return
    } Else {
	Gui Submit ;,NoHide
	If (sendError := SendEmail()) {
	    Gui Show
	} Else {
	    ExitApp 0
	}
    }
FilesList:	  ; Arbitrary event in list
    ;DoubleClick: The user has double-clicked within the control. The variable A_EventInfo contains the focused row number. LV_GetNext() can be used to instead get the first selected row number, which is 0 if the user double-clicked on empty space.

    ;R: The user has double-right-clicked within the control. The variable A_EventInfo contains the focused row number.

    ;ColClick: The user has clicked a column header. The variable A_EventInfo contains the column number, which is the original number assigned when the column was created; that is, it does not reflect any dragging and dropping of columns done by the user. One possible response to a column click is to sort by a hidden column (zero width) that contains data in a sort-friendly format (such as a YYYYMMDD integer date). Such a hidden column can mirror some other column that displays the same data in a more friendly format (such as MM/DD/YY). For example, a script could hide column 3 via LV_ModifyCol(3, 0), then disable automatic sorting in the visible column 2 via LV_ModifyCol(2, "NoSort"). Then in response to the ColClick notification for column 2, the script would sort the ListView by the hidden column via LV_ModifyCol(3, "Sort").

    ;D: The user has attempted to start dragging a row or icon (there is currently no built-in support for dragging rows or icons). The variable A_EventInfo contains the focused row number. In v1.0.44+, this notification occurs even without AltSubmit.

    ;d (lowercase D): Same as above except a right-click-drag rather than a left-drag.

    ;e (lowercase E): The user has finished editing the first field of a row (the user may edit it only when the ListView has -ReadOnly in its options). The variable A_EventInfo contains the row number.
    If (A_GuiEvent = "DoubleClick") {
	If (A_EventInfo) {
	    OpenFile(A_EventInfo)
	} Else {
	    SelectAddFiles()
	}
    } Else If (A_GuiEvent = "K") { ; K: The user has pressed a key while the ListView has focus. A_EventInfo contains the virtual key code of the key, which is a number between 1 and 255. This can be translated to a key name or character via GetKeyName. For example, key := GetKeyName(Format("vk{:x}", A_EventInfo)). On most keyboard layouts, keys A-Z can be translated to the corresponding character via Chr(A_EventInfo). F2 keystrokes are received regardless of WantF2. However, the Enter keystroke is not received; to receive it, use a default button as described below.
	If (A_EventInfo == 0x2D) { ; Ins
	    SelectAddFiles()
	} Else If (A_EventInfo == 0x2E) { ; Del
	    DelItems()
	} Else If (A_EventInfo == 0x0D && GetKeyState("Alt") && !GetKeyState("Ctrl") ) { ; Enter. Only possible is Enter with modifier, otherwise it launches default button
	    GoTo ContextProperties
	}
    }
return

GuiContextMenu:  ; Launched in response to a right-click or press of the Apps key.
    If (A_GuiControl == "FilesListView") { ; Display the menu only for clicks inside the ListView.
	; Show the menu at the provided coordinates, A_GuiX and A_GuiY.  These should be used
	; because they provide correct coordinates even if the user pressed the Apps key:
	Menu ListViewContextMenu, Show, %A_GuiX%, %A_GuiY%
    }
return

ContextSwitchViewReport:
    GuiControl, +Report, FilesListView  ; Switch to details view.
return

ContextSwitchViewList:
    GuiControl, +Icon, FilesListView    ; Switch to icon view.
return

ContextOpenFile:  ; The user selected "Open" in the context menu.
    curRow := LV_GetNext(0)
    If (!curRow)
	curRow := LV_GetNext(0, "F")
    Loop
    {
	OpenFile(curRow)
    } Until !(curRow := LV_GetNext(curRow))
return

ContextProperties:  ; The user selected "Properties" in the context menu.
    curRow := LV_GetNext(0)
    If (!curRow)
	curRow := LV_GetNext(0, "F")
    Loop
    {
	LV_GetText(fullPath, curRow, 2)  ; Get the text of the second field.
	Run properties "%fullPath%",, UseErrorLevel
	If (ErrorLevel)
	    MsgBox Не удалось открыть свойства "%fullPath%".
    } Until !(curRow := LV_GetNext(curRow))
return

ContextDeleteRows:  ; The user selected "Clear" in the context menu.
    DelItems()
return

ExitFunc(ExitReason, ExitCode) {
    If (ExitReason=="Exit")
	ExitApp ExitCode
    ExitApp -1
}

OpenFile(index:=0) {
    If (!index)
	index := LV_GetNext(0, "F")
    LV_GetText(rowText, index, 2)
    Run % """" . rowText . """"
}

SelectAddFiles() {
    static iconArray := {}

    RegRead lastUsedDir, %settingsRegPath%, LastUsedDir
    If (!LastUsedDir) {
	RegRead CommonPictures, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, CommonPictures
	lastUsedDir := Expand(CommonPictures) . "\Сканированное"
    }
    FileSelectFile selectedFiles, M1, %lastUsedDir%, Выберите сканы договора №%laNum%
    ;M: Multi-select, 1: File Must Exist
    If (!selectedFiles)
	return
    
;    prevFormat := A_FormatFloat
;    SetFormat FloatFast, 0.3
    GuiControl -Redraw, FilesListView
    Loop Parse, selectedFiles, `n
    {
	If (A_Index = 1) {
	    lastUsedDir := A_LoopField
	} Else {
	    lastAddedRow := AddFileToList(lastUsedDir . "\" . A_LoopField)
	}
    }
    LV_Modify(lastAddedRow, "Focus Vis")
;    LV_ModifyCol(2, 0)
    GuiControl +Redraw, FilesListView
;    SetFormat FloatFast, %prevFormat%
    
    RegWrite REG_SZ, %settingsRegPath%, lastUsedDir
    GuiControl Focus, FilesListView
}

GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
    For i, path in FileArray {
	lastAddedRow := AddFileToList(path)
    }
}

AddFileToList(path) {
    FileGetSize fileSize, %path%, K
    If (!fileSize) {
	MsgBox 0x30, %mainTitle%, Не удалось определить размер файла %path%`, он не будет добавлен.
	return
    }
    SplitPath path, OutFileName,,OutExtension
    return LV_Add("", OutFileName, path, fileSize)
}

;Expand env vars in string, ignoring %% (double percent sequences)
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

DelItems() {
    curRow := 1  ; This causes the first iteration to start the search at the top.
    While (curRow := LV_GetNext(curRow - 1)) {
	LV_Delete(curRow)
    }
}

SendEmail() {
    global laNum
    
    If (itmc := LV_GetCount()) {
	msgName = loan_scans_%A_Now%
	outMsgPath = %outMailDir%\%msgName%
	filesList := ""
	messageSize := 5 ; 5 kb reserve for mail & headers
	
	Loop %itmc%
	{
	    LV_GetText(path, A_Index, 2)
	    FileGetSize size, %path%, K
	    If (size && !ErrorLevel) {
		filesList .= path . "`n"
		;LV_GetText(size, A_Index, 3)
		messageSize += 4 * (size//3+1) + 1 ; Base64+headers. ~ToDo: account line breaks
	    } Else {
		MsgBox 0x30, %mainTitle%, Не удалось определить размер файла %path%`, или размер равен нулю. Файл не может быть добавлен.
		return 1
	    }
	}
	
	If (messageSize > 8192) {
	    MsgBox 0x40, %mainTitle%, Слишком большой размер письма!`n`nCервер не принимает письма размером больше 8 МБ. Файлы в почте занимают на 1/4 больше`, чем сохранённые на диске`, поэтому рассчитывайте на 5-6 МБ максимум. Обычно этого с большим запасом достаточно`, чтобы отправить сканы кредитных договоров.`nУдалите лишние вложения`, либо сожмите файлы или отсканируйте в меньшем разрешении/с большим сжатием. Если не получится`, обращайтесь в службу ИТ.
	    return 1
	}
	
	FileCreateDir %outMsgPath%
	Loop {
	    errorsMsg:=""
	    atLeastOneCopied:=0
	    TrayTip %mainTitle%, Копирование файлов в папку отправки
	    Loop Parse, filesList, `n
	    {
		If (!A_LoopField)
		    continue
		If (!FileExist(A_LoopField)) {
		    errorsMsg .= "`n""" . A_LoopField . """ (файл не найден)"
		    continue
		}
		FileCopy %A_LoopField%, %outMsgPath%\*.*, 1
		If (A_LastError || ErrorLevel)
		    errorsMsg .= "`n""" . A_LoopField . """ (код " . A_LastError . ")"
		Else
		    atLeastOneCopied := 1
	    }
	    If (!atLeastOneCopied) {
		MsgBox 0x40, %mainTitle%, Ни один файл не скопирован.`n`nПри копировании произошли следующие ошибки:%errorsMsg%
		return 1
	    }
	    If (errorsMsg) {
		MsgBox 0x36, %mainTitle%, Следующие файлы не скопированы:%errorsMsg%`n`nЕсли продолжить без них`, они не будут отправлены.
		IfMsgBox Cancel
		    return 1
		IfMsgBox TryAgain
		    continue
	    }
	    TrayTip
	    break
	}
	FileAppend,
	(LTrim
	    loan-agreements@status.mobilmir.ru
	    Reply-To: %replyTo%
	    %laNum% {сканы договоров отправлены скриптом с компьютера %A_ComputerName% отдела %MailUserId%}
	    Список файлов:
	    %filesList%
	),%outMsgPath%.tmp, UTF-8
	FileMove %outMsgPath%.tmp, %outMsgPath%.txt, 1
	exitOK := 1
	TrayTip %mainTitle%, Сформировано письмо с %itmc% файлами. Будет отправлено через стандатный механизм отправки уведомлений 1С-Рарус.
	Run "%A_AhkPath%" "%outMailDir%\..\DispatchFiles.ahk"
	Sleep 1000
	return 0
    } Else {
	MsgBox 0x40, %mainTitle%, Добавьте сканы договора!
	return 1
    }
}

ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	If (mpos := RegExMatch(A_LoopReadLine, "i)SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", match)) {
	    If (Trim(Trim(matchName), """") = varname) {
		return Trim(Trim(matchValue), """")
	    }
	}
    }
}

Expand(string) {
    PrevPctChr:=0
    LastPctChr:=0
    VarnameJustFound:=0
    output:=""

    While ( LastPctChr:=InStr(string, "%", true, LastPctChr+1) ) {
	If VarnameJustFound
	{
	    EnvGet CurrEnvVar,% SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    output .= CurrEnvVar
	    VarnameJustFound:=0
	} else {
	    output .= SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    If (SubStr(string, LastPctChr+1, 1) == "%") { ;double-percent %% skipped ouside of varname
		output .= "%"
		LastPctChr++
	    } else {
		VarnameJustFound:=1
	    }
	}
	PrevPctChr:=LastPctChr
    }

    If VarnameJustFound ; That's bad, non-closed varname
	Throw Exception("Var name not closed")
	
    output .= SubStr(string,PrevPctChr+1)
    
    return % output
}
