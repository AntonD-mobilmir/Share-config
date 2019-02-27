;adopted from https://autohotkey.com/boards/viewtopic.php?t=6057

RtlGetVersion() {
    static RTL_OSVIEX, init := VarSetCapacity(RTL_OSVIEX, 284, 0) && NumPut(284, RTL_OSVIEX, "UInt")
    If (!NumGet(RTL_OSVIEX,         4, "UInt"  ))
	if (DllCall("ntdll.dll\RtlGetVersion", "Ptr", &RTL_OSVIEX) != 0)
	    Throw Exception("DllCall failed", "RtlGetVersion")
    return { 1 : NumGet(RTL_OSVIEX, 282, "UChar" ),  2 : NumGet(RTL_OSVIEX,         4, "UInt"  )
           , 3 : NumGet(RTL_OSVIEX,   8, "UInt"  ),  4 : NumGet(RTL_OSVIEX,        12, "UInt"  )
           , 5 : NumGet(RTL_OSVIEX,  16, "UInt"  ),  6 : StrGet(&RTL_OSVIEX + 20, 128, "UTF-16")
           , 7 : NumGet(RTL_OSVIEX, 276, "UShort"),  8 : NumGet(RTL_OSVIEX,       278, "UShort")
           , 9 : NumGet(RTL_OSVIEX, 280, "UShort") }
	;. "ProductType:`t`t"           RtlGetVersion[1]   "`n"
	;. "MajorVersion:`t`t"          RtlGetVersion[2]   "`n"
	;. "MinorVersion:`t`t"          RtlGetVersion[3]   "`n"
	;. "BuildNumber:`t`t"           RtlGetVersion[4]   "`n"
	;. "PlatformId:`t`t"            RtlGetVersion[5]   "`n"
	;. "CSDVersion:`t`t"            RtlGetVersion[6]   "`n"
	;. "ServicePackMajor:`t`t"      RtlGetVersion[7]   "`n"
	;. "ServicePackMinor:`t`t"      RtlGetVersion[8]   "`n"
	;. "SuiteMask:`t`t"             RtlGetVersion[9]   "`n"
}

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    RtlGetVersion := RtlGetVersion()
    
    FileAppend % "RtlGetVersion function`n"
	   . "RTL_OSVERSIONINFOEXW structure`n`n"
	   . "ProductType:`t`t"           RtlGetVersion[1]   "`n"
	   . "MajorVersion:`t`t"          RtlGetVersion[2]   "`n"
	   . "MinorVersion:`t`t"          RtlGetVersion[3]   "`n"
	   . "BuildNumber:`t`t"           RtlGetVersion[4]   "`n"
	   . "PlatformId:`t`t"            RtlGetVersion[5]   "`n"
	   . "CSDVersion:`t`t"            RtlGetVersion[6]   "`n"
	   . "ServicePackMajor:`t`t"      RtlGetVersion[7]   "`n"
	   . "ServicePackMinor:`t`t"      RtlGetVersion[8]   "`n"
	   . "SuiteMask:`t`t"             RtlGetVersion[9]   "`n", *
}
