;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding CP1

groups := {}

For i, grp in ReadCSV(A_Args[1], "group") {
    If (groups.HasKey(grp))
        groups[grp]++
    Else
        groups[grp] := 1
}

groupsWith1Member := ""
For grp, c in groups
    If (c==1)
        groupsWith1Member .= grp ","

If (groupsWith1Member) {
    groupsWith1Member := SubStr(groupsWith1Member, 1, -1)
    MsgBox В следующих группах только один (удаляемый) пользователь: %groupsWith1Member%
    Exit 1
}
Exit 0

#include <ReadCSV>
