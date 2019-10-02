;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

;, mtSubdir := "Mozilla Thunderbird"
shortcutName := "Mozilla Thunderbird.lnk"
, exeName := "thunderbird.exe"
, regViews := A_Is64bitOS ? [64, 32] : [0]

;[regKey, value_for_command, 1=parse_command_and_use_1st_token]

regLocs :=  [ ["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" exeName]
              ;[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\thunderbird.exe]
              ;@="C:\\Program Files\\Mozilla Thunderbird\\thunderbird.exe"
              ;"Path"="C:\\Program Files\\Mozilla Thunderbird"
            , ["HKEY_LOCAL_MACHINE\SOFTWARE\Clients\Mail\Mozilla Thunderbird\shell\open\command", "", 1]
              ;@="\"C:\\Program Files\\Mozilla Thunderbird\\thunderbird.exe\" -mail"
            , ["HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Mozilla Thunderbird\*\Main", "PathToExe"]
              ;[HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Mozilla Thunderbird\68.1.0 (en-GB)\Main]
              ;"Install Directory"="C:\\Program Files\\Mozilla Thunderbird"
              ;"PathToExe"="C:\\Program Files\\Mozilla Thunderbird\\thunderbird.exe"
            , ["HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Mozilla Thunderbird *\bin", "PathToExe"]
              ;[HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Mozilla Thunderbird 68.1.0\bin]
              ;"PathToExe"="C:\\Program Files\\Mozilla Thunderbird\\thunderbird.exe"
            , ["HKEY_CLASSES_ROOT\Thunderbird.Url.mailto\shell\open\command", "", 1]
              ;@="\"C:\\Program Files\\Mozilla Thunderbird\\thunderbird.exe\" -osint -compose \"%1\""
            , ["HKEY_CLASSES_ROOT\Thunderbird.Url.news\shell\open\command", "", 1]
              ;@="\"C:\\Program Files\\Mozilla Thunderbird\\thunderbird.exe\" -osint -mail \"%1\""
            , ["HKEY_CLASSES_ROOT\ThunderbirdEML\shell\open\command", "", 1] ]
              ;@="\"C:\\Program Files\\Mozilla Thunderbird\\thunderbird.exe\" \"%1\""

For i, regLoc in regLocs {
    ; regLoc := [regKey, value_for_command, parse_command_and_use_1st_token]
    For i, regView in regViews {
        If (regView)
            SetRegView %regView%
        If (wildcardLoc := InStr(regLoc[1], "*")) {
            subkeyDelim := InStr(regLoc[1], "\",, wildcardLoc+1) ; 0 if * is in leaf key, non-0 if there are \subkeys after wildcarded key
            SplitPath % subkeyDelim ? SubStr(regLoc[1], 1, subkeyDelim - 1) : regLoc[1], regWildcardKey, regBaseKey
            ;MsgBox % ObjectToText([regLoc[1], "subkeyDelim: " subkeyDelim, regWildcardKey "`nregBaseKey: " regBaseKey])
            Loop Reg, %regBaseKey%, K
                If (WildcardMatch(A_LoopRegName, regWildcardKey))
                    If (runCmd := GetRunCmd(regBaseKey "\" A_LoopRegName . (subkeyDelim ? SubStr(regLoc[1], subkeyDelim) : ""), regLoc[2], regLoc[3]))
                        break
        } Else {
            runCmd := GetRunCmd(regLoc[1], regLoc[2], regLoc[3])
        }
    } Until runCmd
} Until runCmd

If (runCmd) {
    MsgBox 0x24, Автозапуск Thunderbird, Создать ярлык для Thunderbird в автозагрузке? В этом случае Thunderbird будет автоматически запускаться при каждом входе в систему.`n`nНайденный путь к исполняемому файлу Thunderbird: %runCmd%, 60
    IfMsgBox Yes
    {
        SplitPath runCmd,, outDir
        FileCreateShortcut "%runCmd%", %A_Startup%\Mozilla Thunderbird.lnk, %outDir%,, Почта,,,, 7
    }
} Else If (FileExist(existingShortcut := A_ProgramsCommon "\" shortcutName)) {
    ;no thunderbird in system – check shortcut just in case
    MsgBox 0x24, Автозапуск Thunderbird, Thunderbird не зарегистрирован в системе`, но в меню Пуск есть для него ярлык. Скопировать его в автозагрузку? В этом случае Thunderbird будет автоматически запускаться при каждом входе в систему., 60
    IfMsgBox Yes
        FileCopy %existingShortcut%, %A_Startup%\%shortcutName%
} Else {
    MsgBox 0x30, Автозапуск Thunderbird, Thunderbird не найден`, ярлык в Автозагрузке создан не будет., 60
}

ExitApp

GetRunCmd(ByRef regKey, ByRef regValName, ByRef parsecl := "") {
    RegRead runCmd, %regKey%, %regValName%
    If (parsecl)
        runCmd := ParseCommandLine(runCmd)[0]
    runCmd := Trim(runCmd, """")
    If (FileExist(runCmd))
        return runCmd
}

#include *i %A_LineFile%\..\..\_Scripts\Lib\ParseCommandLine.ahk
#include *i %A_LineFile%\..\..\_Scripts\Lib\WildcardMatch.ahk
