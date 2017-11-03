;Watch Canon MF Scan Utility and Reset ACL for D:\Users\Public\Сканированное
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore
SetTitleMatchMode 3
FileEncoding UTF-8

global ScriptName:="Наблюдение за Canon MF Scan Utility и сброс настроек доступа к отсканированным файлам"
    , ErrMsgs := {scanDirNotFound: "Не найдена папка сканированных документов. Выход."}

ResetMinPeriod := 30000 ; ms

If (!(tgtBase := FindScanDest())) {
    TrayTip(ErrMsgs[scanDirNotFound])
    Sleep 3000
    ExitApp 1
}
TrayTipAndHide("Настройки доступа будут сбрасываться для папки " tgt)

tgt=%tgtBase%\%A_YYYY%_%A_MM%_%A_DD%

mfscanexe=MFSCANUTILITY.exe

GroupAdd mfprogress, Идет сканирование ahk_exe %mfscanexe%
GroupAdd mfprogress, Завершение сканирования ahk_exe %mfscanexe%
GroupAdd mfprogress, Canon MF Scan Utility ahk_exe %mfscanexe%, Обработка...
;,,,&Параметры...
GroupAdd mfprogress, Canon MF Scan Utility ahk_exe %mfscanexe%, Подождите.
GroupAdd mfprogress, ScanGear ahk_exe %mfscanexe%

While WinExist("ahk_exe " mfscanexe) {
    WinWait ahk_group mfprogress,,3
    If (!ErrorLevel) {
	TrayTip("Обнаружено начало сканирования, ожидание завершения")
	WinWaitClose
	ResetACL()
	reset := 1
    }
    TrayTip("Обнаружено окно MF Scan Utility, ожидание начала сканирования")
}
If (!reset)
    ResetACL()
ExitApp

TrayTipAndHide(text, timeout := 3000) {
    TrayTip(text)
    SetTimer HideTrayIcon, % -Abs(timeout)
}

TrayTip(text:="", opt := 0x21) {
    static lastText
    If (lastText!=text) {
	Menu Tray, Icon
	Menu Tray, Tip, %text%
	If (text) {
	    TrayTip %ScriptName%, %text%, %opt%
	} Else {
	    TrayTip
	    Menu Tray, NoIcon
	    Menu Tray, Icon
	}
    }
    lastText:=text
}

HideTrayIcon() {
    TrayTip
    Menu Tray, Tip, %ScriptName%
    Menu Tray, NoIcon
}

ResetACL() {	
    global tgt, ResetMinPeriod
    static SystemRoot, lastReset
    If (!InStr(FileExist(tgt), "D"))
	return
    If (!SystemRoot)
	EnvGet SystemRoot, SystemRoot
    TrayTip("Сброс настроек доступа, чтобы файлы были доступны по сети")
    Sleep ResetMinPeriod - (A_TickCount - lastReset)
    RunWait %SystemRoot%\System32\icacls.exe "%tgt%" /reset /T /C /Q, %tgt%, Hide
    lastReset:=A_TickCount
    TrayTip()
    return
}

;Идет сканирование
;ahk_class #32770
;ahk_exe MFSCANUTILITY.exe

;Завершение сканирования
;ahk_class #32770
;ahk_exe MFSCANUTILITY.exe

;Сканирование завершено.
;Чтобы закончить, нажмите кнопку [Выход].

;Чтобы продолжить сканирование, вставьте следующий документ и нажмите кнопку [Сканировать].
;Сканировать
;Выход

;Canon MF Scan Utility
;ahk_class #32770
;ahk_exe MFSCANUTILITY.exe

;Обработка...
;Подождите.

;ScanGear
;ahk_class #32770
;ahk_exe MFSCANUTILITY.exe

FindScanDest() {
    PublicPictures := GetKnownFolderfromGUID("{B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}") ;PublicPictures,{B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5},54 

    If (PublicPictures)
	tryDirs := [PublicPictures]
    Else
	tryDirs := []
    tryDirs.Push("D:\Users\Public\Pictures")

    For i, dir in tryDirs
	If (InStr(FileExist(tgtBase := dir "\Сканированное"), "D"))
	    return tgtBase
}

GetKnownFolderfromGUID(guid) {
    VarSetCapacity(mypath,1025 * (A_IsUnicode+1))
    SetGUID(rfid, guid) 
    r := DllCall("Shell32\SHGetKnownFolderPath", "UInt", &rfid, "UInt", 0, "UInt", 0, "UIntP", mypath)
    If (!(r || ErrorLevel))
	return StrGet(mypath,,"UTF-16") 
}

SetGUID(ByRef GUID, String) { 
    VarSetCapacity(GUID, 16, 0) 
    StringReplace,String,String,-,,All 
    NumPut("0x" . SubStr(String, 2,  8), GUID, 0,  "UInt")   ; DWORD Data1 
    NumPut("0x" . SubStr(String, 10, 4), GUID, 4,  "UShort") ; WORD  Data2 
    NumPut("0x" . SubStr(String, 14, 4), GUID, 6,  "UShort") ; WORD  Data3 
    Loop, 8 
	NumPut("0x" . SubStr(String, 16+(A_Index*2), 2), GUID, 7+A_Index,  "UChar")  ; BYTE  Data4[A_Index] 
} 
