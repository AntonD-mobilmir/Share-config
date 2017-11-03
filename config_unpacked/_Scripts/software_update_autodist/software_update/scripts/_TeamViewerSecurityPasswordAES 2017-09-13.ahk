;Проверка текущего пароля в реестре и перезапись при совпадении – для замены стандартных паролей

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

;d:\Users\LogicDaemon\Dropbox\Backups\TeamViewer

write := -1
verbosity := 2
EnvGet RunInteractiveInstalls,RunInteractiveInstalls
If (RunInteractiveInstalls != "")
    verbosity := RunInteractiveInstalls
Loop %0%
{
    If (skipArgs--)
	continue
    arg := %A_Index%
    argFlag := SubStr(arg, 1,1)
    If argFlag in /,-
    {
	swName := SubStr(arg, 2)
	If swName in q,quiet,s,silent
	    verbosity := 0
	Else If (swName = "warn")
	    verbosity := 1
	Else If (swName = "verbose")
	    verbosity := 2
	Else If (swName = "log") {
	    skipArgs := 1
	    logPathargN := A_Index+1
	    logPath := %logPathargN%
	} Else
	    Throw Exception("Неопознанная опция",,arg)
    } Else
	Throw Exception("Лишний параметр командной строки",,arg)
    
}

If (!logPath) {
    logPath := *
    FileEncoding CP866
}

ListOldPasswds := {"F574177FCCEC51367FBDE604C9D7D8BAC00F32131DC7EFC8D33885495010A90526BF392D7177FB520E2B2BB2303A0616": "."	; 2016-08-24 Apps_dept
		  ,"F2AD0177D24744298C530F4F05EE62B2D3AD5A77FD9DF84C535ACD8ECF54ACD3201D31B03EADCFF4B0E37A8E7C7795D0": "."	; 2016-08-24 Apps_office
		  ,"4012F58BE8D40F6C2295C3B108EC3AEE1C428441D85540FB940A5DE55277416A94E0E6CEE9AFAAAAA0033361C3D91D71": "."	; 2016-08-24 Apps_roaming
		  ,"CF99A6F596A9DDF779D50900C68ADB318C9A3F319894A01E79F085C24697E8BD351E5B2DFD1F4DFBBF3E83A79C9117C5": "!"	; 2016-08-24 TeamViewer_host.defaults.reg
		  ,"6C15BFFBE803522724BCA99EEF7EE07BA626CAAAE67EDED2B5B25A1E5FE61F87403EA59EB64B27C15504B1E9C47DC5F5": "!"	; 2017-09-13 TeamViewer_host.defaults.reg
		  ,"F0BA0A56A7DDCD6D3D4F00649A9066908057A79AB2F204B73237A765D1887DB15E9606C44E57F570B5155610D773B272": "!"	; 2017-09-13 TeamViewer5HostUnattended_egs
		  ,"92C58FB6571F0912C6C0318C916E2E01970D0E220A01A64B2CEF00C845C524A1E96893CE6E5CAE4589D791E9C7D71E05": ""	; 2017-09-13 Apps_roaming
		  ,"7F6F9B14ACA7111E8EDC315457999E2E7A0CDDC0CDB5856DADB6D2139652E47EDE55829E38D26E0BEC6A0121AD8C308B": ""	; 2017-09-13 TeamViewer_ServiceNote.reg
		  ,"011A63AD1B98919BE210595C1F03F26EE937A9454C292874787572E84E64781D56E6B0144885AE5B4C50B21384CFA55E": ""	; 2017-09-13 Apps_office
		  ,"1521F2964BD7826E3086A012B83097C43C95A95FD3DE005386308EE60BC77D0F043376055DCD5A8E416053C8C217EF51": "" }	; 2017-09-13 Apps_dept

OldPassHashes := {	 "e5cea553a702dfea4d0df508c7fa32bf":""	; до 2017-09-13\TeamViewer_host.defaults.reg
			,"e7c4c0134748b894aa5bcfc65ef7d4e0":""	; до 2017-09-13\Apps_dept\*.reg
			,"3ba9fd9337e1b3cc3e426d55a85c6b5c":""	; до 2017-09-13\Apps_office\*.reg
			,"75a1ae487a131ac684441f0a4490e930":""	; до 2017-09-13\Apps_roaming\*.reg
			,"f479d774e8bc76723cdfd322754e77cc":""	; до 2017-09-13\TeamViewer5HostUnattended_egs\TeamViewer_host.reg
			,"742c2b5812955928e50b0053aaa645b4":"!"	; до 2016-08-18\TeamViewer_host.defaults.reg
			,"308f8e5264396fa07e9530a92d65afbd":"."	; до 2016-08-18\Apps_dept\TeamViewer.reg, Apps_office\TeamViewer.reg, Apps_roaming\TeamViewer.reg
			,"3e84f2424c8ae3f52af890ab9eb066b9":"Apps_dept.7z"	; до 2016-08-18\Apps_dept\TeamViewer_host.reg
			,"e2499266c256861e2ff57a8e3d3a472c":"."	; до 2016-08-18\Apps_office\TeamViewer_Host.reg, Apps_roaming\TeamViewer_Host.reg
			,"26d5b24f2bdd004ef942684f2b3d1ddc":"!"	} ; до 2016-08-18\TeamViewer5HostUnattended_egs\TeamViewer_host.reg 
SetRegView 32
RegRead curpwd, HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1, SecurityPasswordAES
If (curpwd) {
    md5ofpwd := MD5(curpwd)
    FileAppend Из реестра прочитан зашифрованный пароль TeamViewer %curpwd%`, его MD5: %md5ofpwd%`n, %logPath%

    If (ListOldPasswds.HasKey(curpwd)) {
	switchKey := ListOldPasswds[curpwd]
    } Else If (OldPassHashes.HasKey(md5ofpwd)) {
	switchKey := OldPassHashes[md5ofpwd]
    } Else {
	ShowMsg(einf := "Установленный в данный момент пароль не опознан. Изменения не вносятся.", 0x10)
	write := ""
    }
} Else {
    ShowMsg(einf := "В реестре нет пароля TeamViewer, или он недоступен для чтения.", 0x40)
    write := ""
}

If (write) {
    If (switchKey=="") {
	ShowMsg(einf := "Для текущего пароля ничего делать не требуется.", 0x40)
	write := 0
    } Else If (switchKey==".") {
	writeOk := WriteRegSettings(write := "", einf := "")
    } Else If (switchKey=="!") {
	writeOk := WriteRegSettings(write := "", einf := "")
	ShowMsg(einf := "Был установлен пароль TeamViewer, который надо менять сразу после установки. Сейчас импортирован пароль из " write ", но если известно, кто настраивал TeamViewer, сообщите ему, что он не прав.", 0x30)
	write := "! " write
    } Else {
	writeOk := WriteRegSettings(write := switchKey, einf := "")
    }
}

If (write) {
    If (writeOk)
	status=OK
    Else
	status=Err
    configDir := getDefaultConfigDir()
    Run "%A_AhkPath%" "%configDir%\_Scripts\Lib\RetailStatusReport.ahk" "%A_ScriptName%" "%status% (%write%)" "%einf%"
}

ExitApp !writeOk

WriteRegSettings(ByRef defaultsPath, ByRef einf) {
    If (defaultsPath == "")
	defaultsPath := getDefaultConfig()
    
    ;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
    SplitPath defaultsPath,            ,       ,             , defArcName
    
    static ListNewPasswds := {     "Apps_dept":   	"1521F2964BD7826E3086A012B83097C43C95A95FD3DE005386308EE60BC77D0F043376055DCD5A8E416053C8C217EF51"
				 , "Apps_office": 	"011A63AD1B98919BE210595C1F03F26EE937A9454C292874787572E84E64781D56E6B0144885AE5B4C50B21384CFA55E"
				 , "Apps_roaming":	"92C58FB6571F0912C6C0318C916E2E01970D0E220A01A64B2CEF00C845C524A1E96893CE6E5CAE4589D791E9C7D71E05"
			, "TeamViewer_ServiceNote.reg":	"7F6F9B14ACA7111E8EDC315457999E2E7A0CDDC0CDB5856DADB6D2139652E47EDE55829E38D26E0BEC6A0121AD8C308B"} ; TeamViewer_ServiceNote.reg
	   ; 2017-09-13 "TeamViewer_host.defaults.reg": "6C15BFFBE803522724BCA99EEF7EE07BA626CAAAE67EDED2B5B25A1E5FE61F87403EA59EB64B27C15504B1E9C47DC5F5"
	   ; 2017-09-13 "TeamViewer5HostUnattended_egs":"F0BA0A56A7DDCD6D3D4F00649A9066908057A79AB2F204B73237A765D1887DB15E9606C44E57F570B5155610D773B272"
    
    If (ListNewPasswds.HasKey(defArcName)) {
	If (!A_IsAdmin) {
	    If (verbosity) {
		Run % "*RunAs " DllCall( "GetCommandLine", "Str" ),,UseErrorLevel  ; Requires v1.0.92.01+
		ExitApp
	    } Else
		return 0, ShowMsg(einf := "Скрипт запущен без прав администратора в не-интерактивном режиме. ", 0x10)
	}
	
	RegWrite REG_BINARY, HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1, SecurityPasswordAES, % ListNewPasswds[defArcName]
	If (ErrorLevel)
	    return 0, ShowMsg(einf := "Ошибка " A_LastError ? A_LastError : ErrorLevel " при записи нового пароля.", 0x10)
	Else
	    return 1, ShowMsg(einf := "Пароль заменён на пароль из конфигурации " . defArcName)
    } Else {
	return 0, ShowMsg(einf := "Не найден пароль для конфигурации " . defaultsPath, 0x10)
    }
}

ShowMsg(ByRef text, type:=0) {
    global verbosity, logPath
    FileAppend %text%`n, %logPath%
    If (verbosity == 2 || verbosity && type && (type & 0x70 != 0x40))
	MsgBox % type, %A_ScriptName%, %text%, 300
}

; \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\getDefaultConfig.ahk
getDefaultConfigFileName(defCfg := -1) {
    If (defCfg==-1)
	defCfg := getDefaultConfig()
    SplitPath defCfg, OutFileName
    return OutFileName
}

getDefaultConfigDir(defCfg := -1) {
    If (defCfg==-1) {
        EnvGet configDir, configDir
	If (configDir)
	    return RTrim(configDir, "\")
	defCfg := getDefaultConfig()
    }
    SplitPath defCfg,,OutDir
    return OutDir
}

getDefaultConfig(batchPath := -1) {
    If (batchPath == -1) {
	EnvGet DefaultsSource, DefaultsSource
	If (DefaultsSource)
	    return DefaultsSource
	Try {
	    return getDefaultConfig(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd")
	}
    EnvGet SystemDrive, SystemDrive
	return getDefaultConfig(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd")
    } Else {
	return ReadSetVarFromBatchFile(batchPath, "DefaultsSource")
    }
}

;#Include %A_LineFile%\..\ReadSetVarFromBatchFile.ahk
ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
   {
	If (RegExMatch(A_LoopReadLine, "i)SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", m)) {
	    If (Trim(Trim(mName), """") = varname) {
		return Trim(Trim(mValue), """")
	    }
	}
    }
    Throw Exception("Var not found",, varname)
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

