;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-16

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

usersList = \\Srv1S-B.office0.mobilmir\Users\Public\Shares\Документы\IT\Справочники\Srv0-users-list.txt

Loop
{
    rowCount:=0
    usersData := {}
    currentBlock := {}
    Loop Read, %usersList%
    {
        If (line := Trim(A_LoopReadLine)) {
            sep := InStr(line, "=")
            currentBlock[SubStr(line, 1, sep-1)] := SubStr(line, sep+1)
        } Else If (currentBlock.HasKey("Name")) {
            Name := currentBlock.Name
            While (usersData.HasKey(Name))
                Name := currentBlock.Name " (" A_Index ")"
            usersData[Name] := currentBlock.Clone()
            currentBlock := {}
            rowCount++
        }
    }

    If (rowCount)
        break
    MsgBox 0x15, Выбор пользователя из списка, Список пользователей не прочитался из файла "%usersList%". Либо сервер недоступен`, либо у Вас нет доступа к файлу.
    IfMsgBox Cancel
        ExitApp 1
}

Gui Add, Edit, vFilterText gEditEvent
Gui Add, Button, ym Default, OK
Gui Add, ListView, Section xm gListEvent -WantF2 -Multi Sort Count %rowCount%, Login|Полное имя

Gui Show

Exit

LV_Filter(flt := "") {
    global usersData
    LV_Delete()
    For name, userData in usersData {
        If (!flt || InStr(name, flt) || InStr(userData.FullName, flt))
            LV_Add("Select", name, userData.FullName)
    }
}

ListEvent:
    ;built-in variables A_Gui and A_GuiControl tell which window and ListView
    ;A_GuiEvent:
    ;   DoubleClick: The user has double-clicked within the control. The variable A_EventInfo contains the focused row number. LV_GetNext() can be used to instead get the first selected row number, which is 0 if the user double-clicked on empty space.
    If (A_GuiEvent!="DoubleClick")
        Exit
    LV_GetText(name, A_EventInfo)
    If (!name)
        Exit
ButtonOK:
    Gui Submit
    LV_GetText(name, LV_GetNext())
    If (userData := usersData[name]) {
        FileAppend % userData.Name "`t" userData.FullName "`t" userData.Description, *, CP1
        ExitApp 0
    }
ExitApp 1

EditEvent:
    Gui Submit, NoHide
    LV_Filter(FilterText)
Exit


GuiClose:
GuiEscape:
    ExitApp
