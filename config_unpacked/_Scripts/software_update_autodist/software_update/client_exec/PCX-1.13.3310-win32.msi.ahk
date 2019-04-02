;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

If (!EndsWith(A_ComputerName, "-K")) {
    ExitApp
}

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

tmp = %A_Temp%\PCX-1.13.3310-win32.msi.7z %A_ScriptName%

FileCreateDir %tmp%
Unpack(tmp "\PCX-1.13.3310-win32.msi.7z"
     , "https://www.dropbox.com/s/uc3subnxup982m9/PCX-1.13.3310-win32.msi.7z?dl=1"
     , tmp)

If (InstallMSI(tmp "\PCX-1.13.3310-win32.msi", "/qn"))
    FileRemoveDir %tmp%, 1

ExitApp

Unpack(ByRef arcfname, ByRef URL, ByRef destDir) {
    static exe7z := find7zexe()
    
    While (!FileExist(arcfname))
        Download(arcfname, URL)
    
    RunWait %exe7z% x -aoa -y -o"%destDir%" -- "%arcfname%",, Hide, cmdPID
    StatusUpdate(ErrorLevel, "unpacking " arcfname " → " destDir)
}

Download(ByRef arcfname, ByRef URL) {
    Random rnd, 0, 9999
    tmpDir := A_Temp "\" A_ScriptName A_Now rnd
    FileCreateDir %tmpDir%
    
    RunWait C:\SysUtils\wget.exe -N %URL%, %tmpDir%, Hide UseErrorLevel, cmdPID
    StatusUpdate(lasterr := ErrorLevel, "wget " URL " → " arcfname)
    If (lasterr) {
        UrlDownloadToFile %URL%, %arcfname%.tmp
        StatusUpdate(lasterr := ErrorLevel, "UrlDownloadToFile " URL " → " arcfname)
        If (!lasterr) {
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

InstallMSI(MSIFileFullPath, params) {
    Global logPath
    
    SplitPath MSIFileFullPath, MSIFileName
    logPath=%A_TEMP%\%MSIFileName%.log
    Menu Tray, Tip, Installing %MSIFileFullPath%
TryInstallAgain:
    RunWait %A_WinDir%\System32\msiexec.exe /i "%MSIFileFullPath%" %params% /norestart /l+* "%logPath%",, UseErrorLevel
    lasterr := ErrorLevel
    If (lasterr==1618) { ; Another install is currently in progress
	TrayTip %textTrayTip%, Error 1618: Another install currently in progress`, waiting 30 sec to repeat
	Sleep 30000
	GoTo TryInstallAgain
    }
    Menu Tray, Tip, %textTrayTip%
    
    StatusUpdate(lasterr, "installing " MSIFileFullPath " " params)
    If (lasterr==3010 || !lasterr) ;3010: restart required
        return 0
}

StatusUpdate(status, ByRef text := "") {
    TrayTip %status%, %text%
    If (!status)
        status := OK
    Run % """" A_AhkPath """ """ getDefaultConfigDir() "\_Scripts\Lib\RetailStatusReport.ahk"" ""PCX-1.13.3310-win32.msi.7z " A_ScriptName """ """ (status ? status : "OK") """ """ text """"
}

EndsWith(long, short) {
    return SubStr(long, -StrLen(short)+1) = short
}

#include <getDefaultConfig>
#include <find7zexe>
#include <URIEncodeDecode>
#include <GetMailUserId>
