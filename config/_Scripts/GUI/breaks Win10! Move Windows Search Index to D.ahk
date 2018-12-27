;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

ScriptTitle=Перенос папки индекса
RegRead curSearchRoot, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search, DataDirectory
newSearchRoot := "d:\ProgramData\Microsoft\Search\Data\"

If (curSearchRoot != newSearchRoot) {
    SplitPath newSearchRoot, , , , , OutDrive
    If (FileExist(OutDrive "\")) {
        MsgBox 0x134, %ScriptTitle%, Продолжать аккуратно!`n`nПеренос папки с индексом – экспериментальный`, использовать с осторожностью!`n`n(чтобы отказаться`, выйдите из скрипта через значок в трее)
        IfMsgBox No
            ExitApp
        
        xccurSearchRoot := RTrim(curSearchRoot, "\"), xcnewSearchRoot := RTrim(newSearchRoot, "\")
        Loop
        {
            RegRead startbak, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSearch, Start
            RunWait %SystemRoot%\System32\sc.exe config wsearch start= disabled,,Min
            RunWait %SystemRoot%\System32\net.exe stop WSearch,,Min
            FileCreateDir %newSearchRoot%
            RunWait %comspec% /C "%SystemRoot%\System32\xcopy.exe "%xccurSearchRoot%" "%xcnewSearchRoot%" /E /I /G /H /R /K /O /Y /B /J", %newSearchRoot%, UseErrorLevel ; без comspec, ошибка 4
            If (xcErr := ErrorLevel) {
                FileRemoveDir %newSearchRoot%, 1
                MsgBox 0x23, %ScriptTitle%, Ошибка %xcErr% при копировании старого индекса из "%curSearchRoot%" в "%newSearchRoot%". Попытаться снова? (нет = создать пустые папки) [#%A_Index%]
                IfMsgBox Cancel
                {
                    SplitPath newSearchRoot,, bpnewSearchRoot
                    Loop
                    {
                        FileRemoveDir %bpnewSearchRoot% ; only removed if empty
                        SplitPath bpnewSearchRoot,, bpnewSearchRoot
                    } Until StrLen(bpnewSearchRoot) <= 3 ; ends with "d:", never gets shorter
                    ExitApp
                }
                IfMsgBox No
                {
                    For i, dir in [ newSearchRoot "\Applications\Windows\Projects\SystemIndex"
                                  , newSearchRoot "\Applications\Windows\GatherLogs" ] {
                        Loop
                        {
                            FileCreateDir %dir%
                            If (!InStr(FileExist(dir), "D")) {
                                MsgBox 0x24, %ScriptTitle%, Ошибка %A_LastError% при попытке создания "%dir%". Попытаться снова? [#%A_Index%]
                                IfMsgBox No
                                    ExitApp
                            } Else
                                break
                        }
                    }
                    break
                }
            } Else
                break
        }
        
        ;Run % "rundll32.exe shell32.dll,Control_RunDLL srchadmin.dll", %SystemRoot%\System32
        ;WinWait Indexing Options ahk_class #32770 ahk_exe rundll32.exe
        ;ControlClick Button2
        ;WinWait Advanced Options ahk_pid %rundllPID%
        ;ControlClick Button7
        backupBaseDir := A_AppDataCommon "\mobilmir.ru\reg-backup"
        backupName := backupBaseDir "\Windows Search bak " A_Now ".reg"
        FileCreateDir %backupBaseDir%
        RunWait %SystemRoot%\System32\reg.exe export "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search" "%backupName%",,Min
        Run %SystemRoot%\System32\compact.exe /C /EXE:LZX "%backupName%",,Min
        
        RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search, DataDirectory, %newSearchRoot%
        RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex, LogDirectory, %newSearchRoot%\Applications\Windows\Projects\SystemIndex
        RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex, StreamLogsDirectory, %newSearchRoot%\Applications\Windows\GatherLogs
        
        RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\Gathering Manager\Applications\Windows, ApplicationPath, %newSearchRoot%\Applications\Windows\
        RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\Gathering Manager\Applications\Windows, DefaultProjectPath, %newSearchRoot%\Applications\Windows\Projects
        RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\Gathering Manager\Applications\Windows, GatherLogsPath, %newSearchRoot%\Applications\Windows\GatherLogs
        
        RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\Gathering Manager\Applications\Windows\Projects\SystemIndex, WorkingDirectory, %newSearchRoot%\Applications\Windows\Projects\SystemIndex
        
        RunWait %SystemRoot%\System32\sc.exe config wsearch start= delayed-auto,,Min
        RegWrite REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSearch, Start, %startbak%
        RunWait %SystemRoot%\System32\net.exe start WSearch,,Min
        
        If (curSearchRoot) {
            MsgBox 0x24, %ScriptTitle%, Удалить старую папку индекса "%curSearchRoot%"?
            IfMsgBox Yes
                FileRemoveDir %curSearchRoot%, 1
        }
    }
}
