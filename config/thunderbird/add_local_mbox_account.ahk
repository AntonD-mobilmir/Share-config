;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

argc=%0%
If (argc) {
    mtProfileDir = %1%
} Else {
    Try {
	mtProfileDir := FindThunderbirdProfile()
    }
    mtProfileDir := SelectMTProfileFolder(mtProfileDir, 1)
}

;user_pref("mail.accountmanager.accounts", "accountLocalFolders,accountMainGoogleMailIMAP,accountRSS");
regexS=user_pref\("mail\.accountmanager\.accounts"`, "(.*)"\);$
regexR=user_pref("mail.accountmanager.accounts"`, "$1`,accountMBOX");

tmpPrefs=%mtProfileDir%\prefs.js.tmp
FileDelete %tmpPrefs%
If (FileExist(tmpPrefs))
    Throw "Не удалось удалить временный файл"

While FileExist(mtProfileDir . "\parent.lock") {
    WinClose ahk_exe thunderbird.exe
    If (!splashOn && A_Index > 1) {
	Progress AM ZH0, При выходе Thunderbird перезаписывает prefs.js`, так что добавить учётную запись в открытый профиль нельзя., Профиль занят`, ожидание освобождения., %A_ScriptName%
	splashOn := 1
    }
    Sleep 1000
    FileDelete %mtProfileDir%\parent.lock
}
If (splashOn)
    SplashTextOff

Loop Read, %mtProfileDir%\prefs.js, %tmpPrefs%
{
    ;NewStr := RegExReplace(Haystack, NeedleRegEx [, Replacement = "", OutputVarCount = "", Limit = -1, StartingPosition = 1])
    FileAppend % RegexReplace(A_LoopReadLine, "S)" . regexS, regexR) . "`n"
}

FileRead mboxappend, %A_ScriptDir%\prefs-parts\prefs_MBOXLocalAccount.js
FileAppend `n%mboxappend%,%tmpPrefs%
FileMove %tmpPrefs%, %mtProfileDir%\prefs.js, 1

FileCreateDir %mtProfileDir%\Mail.MBOX\1

ExitApp

#include %A_ScriptDir%\FindThunderbirdProfile.ahk
