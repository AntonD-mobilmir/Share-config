ArrayJoin(obj, sep := " ", keyMin := 1) {
    out := ""
    For i, v in obj
        If (i >= keyMin)
            out .= v . sep
    return SubStr(out, 1, -StrLen(sep))
}
