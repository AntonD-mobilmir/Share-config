;Скрипт для создания ярлыка к dealer.beeline.ru.cmd
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

FileEncoding UTF-8
SendMode InputThenPlay

RegRead PointNumber, HKEY_CURRENT_USER, Software\VIMPELCOM\InternetOffice\Dealer_On_Line\System, DealerPointCode

Gui Add, Text, , Код точки: 
Gui Add, Edit, ym w150 VPointNumber, %PointNumber%
Gui Add, Button, ym Default, &OK
Gui Show

Exit

ButtonOK:
    Gui Submit
;    RegRead, UserDesktop, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, Desktop
;    MsgBox, %UserDesktop%

    Required_CSIDL=40 ; Profile
    VarSetCapacity(ProfilePath,(A_IsUnicode ? 2 : 1)*65536) 
    r := DllCall("Shell32\SHGetFolderPath", "int", 0 , "uint", Required_CSIDL , "int", 0 , "uint", 0 , "str" , ProfilePath)
    If (r or ErrorLevel or !ProfilePath) {
	MsgBox 16, Расположение профиля пользователя не определено, Не удалось определить папку профиля пользователя (код ошибки: %ErrorLevel%). Скрипт будет снова запущен при следующем входе в систему.,30
    }

    IfExist D:\Users\%A_UserName%\Desktop
	DesktopPath = D:\Users\%A_UserName%\Desktop
    Else {
	IfExist %A_Desktop%
	    DesktopPath = %A_Desktop%
	Else
	    FileSelectFolder DesktopPath, ::{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}, 2, Не удалось определить путь к рабочему столу. Укажите его вручную пожалуйста.
    }

    If (!DesktopPath) {
	MsgBox 64, Расположение рабочего стола не определено, Ярлык не будет создан.,30
	Return
    }

    ShortcutFileName := DesktopPath . "\" . PointNumber . " dealer.beeline.ru.lnk"

    FileCreateShortcut `%comspec`%, %ShortcutFileName% , %A_ScriptDir%, /C ""%A_ScriptDir%\dealer.beeline.ru.cmd" %PointNumber%", Установка кода точки и запуск системы Билайн Дилер Он-Лайн, %A_ScriptDir%\favicon.ico (16×16).ico, , 1, 7

ExitApp

GuiClose:
GuiEscape:
ExitApp
