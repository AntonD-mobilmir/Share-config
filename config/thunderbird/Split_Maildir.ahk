#NoEnv

argc = %0%
If (argc) {
    Loop %0%
    {
	SplitMaildir(RemoveEnding(%A_Index%, "cur"))
    }
} Else {
    If (IsFunc("FindThunderbirdProfile")) {
	mailDir := "FindThunderbirdProfile".() . "\Mail"
    } Else {
	EnvGet UserProfile, UserProfile
	mailDir := UserProfile . "\Mail\Thunderbird\profile\Mail"
    }
    FileSelectFolder selectedDir, *%mailDir%, 3, Выберите папку для разделения. Новые папки будут созданы рядом.
    selectedDir := RemoveEnding(selectedDir, "cur")
    If (!InStr(FileExist(selectedDir . "\cur"), "D")) {
	MsgBox %A_ScriptName%, Выбрана папка "%selectedDir%"`, но в этой папке нет подпапки "cur"`, в которой должны храниться сообщения.
    } Else {
	SplitMaildir(selectedDir)
    }
}

Exit

SplitMaildir(dir) {
    If (!FileExist(dir))
	Throw Exception("SplitMaildir", "Папка не найдена", dir)
    static MaxCount := 1000
    dstLim := MaxCount
    dst := CheckCreateNewPrefix(dir, 1)
    Loop Files, %dir%\cur\*.*
    {
	If (A_Index > dstLim) {
	    dstLim += MaxCount
	    dst := CheckCreateNewPrefix()
	}
	FileMove %A_LoopFileFullPath%, %dst%\cur\*.*
    }
}

CheckCreateNewPrefix(newPrefix:="", newIndex:="", subPath := "cur") {
    static i, prefix
    
    If (newPrefix && newPrefix != prefix) {
	prefix := newPrefix
	If newIndex is integer
	    i:=newIndex
	Else
	    i:=0
    }
	
    Loop {
	dir := prefix . Format("_{:02u}", i)
	i++
	If (i>99)
	    Throw "Слишком много частей"
    } Until !FileExist(dir)

    FileCreateDir %dir%\%subPath%
    return dir
}

RemoveEnding(t, ending) {
    If (SubStr(t, 1-StrLen(ending)) = ending)
	return SubStr(t, 1, -StrLen(ending))
    return t
}

#include *i \\Srv0.office0.mobilmir\profiles$\Share\config\thunderbird\FindThunderbirdProfile.ahk
