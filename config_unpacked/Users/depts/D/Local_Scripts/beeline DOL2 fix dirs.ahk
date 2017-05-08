#NoEnv
#SingleInstance off

logfname=%A_ScriptFullPath%.log
DOL2SettingsKey=HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs
DOL2ReqdBaseDir=d:\dealer.beeline.ru\DOL2

rewriteKeys := Object()

Loop Reg, %DOL2SettingsKey%
{
    If (A_LoopRegName) {
	foundavalue:=1
	RegRead rv

	If (A_Index==1) {
	    files := Object()
	    curBasePath := rv
	} Else {
	    curBasePath := CommonPath(curBasePath, rv)
	}
	    rewriteKeys[A_LoopRegName] := rv
    }
}

skipLen := StrLen(curBasePath) + 1

If (skipLen < 4)
    Throw "Длина текущего базового пути меньше 3"

FileAppend %A_Now% Исправление путей в %DOL2SettingsKey% с "%curBasePath%".`n,%logfname%

For k,v in rewriteKeys {
    subPath := SubStr(v, skipLen)
    If (!subPath) {
	If (v != curBasePath)
	    Throw "В ключе " . v . " указан путь """ . v . """, который не совпадает с текущим базовым путем """ . curBasePath . """, но при этом такой же по длине или короче."
    }
    RegWrite REG_SZ, %DOL2SettingsKey%, %k%, % DOL2ReqdBaseDir . subPath
}

MsgBox Пути исправлены`, но без переустановки DOL2 всё равно не заработает`, если в новой корневой папке нет БД конфигурации.

ExitApp

BeginsWith(long, short) {
    return short = SubStr(long, 1, StrLen(short))
}

CommonPath(dir1, dir2) {
    dir1shn:=SubStr(dir1, 1, StrLen(dir2))
    dir2shn:=SubStr(dir2, 1, StrLen(dir1))
    If (dir1shn = dir2shn) {
	return dir1shn
    }
    
    Loop Parse, dir1shn, \
    {
	newCommonPath .= (A_Index > 1 ? "\" : "") . A_LoopField
	If (SubStr(dir2shn, 1, StrLen(newCommonPath)) != newCommonPath)
	    return commonbasePath
	commonbasePath:=newCommonPath
    }
    Throw "Should not happen"
}
