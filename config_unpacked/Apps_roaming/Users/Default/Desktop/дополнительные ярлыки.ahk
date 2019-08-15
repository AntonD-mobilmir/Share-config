;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#NoTrayIcon
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

For i, path in [ "D:\Users\Public\Shares\profiles$\Share\Users\Common\Desktop"
               , "\\Srv1S.office0.mobilmir\Users\Public\Shares\profiles$\Share\Users\Common\Desktop"
               , "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Users\Common\Desktop" ]
    If (FileExist(path))
        Run %SystemRoot%\explorer.exe /open`,"%path%"
        break
MsgBox Папка дополнительных ярлыков недоступна. Возможно`, поможет подключение VPN.
