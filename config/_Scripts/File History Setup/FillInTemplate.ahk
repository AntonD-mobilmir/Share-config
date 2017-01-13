;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
global GUID,r

templateFile=%1%
outFileName=%2%
If (!outFileName) {
    EnvGet LocalAppData, LOCALAPPDATA
    outFileName=%LocalAppData%\Microsoft\Windows\FileHistory\Configuration\Config1.xml
}

TryAgain:

If (FileExist(outFileName)) {
    ; ToDo: вычитать GUID из config1.xml
    Loop Read, %outFileName%
    {
	RegexMatch(A_LoopReadLine, "<UserName>(?<UserName>[^<]+)</UserName>", r)
	|| RegexMatch(A_LoopReadLine, "<FriendlyName>(?<FriendlyName>[^<]+)</FriendlyName>", r)
	|| RegexMatch(A_LoopReadLine, "<PCName>(?<COMPUTERNAME>[^<]+)</PCName>", r)
	|| RegexMatch(A_LoopReadLine, "<UserId>(?<GUID>[^<]+)</UserId>", r)
	|| RegexMatch(A_LoopReadLine, "<LocalCatalogPath1>(?<LocalCatalogPath1>[^<]+)</LocalCatalogPath1>", r)
	|| RegexMatch(A_LoopReadLine, "<LocalCatalogPath2>(?<LocalCatalogPath2>[^<]+)</LocalCatalogPath2>", r)
	|| RegexMatch(A_LoopReadLine, "<StagingAreaPath>(?<StagingAreaPath>[^<]+)</StagingAreaPath>", r)
	|| RegexMatch(A_LoopReadLine, "<DPFrequency>(?<DPFrequency>[^<]+)</DPFrequency>", r)
	|| RegexMatch(A_LoopReadLine, "<DPStatus>(?<DPStatus>[^<]+)</DPStatus>", r)
	|| RegexMatch(A_LoopReadLine, "<RetentionPolicyType>(?<RetentionPolicyType>[^<]+)</RetentionPolicyType>", r)
	|| RegexMatch(A_LoopReadLine, "<TargetName>(?<TargetName>[^<]+)</TargetName>", r)
	|| RegexMatch(A_LoopReadLine, "<TargetUrl>(?<TargetUrl>[^<]+)</TargetUrl>", r)
	|| RegexMatch(A_LoopReadLine, "<TargetDriveType>(?<TargetDriveType>[^<]+)</TargetDriveType>", r)
	|| RegexMatch(A_LoopReadLine, "<TargetConfigPath1>(?<TargetConfigPath1>[^<]+)</TargetConfigPath1>", r)
	|| RegexMatch(A_LoopReadLine, "<TargetConfigPath2>(?<TargetConfigPath2>[^<]+)</TargetConfigPath2>", r)
	|| RegexMatch(A_LoopReadLine, "<TargetCatalogPath1>(?<TargetCatalogPath1>[^<]+)</TargetCatalogPath1>", r)
	|| RegexMatch(A_LoopReadLine, "<TargetCatalogPath2>(?<TargetCatalogPath2>[^<]+)</TargetCatalogPath2>", r)
	|| RegexMatch(A_LoopReadLine, "<TargetBackupStorePath>(?<TargetBackupStorePath>[^<]+)</TargetBackupStorePath>", r)
	;|| RegexMatch(A_LoopReadLine, "<{}>(?<{}>[^<]+)</{}>", r)
    }
    
    FileMove %outFileName%, %outFileName%.%A_Now%.bak

    If (!templateFile)
	templateFile=%A_ScriptDir%\File History loose template\Config1.xml
} Else {
    MsgBox 0x36, %A_ScriptName%, "Файл настроек ещё не существует: """ . outFileName . """`n`nЕсли архивация ещё не настроена, этот скрипт срабатывает, но настройки не отражаются в панели управления. Сначала включите архивацию, затем запустите скрипт для обновления настройки (или нажмите ""Повторить"").", 300
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

Try {
    Loop Read, %templateFile%, %outFileName%
	FileAppend % Expand(A_LoopReadLine) . "`n"
} Catch e {
    Throw e
}

ExitApp

Expand(string) {
    PrevPctChr:=0
    LastPctChr:=0
    VarnameJustFound:=0
    output:=""

    While ( LastPctChr:=InStr(string, "%", true, LastPctChr+1) ) {
	If (VarnameJustFound) {
	    reqdVarName := SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    If (reqdVarName)
		If (%reqdVarName%)
		    CurrEnvVar:=%reqdVarName%
	    If (!CurrEnvVar)
		EnvGet CurrEnvVar,%reqdVarName%
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
