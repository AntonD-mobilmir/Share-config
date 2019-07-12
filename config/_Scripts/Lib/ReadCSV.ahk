;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ReadTSV(ByRef tsvpath, ByRef reqHeaders := "") {
    return ReadCSV(tsvpath, reqHeaders, A_Tab)
}

ReadCSV(ByRef csvpath, ByRef reqHeaders := "", separator:="CSV") {
    ;modes for reqHeaders:
    ; "" – output is array containing objects, each object is a row with corresponding titles from tsv as key names
    ; 		[{title_of_some_col: value, title_of_other_col: value, …}, {title_of_some_col: value_from_row2, title_of_other_col: value_from_row_2, …}, …]
    ; 		reqHeaders will be re-assigned to array of column titles
    ; 0 – output is array containing arrays, each inner array is a row tsv, key names are column numbers from tsv
    ; 		reqHeaders will be re-assigned to array of column titles
    ; "string" – only single column (titled "string") read from tsv, output is array of values
    ; integer – only single column (nr. integer) read from tsv, output is array of values
    ;
    ; ["requested column 1 title", "requested column 2 title", …] – output is array of arrays, each inner array is a row with data from columns requested in reqHeaders
    ; [outputKey1Name: "requested column 1 title", outputKey2Name: "requested column 2 title", …] – output is array of objects, each inner object is a row with data from columns requested in reqHeaders
    ;		key names in inner array of output = key names of columns in reqHeaders (no matter in which order it's in the file)
    ;		[[reqHeaderscol1row1data, reqHeaderscol2row1data, …], [reqHeaderscol1row2data, reqHeaderscol2row2data, …], …]
    ; 			or, if reqHeaders is non-array object,
    ;		[{reqHeadersKey1: row1datafor_column_named_reqHeadersVal1, reqHeadersKey2: row1datafor_column_named_reqHeadersVal2, …}
    ;		,{reqHeadersKey1: row2datafor_column_named_reqHeadersVal1, reqHeadersKey2: row2datafor_column_named_reqHeadersVal2, …}
    ;		, …]
    objTSV := []
    singleColumn := ""
    Loop Read, %csvpath%
    {
	If (A_Index == 1) { ; column titles
	    tsvHdrs := []
	    Loop Parse, A_LoopReadLine, %separator%
		tsvHdrs[A_Index] := A_LoopField
	    If (IsObject(reqHeaders)) {
		hdrColNums := {}
		For i, header in reqHeaders
		    hdrColNums[header] := i
		For i, header in tsvHdrs.Clone()
		    If (hdrColNums.HasKey(header))
			tsvHdrs[i] := hdrColNums[header]
		    Else
			tsvHdrs.Delete(i)
	    } Else If (reqHeaders==0) { ; all file, with key names as col numbers (==0)
		reqHeaders := tsvHdrs ; copy headers to output
		For i in tsvHdrs
		    tsvHdrs[i] := i ; redefine key names to column numbers for output
	    } Else If (reqHeaders=="") { ; all file, with key names as column titles (=="")
		reqHeaders := tsvHdrs ; copy headers to output
	    } Else If headers is integer
	    {
		singleColumn := headers
	    } Else { ; single column titled reqHeaders
		singleColumn := ""
		For i,title in tsvHdrs
		    If (title == reqHeaders) {
			singleColumn := i
			break
		    }
		If (singleColumn == "")
		    Throw Exception("Запрошенный столбец не найден в файле",, "Столбец """ reqHeaders """, файл """ csvpath """")
	    }
	} Else {
	    If (singleColumn) {
		currLine := ""
		Loop Parse, A_LoopReadLine, %separator%
		    If (A_Index == singleColumn) {
			If (A_LoopField)
			    currLine := A_LoopField
			break
		    }
	    } Else {
		currLine := {}
		If (hdrColNums) { ; filter is on
		    Loop Parse, A_LoopReadLine, %separator%
			If (tsvHdrs.HasKey(A_Index) && A_LoopField)
			    currLine[tsvHdrs[A_Index]] := A_LoopField
		} Else {
		    Loop Parse, A_LoopReadLine, %separator%
			If (A_LoopField)
			    currLine[tsvHdrs[A_Index]] := A_LoopField
		}
	    }
	    objTSV[A_Index-1] := currLine
	}
    }
    return (objTSV)
}
