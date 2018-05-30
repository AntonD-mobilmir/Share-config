;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

RegWrite REG_DWORD, HKEY_CURRENT_USER\Software\TeamViewer\Version5.1, ShowTaskbarInfoOnMinimize, 0

cardText=
FileReadLine nameTV, %A_AppDataCommon%\mobilmir.ru\trello-id.txt, 3
If (!TVName)
    nameTV = %A_USERNAME% \\%A_COMPUTERNAME%

RegWrite REG_SZ, HKEY_CURRENT_USER\Software\TeamViewer\Version5.1, Username, %nameTV%
