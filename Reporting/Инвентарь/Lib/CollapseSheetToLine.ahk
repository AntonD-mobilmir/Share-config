CollapseSheetToLine(srcObj, keyMin := "", sep := " ") {
    out := {}
    For i, subObj in srcObj
        If (i>=keyMin)
            For j, field in subObj
                out[j] .= ( out[j] ? sep : "" ) . field
    return out
}
