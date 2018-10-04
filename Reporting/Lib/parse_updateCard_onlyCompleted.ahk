;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv

parse_updateCard_onlyCompleted(data, ByRef update := "") {
    global cardMembers
    changeList := ""
    For field, value in data.old {
	If field in desc,due,pos,name,idLabels,idAttachmentCover,idMembers
	{
	    continue
	} Else If (field == "dueComplete") {
            changeList .= (value ? "☐" : "☑") . " в поле «срок», " ; value – это старое значение, а не новое
        } Else If (field == "closed") {
            changeList .= (value ? "раз" : "за") "архивирована, "
	} Else If (field == "idList") {
            newListName := data.listAfter.name
            If newListName in Готово,Выполнено,Завершено
                changeList .= newListName ", "
            If (IsObject(update)) ; при изменении списка, в data.list.name пусто
                update.list :=  data.listBefore.name
	} Else {
	    changeList .= "изменено поле """ field """, обработка для него не прописана, "
        }
    }
    
    ;MsgBox % "Список изменений: " changeList "`nИсходные данные: " ObjectToText(data)
    If (changeList) {
        If (IsObject(update)) {
            update.status := SubStr(changeList, 1, -2)
            return update
        } Else {
            return SubStr(changeList, 1, -2)
        }
    }
}
