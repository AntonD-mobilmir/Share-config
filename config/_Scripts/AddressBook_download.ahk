;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
FileEncoding UTF-8

argv=%1%
If (argv="/debug")
    debug=1
FileReadLine ScriptUpdaterDir, %A_AppDataCommon%\mobilmir.ru\ScriptUpdaterDir.txt, 1
If (!ScriptUpdaterDir)
    Throw Exception("ScriptUpdater не найден",, "%ProgramData%\mobilmir.ru\ScriptUpdaterDir.txt")

FileReadLine abDir, %A_AppDataCommon%\mobilmir.ru\addressbookdir.txt, 1

If (!abDir) {
    If (A_IsAdmin) {
	If (InStr(FileExist("D:\Mail\Thunderbird"), "D"))
	    abDir=D:\Mail\Thunderbird\AddressBook
	Else
	    abDir=%A_AppDataCommon%\mobilmir.ru\AddressBook
	abLocFile=%A_AppDataCommon%\mobilmir.ru\addressbookdir.txt
    } Else {
	EnvGet LocalAppData, LOCALAPPDATA
	abDir=%LocalAppData%\mobilmir.ru\AddressBook
	abLocFile=%LocalAppData%\mobilmir.ru\addressbookdir.txt
    }
    If (debug)
	MsgBox abDirLoc was not defined in addressbookdir.txt. Writing "%abDir%" to "%abLocFile%".
    FileCreateDir %abDir%
    FileDelete %abLocFile%
    FileAppend %abDir%, %abLocFile%, CP1
}
RunWait "%A_AhkPath%" /ErrorStdOut "%ScriptUpdaterDir%\scriptUpdater.ahk" "%abDir%\business_contacts.mab" "https://www.dropbox.com/s/0icvtif93c0dnap/business_contacts.mab.gpg?dl=1" 0, %A_Temp%
If (debug)
    MsgBox,
    (LTrim
	scriptUpdater.ahk Exit code: %ErrorLevel%
	ScriptUpdaterDir: %ScriptUpdaterDir%
	abDir: %abDir%
	abLocFile: %abLocFile%
    )
