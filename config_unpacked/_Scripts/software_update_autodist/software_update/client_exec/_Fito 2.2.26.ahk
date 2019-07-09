;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet RunInteractiveInstalls,RunInteractiveInstalls
RunInteractiveInstalls := RunInteractiveInstalls!="0"

If (RunInteractiveInstalls) {
    If (!A_IsAdmin) {
        ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
        Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
        if ErrorLevel = ERROR
            MsgBox Без прав администратора ничего не выйдет.
        ExitApp
    }
    Menu Tray, Add, Show hidden window, ShowHiddenCMD
} Else If (!InStr(FileExist("d:\1S\Утилиты Вики-Принт"), "D"))
    ExitApp 0

Unpack(A_Temp "\Утилиты.7z"
      , "https://p-ams1.pcloud.com/cBZJXwMA8ZceNhuQZZZetdNA7Z2ZZfb5ZkZ2bKQZKVZR7ZhJZnXZ1JZoZUJZtXZ1kZ65ZYZ15ZRXZC7ZfiO37ZaVGEYGxzaOXDqhdjUuy7RjzngOU7/%D0%A3%D1%82%D0%B8%D0%BB%D0%B8%D1%82%D1%8B.7z"
      , "d:\1S\Утилиты Вики-Принт")
    RunWait %SystemRoot%\System32\icacls.exe "d:\1S\Утилиты Вики-Принт\*.ini" /T /C /Grant *S-1-5-11:M, d:\1S\Утилиты Вики-Принт, Min
    StatusUpdate((ErrorLevel ? "[!] Error " ErrorLevel : "[OK]") " icacls.exe")
ExitApp

ShowHiddenCMD:
    WinShow ahk_pid %cmdPID%
return

Unpack(ByRef arcfname, ByRef URL, ByRef destDir) {
    global cmdPID
    static exe7z := find7zexe()
    
    While (!FileExist(arcfname)) {
        If (FileExist(absarcfname := A_ScriptDir "\" arcfname))
            arcfname := absarcfname
        Else
            Download(arcfname, URL)
    }
    RunWait %exe7z% x -aoa -y -o"%destDir%" -- "%arcfname%",, Hide, cmdPID
    If (ErrorLevel)
        StatusUpdate("[!] Error " ErrorLevel " unpacking " arcfname " → " destDir)
}

Download(ByRef arcfname, ByRef URL) {
    global cmdPID
    Random rnd, 0, 9999
    tmpDir := A_Temp "\" A_ScriptName A_Now rnd
    FileCreateDir %tmpDir%
    
    StatusUpdate("[.] wget " URL " → " arcfname)
    RunWait C:\SysUtils\wget.exe -N %URL%, %tmpDir%, Hide UseErrorLevel, cmdPID
    If (ErrorLevel) {
        StatusUpdate("[!] Error " ErrorLevel " wget " URL " → " arcfname ", trying UrlDownloadToFile")
        UrlDownloadToFile %URL%, %arcfname%.tmp
        If (ErrorLevel) {
            StatusUpdate("[!] Error " ErrorLevel " UrlDownloadToFile " URL " → " arcfname)
        } Else {
            StatusUpdate("[OK] UrlDownloadToFile " URL " → " arcfname)
            FileMove %arcfname%.tmp, %arcfname%, 1
        }
    } Else {
        Loop Files, %tmpDir%\*.*
            If (A_Index > 1)
                Throw Exception("Во временной папке загрузок больше одного файла",, tmpDir)
            Else
                FileMove %A_LoopFileFullPath%, %arcfname%
    }
    FileRemoveDir %tmpDir%, 1
}

StatusUpdate(ByRef status) {
    global RunInteractiveInstalls
    static MailUserId := GetMailUserId()
    If (RunInteractiveInstalls) {
        Menu Tray, Tip, %A_ScriptName%: %status%
        TrayTip,,%status%
        Sleep ErrorLevel ? 3000 : 0
    }
    
    Run % """" A_AhkPath """ """ getDefaultConfigDir() "\_Scripts\Lib\RetailStatusReport.ahk"" """ A_ScriptName """ """ (status ? status : "OK") """ """ text """"
}

#include <getDefaultConfig>
#include <find7zexe>
#include <URIEncodeDecode>
#include <GetMailUserId>
