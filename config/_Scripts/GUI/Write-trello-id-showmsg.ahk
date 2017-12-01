;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

pathTrelloID=%A_AppDataCommon%\mobilmir.ru\trello-id.txt

argc = %0%
If (argc) {
    errtxt=
    Loop argc
	errtxt .= %A_Index% " "
    MsgBox Проблема при записи карточки Trello!`n%errtxt%`n`nФайл "%pathTrelloID%" не записан.`nИсправьте карточку`, обновите дамп Inventory\collector-script\trello-accounting-board-dump (или дождитесь автоматического обновления) и запустите "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Write-trello-id.ahk"
} Else {
    Run "%pathTrelloID%"
    MsgBox Записан файл "%pathTrelloID%". Проверьте его содержимое!
}
