;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
;FileEncoding UTF-8 - actually CSV reports are in ANSI

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

pathReport = %A_Temp%\%A_ScriptName%.%A_Now%.tsv
pathInv7zBase = \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\actual\RetailDepts

depts := {}
Progress A M,https://docs.google.com/spreadsheets/d/1VPfguqo2fBt5a23Fu8cl_KtOSrMLQOiDuxs17YdmKyg/,Загрузка списка отделов
deptsList := GetURL("https://docs.google.com/spreadsheets/d/e/2PACX-1vS1VdSPrtzh81PwFn--mytpZqsgjmTZBtAEzhEINXBnOt-b8gSuD3s5xqyj5-bC1uLw1RhZgwPxFzyV/pub?gid=0&single=true&output=tsv")
Loop Parse, deptsList, `n, `r
    If (RegexMatch(A_LoopField, "A)(?P<Name>.+) (?P<ID>[^ ]+)@", dept))
        depts[deptID] := A_LoopField
Progress Off

InvReportsToSpreadsheet(pathReport, pathInv7zBase, depts)
Run %pathReport%
ExitApp

#include <InvReportsToSpreadsheet>
#include <GetURL>
