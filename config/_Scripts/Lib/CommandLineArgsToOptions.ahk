;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

CommandLineArgsToOptions(sw) {
    ; input:
    ; { switch: {name: max nr of parameters}
    ; , switch: max nr of parameters
    ; , "": max nr of switchless arguments}
    ; switch: as is on command line
    ; name: name for option in returned object. If nr of parameters > 1, parameters will be in array
    ; 
    ; output:
    ; {name: param, name: [param1, param2], name: "", "": [array of switchless parameters (or just parameter w/o array if max nr of switchless arguments above = 1)]}
    local swlessLeft, opt, endsw, optnNegated, optnName, argv, flag, leftParams, newSw
    endsw := optnNegated := 0
    optnName := ""
    opt := Object()
    
    If (swlessLeft := sw[""])
	If (swlessLeft!=1)
	    opt[""] := {}
    Loop %0%
    {
	argv := %A_Index%
	flag := SubStr(argv, 1, 1)
	If (!endsw && optnName=="" && (flag == "/" || flag == "-")) {
	    If (swlessLeft && endsw := argv=="--")
		continue
	    If (sw.HasKey(newSw := SubStr(argv, 2)) || (optnNegated := SubStr(argv, 2, 2) = "no") && sw.HasKey(newSw := SubStr(argv, 4))) {
		If (IsObject(sw[newSw])) {
		    For optnName, leftParams in sw[newSw]
			If (A_Index > 1)
			    Throw Exception(A_ThisFunc " does not support multiple variables for single switch",, argv)
		} Else
		    leftParams := sw[optnName := newSw]
		
		If (leftParams==0) {
		    opt[optnName] := !optnNegated
		    optnName=
		} Else If (leftParams!=1)
		    opt[optnName] := Object()
		continue
	    } Else
		Throw Exception("Unknown command line switch",, argv)
	}
	
	If (optnName == "" && !swlessLeft--) {
	    Throw Exception("Excess command line argument",, argv)
	} Else {
	    If (IsObject(opt[optnName]))
		opt[optnName].Push(argv)
	    Else
		opt[optnName] := argv
	    If (!--leftParams)
		optnName=
	}
    }
    
    return opt
}
