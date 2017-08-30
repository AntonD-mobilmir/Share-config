;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IniReadUnicode(Filename, IniSection, Key){
    SectionFound=0
    
    IfNotExist %Filename%
	Throw Exception("File not exist", 0, Filename)
    Loop Read, %Filename%
    {
	If SectionFound {
	    If (RegExMatch(A_LoopReadLine,"^\[.+\]$")) { ; Next section begin
		Break
	    } Else {
		NameValueSplitPos:=InStr(A_LoopReadLine, "=")
		If ( Trim(SubStr(A_LoopReadLine, 1, NameValueSplitPos-1)) = Trim(Key) )
		    return SubStr(A_LoopReadLine, NameValueSplitPos+1)
	    }
	} Else {
	    If A_LoopReadLine = [%IniSection%]
		SectionFound=1
	}
    }

    If SectionFound
        Throw Exception("Corresponding key not found inside section", 0, Key)
    Else
	Throw Exception("section not found", -1, IniSection)
}

IniReadSectionUnicode(Filename, IniSection){
    SectionFound=0
    
    IfNotExist %Filename%
	Throw Exception("File not exist", 0, Filename)
    Loop Read, %Filename%
    {
	OutputLine := A_LoopReadLine

	If SectionFound {
	    If (RegExMatch(A_LoopReadLine,"^\[.+\]$")) ; Next section begin
		break
	    Else ; Not a section header, section contents
		SectionContents .= A_LoopReadLine . "`n"
	} Else {
	    If A_LoopReadLine = [%IniSection%]
		SectionFound=1
	}
    }
    
    If (!SectionContents)
	Throw Exception("section not found", -1, IniSection)

    return SectionContents
}

IniWriteUnicode(Filename, IniSection, Key, Value){
    Return IniModifyUnicode(Filename, IniSection, Key, Value)
}

;IniWriteSectionUnicode(Filename, IniSection, SectionContents){
;}

IniDeleteKeyUnicode(Filename, IniSection, Key){
    Return IniModifyUnicode(Filename, IniSection, Key,, 1)
}

IniDeleteSectionUnicode(Filename, IniSection){
    Return IniModifyUnicode(Filename, IniSection,,, 1)
}

;IniEnumSectionsUnicode(Filename){
;}

;IniEnumKeysUnicode(Filename, IniSection){
;}

IniModifyUnicode(Filename, IniSection, Key="", Value="", Remove=0){
    SectionFound=0
    KeyWaiting=1
    
    IfNotExist %Filename%
	Throw Exception("File not exist", 0, Filename)
    IfExist %Filename%.new
	FileDelete %Filename%.new
    Loop Read, %Filename%, %Filename%.new
    {
	OutputLine := A_LoopReadLine

	If KeyWaiting {
	    If SectionFound {
		If (RegExMatch(A_LoopReadLine,"^\[.+\]$")) { ; Next section begin
		    If Remove {
			If Key
			{
			    ; it must be deleted, but it's not there already
			    Throw Exception("Corresponding key not found inside section", 0, Key)
			}
			; Else Key not specified section must removed, it is, and next has begun
		    } Else { ; Not Remove
			OutputLine := Key . "=" . Value . "`n" . OutputLine
		    }
		    SectionFound=0
		    KeyWaiting=0
		} Else { ; Not a section header, must be name=value
		    If ( Remove && Key=="") ; Removing section, because key not specified
			Continue ; skip to next, Key will never match, KeyWaiting will become 0 only at end of section
		    
		    FoundKey := Trim(SubStr(A_LoopReadLine, 1, InStr(A_LoopReadLine, "=")-1))
		    If FoundKey = %Key%
		    {
			KeyWaiting=0
			If Remove
			    Continue ; to skip FileAppend
			Else
			    OutputLine = %Key%=%Value%
			; TODO: overwrite it return SubStr(A_LoopReadLine, NameValueSplitPos+2)
		    }
		}
	    } Else {
		If A_LoopReadLine = [%IniSection%]
		{
		    SectionFound=1
		    If ( Remove && Key=="") ; Removing section, because key not specified
			Continue
		}
	    }
	}
	FileAppend %OutputLine%`n, %Filename%.new
    }
    
    If KeyWaiting ; Section not found
	FileAppend [%IniSection%]`n%Key%=%Value%, %Filename%.new
	; ToDo: Add section, write key&val
    
    FileMove %Filename%,%Filename%.%A_Now%.bak
    FileMove %Filename%.new,%Filename%,1
}
