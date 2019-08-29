;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

CommandLineArgs_to_FindTrelloCardQuery(ByRef options := "", query := "", ByRef othersw := "") {
    If (!IsObject(query))
	query := Object()
    
    args := ParseScriptCommandLine("""")
    Loop % args[""]
    {
	argv := args[A_Index]
	If (option) {
	    options[option] := argv
	    option=
	} Else If (parmName) {
	    parmValue := argv
	} Else {
	    If (SubStr(argv, 1, 1) == "/") {
		option := SubStr(argv, 2)
		continue
	    } Else {
		If (!colon := InStr(argv, ":")) {
                    If (IsByRef(othersw)) {
                        If(IsObject(othersw))
                            othersw[A_Index] := argv
                        Else
                            othersw .= argv " "
                    } Else
                        Throw Exception("Param name should end with a colon", A_LineFile ": " A_ThisFunc, argv)
                } Else {
                    parmName := Trim(SubStr(argv, 1, colon-1))
                    parmValue := Trim(SubStr(argv, colon+1)) ; if "", this arg is just a param name, next arg is parm value
                }
	    }
	}
	If (parmValue) { 
	    If (query.HasKey(parmName)) {
		If (!IsObject(query[parmName]))
		    query[parmName] := {query[parmName]: parmName "0"}
		query[parmName][parmValue] := parmName A_Index
	    } Else
		query[parmName] := parmValue
	    parmName=
	}
    }
    return query
}

#include %A_LineFile%\..\ParseScriptCommandLine.ahk
