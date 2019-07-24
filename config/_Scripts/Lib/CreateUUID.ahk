;by jNizM
;source: https://www.autohotkey.com/boards/viewtopic.php?t=4732
;https://www.autohotkey.com/boards/viewtopic.php?p=27150&sid=f729e611c153d70ecd8a942d7c926437#p27150
CreateUUID()
{
    VarSetCapacity(puuid, 16, 0)
    if !(DllCall("rpcrt4.dll\UuidCreate", "ptr", &puuid))
        if !(DllCall("rpcrt4.dll\UuidToString", "ptr", &puuid, "uint*", suuid))
            return StrGet(suuid), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
    return ""
}
