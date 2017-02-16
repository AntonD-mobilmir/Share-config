;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8-RAW
global GUID

templateFile=%1%
outFileName=%2%
If (!outFileName) {
    EnvGet LocalAppData, LOCALAPPDATA
    outFileName=%LocalAppData%\Microsoft\Windows\FileHistory\Configuration\Config1.xml
}

TryAgain:

If (FileExist(outFileName)) {
    If (!varNamesAndRegexes)
	varNamesAndRegexes:=FillInVarNamesAndRegexes()
    
    Loop Read, %outFileName%
    {
	For k,v in varNamesAndRegexes {
	    If (!r%k%) { ; if variable with name «r append what-stored-in-k» is not defined, 0 or ""
		If (RegexMatch(A_LoopReadLine, v, r)) {
		    r%k%:=r1
		    break
		}
	    }
	}
	;MsgBox curline:`n%A_LoopReadLine%`nrUserName: %rUserName%
    }
    
    If (!templateFile)
	templateFile=%A_ScriptDir%\File History loose template\Config1.xml
} Else {
    MsgBox 0x36, %A_ScriptName%, % "Файл настроек ещё не существует: """ . outFileName . """`n`nЕсли архивация ещё не настроена, этот скрипт срабатывает, но настройки не отражаются в панели управления. Сначала включите архивацию, затем запустите скрипт для обновления настройки (или нажмите ""Повторить"").", 300
    IfMsgBox TIMEOUT
	ExitApp 64
    IfMsgBox Cancel
	ExitApp 128
    IfMsgBox TryAgain
	GoTo TryAgain
    TypeLib := ComObjCreate("Scriptlet.TypeLib")
    NewGUID := TypeLib.Guid
    TypeLib :=

    If (!RegexMatch(NewGUID, "{([^}]+?)}", GUID)) {
        GUID := NewGUID
    }
    GUID := Format("{:Ls}", Trim(GUID, "{}"))

    If (!templateFile)
	templateFile=%A_ScriptDir%\File History prefilled template\Config1.xml
}

FileDelete %outFileName%.tmp
Try {
    Loop Read, %templateFile%, %outFileName%.tmp
	FileAppend % Expand(A_LoopReadLine) . "`n"
} Catch e {
    Throw e
}
bakName=%outFileName%.bak
While FileExist(bakName)
    bakName=%outFileName%.%A_Index%.bak
FileMove %outFileName%, %outFileName%.bak
FileMove %outFileName%.tmp, %outFileName%

ExitApp

FillInVarNamesAndRegexes() {
    return {  "UserName": "<UserName>([^<]+)</UserName>"
	    , "FriendlyName": "<FriendlyName>([^<]+)</FriendlyName>"
	    , "COMPUTERNAME": "<PCName>([^<]+)</PCName>"
	    , "GUID": "<UserId>([^<]+)</UserId>"
	    , "LocalCatalogPath1": "<LocalCatalogPath1>([^<]+)</LocalCatalogPath1>"
	    , "LocalCatalogPath2": "<LocalCatalogPath2>([^<]+)</LocalCatalogPath2>"
	    , "StagingAreaPath": "<StagingAreaPath>([^<]+)</StagingAreaPath>"
	    , "DPFrequency": "<DPFrequency>([^<]+)</DPFrequency>"
	    , "DPStatus": "<DPStatus>([^<]+)</DPStatus>"
	    , "RetentionPolicyType": "<RetentionPolicyType>([^<]+)</RetentionPolicyType>"
	    , "TargetName": "<TargetName>([^<]+)</TargetName>"
	    , "TargetUrl": "<TargetUrl>([^<]+)</TargetUrl>"
	    , "TargetDriveType": "<TargetDriveType>([^<]+)</TargetDriveType>"
	    , "TargetConfigPath1": "<TargetConfigPath1>([^<]+)</TargetConfigPath1>"
	    , "TargetConfigPath2": "<TargetConfigPath2>([^<]+)</TargetConfigPath2>"
	    , "TargetCatalogPath1": "<TargetCatalogPath1>([^<]+)</TargetCatalogPath1>"
	    , "TargetCatalogPath2": "<TargetCatalogPath2>([^<]+)</TargetCatalogPath2>"
	    , "TargetBackupStorePath": "<TargetBackupStorePath>([^<]+)</TargetBackupStorePath>" }
}

;prev in-loop, doesn't work because earlier regexes clear up variables if values not found in file (rUsername is filled when found, then cleaed when not found)
	;RegexMatch(A_LoopReadLine, "<UserName>(?<UserName>[^<]+)</UserName>", r)
	;|| RegexMatch(A_LoopReadLine, "<FriendlyName>(?<FriendlyName>[^<]+)</FriendlyName>", r)
	;|| RegexMatch(A_LoopReadLine, "<PCName>(?<COMPUTERNAME>[^<]+)</PCName>", r)
	;|| RegexMatch(A_LoopReadLine, "<UserId>(?<GUID>[^<]+)</UserId>", r)
	;|| RegexMatch(A_LoopReadLine, "<LocalCatalogPath1>(?<LocalCatalogPath1>[^<]+)</LocalCatalogPath1>", r)
	;|| RegexMatch(A_LoopReadLine, "<LocalCatalogPath2>(?<LocalCatalogPath2>[^<]+)</LocalCatalogPath2>", r)
	;|| RegexMatch(A_LoopReadLine, "<StagingAreaPath>(?<StagingAreaPath>[^<]+)</StagingAreaPath>", r)
	;|| RegexMatch(A_LoopReadLine, "<DPFrequency>(?<DPFrequency>[^<]+)</DPFrequency>", r)
	;|| RegexMatch(A_LoopReadLine, "<DPStatus>(?<DPStatus>[^<]+)</DPStatus>", r)
	;|| RegexMatch(A_LoopReadLine, "<RetentionPolicyType>(?<RetentionPolicyType>[^<]+)</RetentionPolicyType>", r)
	;|| RegexMatch(A_LoopReadLine, "<TargetName>(?<TargetName>[^<]+)</TargetName>", r)
	;|| RegexMatch(A_LoopReadLine, "<TargetUrl>(?<TargetUrl>[^<]+)</TargetUrl>", r)
	;|| RegexMatch(A_LoopReadLine, "<TargetDriveType>(?<TargetDriveType>[^<]+)</TargetDriveType>", r)
	;|| RegexMatch(A_LoopReadLine, "<TargetConfigPath1>(?<TargetConfigPath1>[^<]+)</TargetConfigPath1>", r)
	;|| RegexMatch(A_LoopReadLine, "<TargetConfigPath2>(?<TargetConfigPath2>[^<]+)</TargetConfigPath2>", r)
	;|| RegexMatch(A_LoopReadLine, "<TargetCatalogPath1>(?<TargetCatalogPath1>[^<]+)</TargetCatalogPath1>", r)
	;|| RegexMatch(A_LoopReadLine, "<TargetCatalogPath2>(?<TargetCatalogPath2>[^<]+)</TargetCatalogPath2>", r)
	;|| RegexMatch(A_LoopReadLine, "<TargetBackupStorePath>(?<TargetBackupStorePath>[^<]+)</TargetBackupStorePath>", r)
	;;|| RegexMatch(A_LoopReadLine, "<{}>(?<{}>[^<]+)</{}>", r)


Expand(string) {
    global
    
    local PrevPctChr:=LastPctChr:=VarnameJustFound:=0, output:="", reqdVarName, CurrEnvVar

    While ( LastPctChr:=InStr(string, "%", true, LastPctChr+1) ) {
	If (VarnameJustFound) {
	    reqdVarName := SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    If (reqdVarName)
		If (%reqdVarName%)
		    CurrEnvVar:=%reqdVarName%
	    If (!CurrEnvVar)
		EnvGet CurrEnvVar,%reqdVarName%
	    If (!CurrEnvVar)
		Throw "Переменная не найдена: " . reqdVarName
	    output .= CurrEnvVar
	    CurrEnvVar=
	    VarnameJustFound:=0
	} else {
	    output .= SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    If (SubStr(string, LastPctChr+1, 1) == "%") { ;double-percent %% skipped ouside of varname
		output .= "%"
		LastPctChr++
	    } else {
		VarnameJustFound:=1
	    }
	}
	PrevPctChr:=LastPctChr
    }

    If (VarnameJustFound) ; That's bad, non-closed varname
	Throw Exception("Var name not closed")
	
    output .= SubStr(string,PrevPctChr+1)
    
    return % output
}
