;HardlinkOrReparse.ahk
; %1% list of objects (files or directories)
; %2% destination where they will be linked

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

;MsgBox % list of objects: %1%`ndestination where they will be linked: %2%

IfNotExist %1%
{
    Errors=Listfile %1% not exist!
    Exit 4
} Else {
    Loop Read, %1%
    {
	SplitPath A_LoopReadLine, SrcName, SrcDir
;	FileGetAttrib Attributes,A_LoopReadLine
;	IfInString Attributes, D
	If (!SrcName) {
	    SplitPath SrcDir, SrcName
	    LinkType = Junction
	    RunWait "%A_ScriptDir%\xln.exe" -n "%SrcDir%" "%2%%SrcName%",,Hide UseErrorLevel
	} Else {
	    LinkType = Hardlink
	    RunWait "%A_ScriptDir%\xln.exe" "%A_LoopReadLine%" "%2%%SrcName%",,Hide UseErrorLevel
	}

	If (ErrorLevel) {
	    errorText = Error %ERRORLEVEL% creating %LinkType% for %A_LoopReadLine%`n
	    Errors = %Errors%%errorText%
	    FileAppend %errorText%,*
	} Else {
	    AtLeastOneSucceeded := 1
	}
    }
}

If (Errors) {
    MsgBox 48, Errors occured while linking, %Errors%
    Exit AtLeastOneSucceeded ? 2 : 1
}
