;by jNizM
;https://www.autohotkey.com/boards/viewtopic.php?t=4732
;https://www.autohotkey.com/boards/viewtopic.php?p=27140&sid=f729e611c153d70ecd8a942d7c926437#p27140
IsEqualGUID(guid1, guid2)
{
    return DllCall("ole32\IsEqualGUID", "ptr", &guid1, "ptr", &guid2)
}
