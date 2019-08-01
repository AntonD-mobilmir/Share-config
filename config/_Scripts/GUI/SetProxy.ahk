;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance ignore
SetRegView 64

EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server
EnvGet Unattended, Unattended
If (!Unattended) {
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    Unattended := RunInteractiveInstalls=="0"
}
regrootsProxy	:= ["HKEY_LOCAL_MACHINE", "HKEY_CURRENT_USER"]
regKeysEnv	:= ["SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "Environment"]
proxyIEKey	= Software\Microsoft\Windows\CurrentVersion\Internet Settings

ProxyOverride		= <local>

If (A_IsAdmin) {
    If ( A_Is64bitOS ) { ; at least on Windows 10 single run of netsh.exe modifies settings for bot 64-bit and 32-bit winhttp; if this is case for Vista/7/8, if is not needed and only Else can be executes without negative side-effects
        netsh32exe := SystemRoot "\SysWOW64\netsh.exe"
        netsh64exe := SystemRoot "\" (( A_PtrSize == 4 ) ? "SysNative" : "System32") "\netsh.exe" ;32-bit AutoHotkey on 64-bit system?
    } Else
        netsh32exe := SystemRoot "\System32\netsh.exe"
}

RegRead ProxySettingsPerUser, HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings, ProxySettingsPerUser
ProxySettingsPerUser := ProxySettingsPerUser != "0"
SystemProxy:=!ProxySettingsPerUser

If %0%
{ ; %0% – var with name "0", contains nr. of command line arguments
    proxy=%1%
    ProxySettingsPerUser=%2%
} Else If (Unattended) {
    proxy=
    FileAppend No command line args`, turning off proxy.`n, *, CP1
} Else {
    For i, regrootProxy in regrootsProxy {
        RegRead ProxyEnable, %regrootProxy%\%proxyIEKey%, ProxyEnable
        If (ProxyEnable) {
            RegRead proxy, %regrootProxy%\%proxyIEKey%, ProxyServer
            proxySrc = `nТекущее значение прочитано из %regrootProxy%\%proxyIEKey%: ProxyServer
            SystemProxy := 2-i
            break
        }
    }

    If (SystemProxy) {
        If (!A_IsAdmin) {
            MsgBox 51, Включен общесистемный прокси, Скрипт запущен без прав администратора`, но настроено использование общесистемного прокси сервера`, и пользовательские настройки будут игнорироваться.`n`nПерезапустить скрипт от имени администратора?
            IfMsgBox Cancel
                Exit
            IfMsgBox Yes
            {
                ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
                Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
                ExitApp
            }
        }
            
	ProxyQueryText=системные настройки прокси (HKLM)
    } else {
	ProxyQueryText=настройки IE текущего пользователя
    }
    
    InputBox proxy, Адрес прокси сервера, Будет записан в %ProxyQueryText%.`nПустая строка = без прокси.п`nформат: сервер:порт%proxySrc%, , , , , , , 300, %proxy%
    If (ErrorLevel)
	Exit
}

If (proxy) {
    If ( !InStr(proxy,":") ) {
	If (Unattended) {
	    FileAppend Unattended but there's no port in proxy string "%proxy%". Won't continue.`n,*,CP1
	    Exit
	} Else {
	    MsgBox 35, В строке прокси не указан порт, В адресе прокси-сервера "%proxy%" не указан порт через двоеточие.`nБез номера порта работать не будет!`n`nДобавить :3128 к адресу?
	    IfMsgBox Cancel
		Exit
	    IfMsgBox Yes
		proxy=%proxy%:3128
	}
	
    }
} else { ; No proxy
    If (ProxySettingsPerUser == "0") {
	If (!Unattended) {
	    MsgBox 35, Системные настройки прокси.,Сейчас системный прокси будет выключен`, но включенный режим общесистемных настроек не позволит пользователям указать свои адреса прокси.`n`nВыключить переопределение пользовательских настроек?
	    IfMsgBox Cancel
		Exit
	    IfMsgBox Yes
		ProxySettingsPerUser=1
	}
    } Else {
	ProxySettingsPerUser=1
    }
}

If (SystemProxy) {
    ;regKeyEnv=SYSTEM\CurrentControlSet\Control\Session Manager\Environment
    
    If (ProxySettingsPerUser)
	RegDelete HKEY_LOCAL_MACHINE, SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings, ProxySettingsPerUser
;    Else ;    Causes problems with different software, which ignores HKLM record for proxy and uses user records only.
;	RegWrite REG_DWORD, HKEY_LOCAL_MACHINE, SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings, ProxySettingsPerUser, 0
}

If (proxy) {
    If (SystemProxy)
        netshargs=winhttp set proxy proxy-server="http=%proxy%;https=%proxy%;ftp=%proxy%" bypass-list="%ProxyOverride%"
    
    regrootProxy := regrootsProxy[2-SystemProxy]
    regKeyEnv    := regKeysEnv[2-SystemProxy]
    ; envvars: for gpg, wget and other unix utils
    RegWrite REG_SZ, %regrootProxy%\%regKeyEnv%, http_proxy, http://%proxy%/
    RegWrite REG_SZ, %regrootProxy%\%regKeyEnv%, https_proxy, http://%proxy%/

    ;Internet Explorer
    RegWrite REG_SZ, %regrootProxy%\%proxyIEKey%, ProxyServer, %proxy%
    RegWrite REG_SZ, %regrootProxy%\%proxyIEKey%, ProxyOverride, %ProxyOverride%
    RegWrite REG_SZ, %regrootProxy%\%proxyIEKey%, ProxyEnable, 1
} Else {
    For i, regrootProxy in regrootsProxy {
        regKeyEnv := regKeysEnv[i]
	RegDelete %regrootProxy%\%regKeyEnv%, http_proxy
	RegDelete %regrootProxy%\%regKeyEnv%, https_proxy
	
	;Internet Explorer
	RegWrite REG_SZ, %regrootProxy%\%proxyIEKey%, ProxyEnable, 0
    }
    
    If (SystemProxy)
	netshargs=winhttp reset proxy
    RunWait %SystemRoot%\System32\proxycfg.exe -d,,Min UseErrorLevel
}

If (netshargs) {
    RunWait %netsh32exe% %netshargs%,,Min UseErrorLevel
    If (netsh64exe)
	RunWait %netsh64exe% %netshargs%,,Min UseErrorLevel
}

EnvUpdate
