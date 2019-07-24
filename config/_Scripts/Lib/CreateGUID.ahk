;by jNizM
;https://www.autohotkey.com/boards/viewtopic.php?t=4732
;https://www.autohotkey.com/boards/viewtopic.php?p=27140&sid=f729e611c153d70ecd8a942d7c926437#p27140
CreateGUID()
{
    VarSetCapacity(pguid, 16, 0)
    if !(DllCall("ole32.dll\CoCreateGuid", "ptr", &pguid)) {
        size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
        if (DllCall("ole32.dll\StringFromGUID2", "ptr", &pguid, "ptr", &sguid, "int", size))
            return StrGet(&sguid)
    }
    return ""
}
