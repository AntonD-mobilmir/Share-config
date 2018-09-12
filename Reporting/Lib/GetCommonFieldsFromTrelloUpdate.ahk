GetCommonFieldsFromTrelloUpdate(data, ByRef out := "") {
    global cardMembers
    If (!IsObject(out))
        out := {}
    out.board :=   data.board.name
    out.list :=    data.list.name
    out.card :=    data.card.name
    out.members := cardMembers[data.card.id]

    return out
}
