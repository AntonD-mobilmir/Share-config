;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; A_ComputerName != "CtrlRevDept-03"
If (A_Args[1]) {
    compPrefixSC=\\%1%
    compPrefixReg=\\%1%:
}
ProfileListRegKey=%compPrefixReg%HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList

RunWait sc.exe %compPrefixSC% start RemoteRegistry

profileKeysFound := {}
profileKeysBak := {}

Loop Reg, %ProfileListRegKey%, K
{
    If (EndsWith(A_LoopRegName, ".bak")) {
        profileKeysBak[A_LoopRegName] := {}
    } Else {
        profileKeys[A_LoopRegName] := {}
    }
}

For profileKeyBak in profileKeysBak {
    profileKey := SubStr(profileKeyBak, 1, -4)
    
    profVals := {}
    Loop Reg, %ProfileListRegKey%\%profileKey%
        profVals[A_LoopRegName] := A_LoopRegType
    
    If ( profVals.HasKey("Flags")
      && profVals.HasKey("ProfileImagePath")
      && profVals.HasKey("State")) {
        FileAppend %A_Now% Bak key %profileKeyBak% exists for a functional profile key %profileKey%`n, *
    } Else {
        FileAppend %A_Now% Copying "%ProfileListRegKey%\%profileKeyBak%" to "%profileKey%"..., *
        RegKeyCopy(ProfileListRegKey "\" profileKeyBak, ProfileListRegKey "\" profileKey)
        If (!ErrorLevel) {
            FileAppend OK`n%A_Now% Removing "%ProfileListRegKey%\%profileKeyBak%"..., *
            RegDelete %ProfileListRegKey%\%profileKeyBak%
        }
        FileAppend % (ErrorLevel ? "OK" : Error %A_LastError%) "`n", *
    }
}

EndsWith(ByRef long, ByRef short) {
    return short = SubStr(long, -StrLen(short)+1)
}

RegKeyCopy(ByRef src, ByRef dst) {
    errors := 0
    If (!RegexMatch(src, "A)(?P<ComputerName>\\\\[^:\/]+:)?(?P<RootKey>[^\/:]+?)\\(?P<SubKey>.+)", srcReg))
        Throw Exception("reg root key not found in src",, src)
    
    ;MsgBox src: %src%`nsrcRegRootKey: %srcRegRootKey%`nsrcRegSubKey: %srcRegSubKey%
    srcSubkeyLen := StrLen(srcRegSubKey) + 1
    
    Loop Reg, %src%, R
    {
        If (srcRegSubKey == SubStr(A_LoopRegSubKey, 1, StrLen(srcRegSubKey)))
            dstRegSubkey := dst . SubStr(A_LoopRegSubKey, srcSubkeyLen)
        Else
            Throw Exception("Loop Reg subkey does not start with Src subkey",, A_LoopRegSubKey " ← " srcRegSubKey)
        RegRead v
        RegWrite %A_LoopRegType%, %dstRegSubkey%, %A_LoopRegName%, %v%
        errors += ErrorLevel
    }
    ErrorLevel := errors
}

#include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\ObjectToText.ahk
