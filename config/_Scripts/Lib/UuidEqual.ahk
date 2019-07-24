;by jNizM
;https://www.autohotkey.com/boards/viewtopic.php?t=4732
;https://www.autohotkey.com/boards/viewtopic.php?p=27150&sid=f729e611c153d70ecd8a942d7c926437#p27150
UuidEqual(uuid1, uuid2)
{
    return DllCall("rpcrt4.dll\UuidEqual", "ptr", &uuid1, "ptr", &uuid2, "ptr", &RPC_S_OK)
}
