#NoEnv
EnvGet lProgramFiles, ProgramFiles(x86)
If (!lProgramFiles)
    lProgramFiles:=A_ProgramFiles

Sleep 2000
FileCreateShortcut %lProgramFiles%\Mozilla Thunderbird\thunderbird.exe,%A_Startup%\Mozilla Thunderbird.lnk,%lProgramFiles%\Mozilla Thunderbird,,(создано скриптом %A_ScriptFullPath%),,,,7
FileDelete %A_ScriptFullPath%
