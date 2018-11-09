;Проверка текущего пароля в реестре и перезапись при совпадении – для замены стандартных паролей

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

regPassKey = "SecurityPasswordAES"=hex:

ListPassHashes := {	 "e5cea553a702dfea4d0df508c7fa32bf":""	; действующие\TeamViewer_host.defaults.reg
			,"dcc3c599c017e66ef26af2ad41ad851f":""	; действующие\Apps_dept\TeamViewer*.reg
			,"3ba9fd9337e1b3cc3e426d55a85c6b5c":""	; действующие\Apps_office\TeamViewer.reg, TeamViewer_Host.reg
			,"75a1ae487a131ac684441f0a4490e930":""	; действующие\Apps_roaming\TeamViewer.reg, TeamViewer_Host.reg
			,"f479d774e8bc76723cdfd322754e77cc":""	; действующие\TeamViewer5HostUnattended_egs\TeamViewer_host.reg

                        ,"a7d5df881f9720f3dfe2470b6985506a":"."	; до 2018-10-08\Apps_dept\TeamViewer.reg (DT-2)
			,"e7c4c0134748b894aa5bcfc65ef7d4e0":"."	; до 2018-10-08\Apps_dept\TeamViewer.reg, TeamViewer_host.reg
			,"742c2b5812955928e50b0053aaa645b4":"!"	; до 2016-08-18\TeamViewer_host.defaults.reg
			,"308f8e5264396fa07e9530a92d65afbd":"."	; до 2016-08-18\Apps_dept\TeamViewer.reg, Apps_office\TeamViewer.reg, Apps_roaming\TeamViewer.reg
			,"3e84f2424c8ae3f52af890ab9eb066b9":"Apps_dept.7z"	; до 2016-08-18\Apps_dept\TeamViewer_host.reg
			,"e2499266c256861e2ff57a8e3d3a472c":"."	; до 2016-08-18\Apps_office\TeamViewer_Host.reg, Apps_roaming\TeamViewer_Host.reg
			,"26d5b24f2bdd004ef942684f2b3d1ddc":"!"	} ; до 2016-08-18\TeamViewer5HostUnattended_egs\TeamViewer_host.reg 
SetRegView 32
RegRead curpwd, HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1, SecurityPasswordAES
md5ofpwd := MD5(curpwd)
FileAppend Из реестра прочитан зашифрованный пароль TeamViewer %curpwd%`, его MD5: %md5ofpwd%`n,*, cp1

If (ListPassHashes.HasKey(md5ofpwd)) {
    switchKey := ListPassHashes[md5ofpwd]
    
    If (switchKey=="") {
	ShowMsg("Для текущего пароля ничего делать не требуется.")
    } Else If (switchKey==".") {
	WriteRegSettings()
    } Else If (switchKey=="!") {
	ShowMsg("В реестре указан пароль TeamViewer, который должен был быть изменён сразу после установки. Сейчас будет импортирован стандартный пароль, но если известно, кто настраивал TeamViewer, сообщите ему, что он не прав.", 0x30)
	WriteRegSettings()
    } Else {
	WriteRegSettings(switchKey)
    }
} Else {
    ShowMsg("Установленный в данный момент пароль не опознан. Изменения не вносятся.`n`nЗашифрованный пароль: " curpwd "`, MD5: " md5ofpwd,0x10)
    ExitApp 1
}

ExitApp

WriteRegSettings(defaultsPath := "") {
    If (!defaultsPath) {
	defaultsPath := getDefaultConfig()
    }
    
    ;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
    SplitPath defaultsPath,            ,       ,             , defArcName
    
    ListNewPasswds := {	 "Apps_dept":	"B6A0BA5F7280B090C170550CE7F554F3AE79B80B2BF25BC426A53BD99A4CF7F82D0216227D045C557E243FEC53FC2B66"
			,"Apps_office":	"F2AD0177D24744298C530F4F05EE62B2D3AD5A77FD9DF84C535ACD8ECF54ACD3201D31B03EADCFF4B0E37A8E7C7795D0"
			,"Apps_roaming":	"4012F58BE8D40F6C2295C3B108EC3AEE1C428441D85540FB940A5DE55277416A94E0E6CEE9AFAAAAA0033361C3D91D71"}
    
    If (ListNewPasswds.HasKey(defArcName)) {
	If (!A_IsAdmin) {
	    EnvGet RunInteractiveInstalls,RunInteractiveInstalls
	    If (RunInteractiveInstalls!="0") {
		ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
		Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
		ExitApp
	    } Else {
		ShowMsg("Скрипт запущен без прав администратора в не-интерактивном режиме. ")
	    }
	}

	RegWrite REG_BINARY, HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1, SecurityPasswordAES, % ListNewPasswds[defArcName]
	If (ErrorLevel) {
	    ShowMsg("Ошибка записи нового пароля.", 0x10)
	} Else {
	    ShowMsg("Пароль заменён на пароль из конфигурации " . defArcName)
	}
    } Else {
	ShowMsg("Не найден пароль для конфигурации " . defaultsPath, 0x10)
    }
}

ShowMsg(text, type:=0) {
    static envGot
    If (!envGot) {
	EnvGet RunInteractiveInstalls,RunInteractiveInstalls
	envGot:=1
    }
    
    FileAppend %text%`n,*,cp1
    If (RunInteractiveInstalls!="0") {
	MsgBox % type, %A_ScriptName%, %text%, 60
    }
}

; \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\getDefaultConfig.ahk
getDefaultConfig() {
    EnvGet SystemDrive, SystemDrive
    defaultConfig := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd", "DefaultsSource")
    If (!defaultConfig)
	defaultConfig := ReadSetVarFromBatchFile(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd", "DefaultsSource")
    return defaultConfig
}

getDefaultConfigFileName() {
    defaultConfig := getDefaultConfig()
    SplitPath defaultConfig, OutFileName
    return OutFileName
}

getDefaultConfigDir() {
    defaultConfig := getDefaultConfig()
    SplitPath defaultsSource,,OutDir
    return OutDir
}

;#Include %A_LineFile%\..\ReadSetVarFromBatchFile.ahk
ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	If (mpos := RegExMatch(A_LoopReadLine, "i)SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", match)) {
	    If (Trim(Trim(matchName), """") = varname) {
		return Trim(Trim(matchValue), """")
	    }
	}
    }
}

;src: https://github.com/jNizM/AutoHotkey_Scripts/blob/master/Functions/Checksums/MD5.ahk

; ===================================================================================
; AHK Version ...: AHK_L 1.1.14.03 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: Checksum: MD5
;                  Calc MD5-Hash from String / Hex / File / Address
;                  http://en.wikipedia.org/wiki/MD5
; Version .......: 2014.04.09-1828
; Author ........: Bentschi
; Modified ......: jNizM
; ===================================================================================

; MD5 ===============================================================================
MD5(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8003, encoding)
}
HexMD5(hexstring)
{
	return CalcHexHash(hexstring, 0x8003)
}
FileMD5(filename)
{
    return CalcFileHash(filename, 0x8003, 64 * 1024)
}
AddrMD5(addr, length)
{
    return CalcAddrHash(addr, length, 0x8003)
}

; CalcAddrHash ======================================================================
CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0)
{
    static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
    static b := h.minIndex()
    hProv := hHash := o := ""
    if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
    {
        if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash))
        {
            if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
            {
                if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0))
                {
                    VarSetCapacity(hash, hashlength, 0)
                    if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0))
                    {
                        loop % hashlength
                        {
                            v := NumGet(hash, A_Index - 1, "UChar")
                            o .= h[(v >> 4) + b] h[(v & 0xf) + b]
                        }
                    }
                }
            }
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
        }
        DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    }
    return o
}

; CalcStringHash ====================================================================
CalcStringHash(string, algid, encoding = "UTF-8", byref hash = 0, byref hashlength = 0)
{
    chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
    length := (StrPut(string, encoding) - 1) * chrlength
    VarSetCapacity(data, length, 0)
    StrPut(string, &data, floor(length / chrlength), encoding)
    return CalcAddrHash(&data, length, algid, hash, hashlength)
}

; CalcHexHash =======================================================================
CalcHexHash(hexstring, algid)
{
    length := StrLen(hexstring) // 2
    VarSetCapacity(data, length, 0)
    loop % length
    {
        NumPut("0x" SubStr(hexstring, 2 * A_Index - 1, 2), data, A_Index - 1, "Char")
    }
    return CalcAddrHash(&data, length, algid)
}

; CalcFileHash ======================================================================
CalcFileHash(filename, algid, continue = 0, byref hash = 0, byref hashlength = 0)
{
	fpos := ""
    if (!(f := FileOpen(filename, "r")))
    {
        return
    }
    f.pos := 0
    if (!continue && f.length > 0x7fffffff)
    {
        return
    }
    if (!continue)
    {
        VarSetCapacity(data, f.length, 0)
        f.rawRead(&data, f.length)
        f.pos := oldpos
        return CalcAddrHash(&data, f.length, algid, hash, hashlength)
    }
    hashlength := 0
    while (f.pos < f.length)
    {
        readlength := (f.length - fpos > continue) ? continue : f.length - f.pos
        VarSetCapacity(data, hashlength + readlength, 0)
        DllCall("RtlMoveMemory", "Ptr", &data, "Ptr", &hash, "Ptr", hashlength)
        f.rawRead(&data + hashlength, readlength)
        h := CalcAddrHash(&data, hashlength + readlength, algid, hash, hashlength)
    }
    return h
}

