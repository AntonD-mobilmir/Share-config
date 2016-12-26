#NoEnv

; %1% list of objects (files or directories)
; %2% destination where they will be linked

;MsgBox % list of objects: %1%`ndestination where they will be linked: %2%

IfNotExist %1%
    Errors=Listfile %1% not exist
Else
    Loop Read, %1%
    {
	SplitPath A_LoopReadLine, SrcName, SrcDir
;	FileGetAttrib Attributes,A_LoopReadLine
;	IfInString Attributes, D
	If Not SrcName
	{
	    SplitPath SrcDir, SrcName
	    RunWait "%A_ScriptDir%\xln.exe" -n "%SrcDir%" "%2%%SrcName%",,UseErrorLevel
	} Else
	    RunWait "%A_ScriptDir%\xln.exe" "%A_LoopReadLine%" "%2%%SrcName%",,UseErrorLevel

	If ErrorLevel
	    Errors = %Errors%`nErr %ERRORLEVEL%: %A_LoopReadLine%
    	FileAppend Error %ERRORLEVEL% linking %A_LoopReadLine%`n",*
    }

If Errors
    MsgBox 48, Errors occured while linking, %Errors%
