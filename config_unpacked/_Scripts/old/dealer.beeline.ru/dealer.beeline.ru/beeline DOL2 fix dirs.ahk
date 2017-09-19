#NoEnv
#SingleInstance off

logfname=%A_ScriptFullPath%.log
DOL2SettingsKey=HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs
DOL2ReqdBaseDir=d:\dealer.beeline.ru\DOL2

moveFiles := ["DATA\ARCDB.mdb"
	     ,"DATA\DB.mdb"
	     ,"DATA\DOLNavigator.config.xml"]

RegRead curBasePath, %DOL2SettingsKey%, RootDir

If (curBasePath=DOL2ReqdBaseDir) {
    MsgBox Исправлять нечего`, сейчас указана правильная базовая папка.
    ExitApp
}

If (StrLen(curBasePath) < 3)
    Throw "Длина текущего базового пути меньше 3"

FileAppend %A_Now% Исправление пути в %DOL2SettingsKey% с "%curBasePath%".`n,%logfname%

RegWrite REG_SZ, %DOL2SettingsKey%, RootDir, %DOL2ReqdBaseDir%

For i,subpath in moveFiles {
    SplitPath subpath,,outDir
    If (outDir != prevOutDir)
	FileCreateDir %DOL2ReqdBaseDir%\%OutDir%
    prevOutDir := outDir
    FileMove %curBasePath%\%subpath%, %DOL2ReqdBaseDir%\%subpath%
    If (ErrorLevel)
	moveErrors++
}

If (moveErrors) {
    MsgBox Пути исправлены`, но при переносе файлов БД конфигурации возникли ошибки.
} Else {
    Run explorer.exe /explore`,%curBasePath%
    MsgBox Пути исправлены`, и все файлы БД конфигурации перенесены.`n`nИз "%curBasePath%" можно удалить LOGS`, DATA\HELP и DATA\ARCH.
}

ExitApp
