;Stop Windows from associating its apps with file types and protocols
;via http://www.ghacks.net/2016/10/28/stop-resetting-my-apps/
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

global pkgBaseKey:="HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages"
        ,assocList:=Object()
        ,appList := Object()
        
Loop Reg, %pkgBaseKey%, K
{
    packageName:=A_LoopRegName
    If(DeniedApp(packageName))
        Loop Reg, %pkgBaseKey%\%packageName%, K
            ListAppAssoc(packageName, A_LoopRegName)
    Else
        Loop Reg, %pkgBaseKey%\%packageName%, K
            If (DeniedApp(A_LoopRegName))
                ListAppAssoc(packageName, A_LoopRegName)
}

For appName, ftype in appList {
    list .= appName . ": " . Trim(ftype, ",") . "`n`n"
}
MsgBox 0x24, Запретить следующие ассоциации?, %list%

IfMsgBox Yes
{
    For assocID in assocList {
        RegWrite REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\%assocID%, NoOpenWith
    }
}

ListAppAssoc(packageName, appName) {
    humanReadableAppName := appName = "App" ? packageName : appName
    Loop Reg, %pkgBaseKey%\%packageName%\%appName%\Capabilities, K ; FileAssociations / URLAssociations / …
        If (EndsWith(A_LoopRegName, "Associations")) {
            Loop Reg, %pkgBaseKey%\%packageName%\%appName%\Capabilities\%A_LoopRegName%
                If ( !(BeginsWith(A_LoopRegName, "ms") || BeginsWith(A_LoopRegName, "microsoft") || BeginsWith(A_LoopRegName, "outlook")) ) {
                    RegRead assocID
                    assocList[assocID] := ""
                    appList[humanReadableAppName] .= A_LoopRegName . ","
                }
        }
}

DeniedApp(appName) {
    static DenyApps := [ "Microsoft.MicrosoftEdge"
                        ,"Microsoft.Windows.Photos"
                        ,"microsoft.windowslive.mail"
                        ,"Microsoft.ZuneMusic"
                        ,"Microsoft.ZuneVideo"]
    For i,v in DenyApps {
        If (appName = v || BeginsWith(appName, v . "_"))
            return 1
    }
    return 0
}

BeginsWith(longstr, shortstr) {
    return SubStr(longstr, 1, StrLen(shortstr)) = shortstr
}

EndsWith(longstr, shortstr) {
    return SubStr(longstr, 1-StrLen(shortstr)) = shortstr
}

;First, read something like this:
;    [HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\Microsoft.MicrosoftEdge_38.14393.0.0_neutral__8wekyb3d8bbwe\MicrosoftEdge\Capabilities]
;    "ApplicationName"="@{Microsoft.MicrosoftEdge_38.14393.0.0_neutral__8wekyb3d8bbwe?ms-resource://Microsoft.MicrosoftEdge/Resources/AppName}"
;    "ApplicationDescription"="@{Microsoft.MicrosoftEdge_38.14393.0.0_neutral__8wekyb3d8bbwe?ms-resource://Microsoft.MicrosoftEdge/Resources/AppDescription}"

;    [HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\Microsoft.MicrosoftEdge_38.14393.0.0_neutral__8wekyb3d8bbwe\MicrosoftEdge\Capabilities\FileAssociations]
;    ".htm"="AppX4hxtad77fbk3jkkeerkrm0ze94wjf3s9"
;    ".html"="AppX4hxtad77fbk3jkkeerkrm0ze94wjf3s9"
;    ".pdf"="AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723"
;    ".svg"="AppXde74bfzw9j31bzhcvsrxsyjnhhbq66cs"
;    ".xml"="AppXcc58vyzkbjbs4ky0mxrmxf8278rk9b3t"

;    [HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\Microsoft.MicrosoftEdge_38.14393.0.0_neutral__8wekyb3d8bbwe\MicrosoftEdge\Capabilities\URLAssociations]
;    "http"="AppXq0fevzme2pys62n3e0fbqa7peapykr8v"
;    "https"="AppX90nv6nhay5n6a98fnetv7tpk64pp35es"
;    "read"="AppXe862j7twqs4aww05211jaakwxyfjx4da"
;    "microsoft-edge"="AppX7rm9drdg8sk7vqndwj3sdjw11x96jc0y"
;Then, write to [HKEY_CURRENT_USER\SOFTWARE\Classes\AppX*] NoOpenWith=REG_SZ:
