;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet SystemDrive,SystemDrive

If (InStr(FileExist(SystemDrive "\ComProxy"), "D")) {
    RunWait %SystemRoot%\System32\net.exe stop ComProxy,,UseErrorLevel
    For i, v in ["com0com", "c0c"]
        If (FileExist(uninstpath := (uninstdir := "C:\ComProxy\" v) "\uninstall.exe"))
            For j, arg in ["/s", ""]
                If (FileExist(uninstpath))
                    RunWait "%uninstpath%" %arg%,%uninstdir%,UseErrorLevel
    RunWait %comspec% /C "C:\ComProxy\uninstallService.cmd",C:\ComProxy,UseErrorLevel
}
