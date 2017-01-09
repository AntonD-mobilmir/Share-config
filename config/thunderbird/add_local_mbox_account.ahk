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
Loop Read, %mtProfileDir%\prefs.js, %tmpPrefs%
{
    ;NewStr := RegExReplace(Haystack, NeedleRegEx [, Replacement = "", OutputVarCount = "", Limit = -1, StartingPosition = 1])
    FileAppend % RegexReplace(A_LoopReadLine, "S)" . regexS, regexR) . "`n"
}

FileRead mboxappend, %A_ScriptDir%\default_profile_template\prefs_MBOXLocalAccount.js
FileAppend `n%mboxappend%,%tmpPrefs%
FileMove %tmpPrefs%, %mtProfileDir%\prefs.js, 1

FileCreateDir %mtProfileDir%\Mail.MBOX\1

ExitApp

#include %A_ScriptDir%\FindThunderbirdProfile.ahk
