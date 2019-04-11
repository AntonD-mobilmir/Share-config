;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv

BatchQueryCardMembers(idCard, cardMembers) {
    global flog
    static BatchQueries := 10, countQueries := 0, queryList := {}
    If (idCard && !queryList.HasKey(idCard) && !memberList.HasKey(idCard))
        queryList[idCard] := "", countQueries++
    If (countQueries = BatchQueries || (countQueries && !idCard)) {
        queryStr := "/batch/?urls=", queryOrder := []
        For idCard in queryList
            queryOrder[A_Index] := idCard, queryStr .= "/cards/" idCard "/members,"
        For i, batchResponse in TrelloAPI1("GET", query := SubStr(queryStr, 1, -1), lastResp := {})
            For statusCode, members in batchResponse
                For j, member in members
                    cardMembers[queryOrder[i]] := member.fullName " @" member.username
        flog.WriteLine(query " → " lastresp)
        
        countQueries := 0, queryList := {}
    }
    
    return cardMembers
}
