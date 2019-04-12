;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
;FileEncoding UTF-8 - actually CSV reports are in ANSI

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

pathReport = %A_Temp%\%A_ScriptName%.%A_Now%.tsv
pathInv7zBase = \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\actual\RetailDepts

depts := {}
Progress A M,список отделов для апгрейда.txt,Загрузка списка отделов
Loop Read, список отделов для апгрейда.txt
    If (RegexMatch(A_LoopReadLine, "(\S+)(?:@(\s|$))", em))
        depts[em1] := A_LoopReadLine, dc++
Progress Off

InvReportsToSpreadsheet(pathReport, pathInv7zBase, depts)
Run %pathReport%
ExitApp

#include <InvReportsToSpreadsheet>
