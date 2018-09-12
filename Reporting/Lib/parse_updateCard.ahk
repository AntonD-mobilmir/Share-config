;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv

parse_updateCard(data, ByRef out := "") {
    global cardMembers
    changeList := "", listName := data.list.name
    For field, value in data.old
	If field in desc,due,pos,name,idLabels,idAttachmentCover,idMembers
	    continue
	Else If (field == "dueComplete")
            changeList .= (value ? "☐" : "☑") . " в поле ""срок"", " ; value – это старое значение, а не новое
        Else If (field == "closed")
            changeList .= (value ? "раз" : "за") "архивирована, "
	Else If (field == "idList") {
            newListName := data.listAfter.name
            If newListName in Готово,Выполнено,Завершено
		changeList .= "перемещена в список " data.listAfter.name ", "
            If (!listName) ; при изменении списка, в data.list.name пусто
                listName := data.listAfter.name
	} Else
	    return "Изменено поле """ field """, обработка для него не прописана. Всё действие: " JSON.Dump(data)
    If (changeList) {
        If (IsByRef(out)) {
            GetCommonFieldsFromTrelloUpdate(data, out)
            out.list   := listName
            out.status := SubStr(changeList, 1, -2))
        }
        return SubStr(changeList, 1, -2)
    }
}

#include %A_LineFile%\..\GetCommonFieldsFromTrelloUpdate.ahk
