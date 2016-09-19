;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8
SendMode InputThenPlay

DeleteShortcutOnExit=1

Required_CSIDL=40 ; Profile
VarSetCapacity(ProfilePath,(A_IsUnicode ? 2 : 1)*1025) 
r := DllCall("Shell32\SHGetFolderPath", "int", 0 , "uint", Required_CSIDL , "int", 0 , "uint", 0 , "str" , ProfilePath)
If (r or ErrorLevel or !ProfilePath) {
    MsgBox 16, Расположение профиля пользователя не определено, Не удалось определить папку профиля пользователя (код ошибки: %ErrorLevel%). Скрипт будет снова запущен при следующем входе в систему.,30
}

IfExist %ProfilePath%\Desktop
{
    IfExist D:\Users\%A_UserName%\Desktop
	DesktopPath = D:\Users\%A_UserName%\Desktop
    Else {
	If A_Desktop
	    DesktopPath = %A_Desktop%
	Else
	    FileSelectFolder DesktopPath, ::{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}, 2, Не удалось определить путь к рабочему столу. Укажите его вручную пожалуйста.
    }

    If (!DesktopPath) {
	MsgBox 64, Расположение рабочего стола не определено, Путь к рабочему столу не указан. Запрос появится при следующем входе в систему.,30
	Return
    }
    
    FileMoveDir %ProfilePath%\Desktop, %DesktopPath%, 2
    If ErrorLevel {
	MsgBox 16, Ошибка при перемещении файлов, При перемещении файлов произошла ошибка (Код: %ErrorLevel%). Скрипт будет снова запущен при следующем входе в систему.,30
	DeleteShortcutOnExit=0
    }
}

IfExist %ProfilePath%\My Documents
{
    IfExist D:\Users\%A_UserName%\Documents
	MyDocsPath = D:\Users\%A_UserName%\Documents
    Else {
	If A_MyDocuments
	    MyDocsPath = %A_MyDocuments%
	Else
	    FileSelectFolder MyDocsPath,, 2, Не удалось определить путь к папке «Мои документы». Укажите его вручную пожалуйста.
    }

    If (!MyDocsPath) {
	MsgBox 64, Расположение папки «Мои документы» не определено, Путь к папке «Мои документы» не указан. Запрос появится при следующем входе в систему.,30
	Return
    }
    
    FileMoveDir %ProfilePath%\My Documents, %MyDocsPath%, 2
    If ErrorLevel {
	MsgBox 16, Ошибка при перемещении файлов, При перемещении файлов произошла ошибка (Код: %ErrorLevel%). Скрипт будет снова запущен при следующем входе в систему.,30
	DeleteShortcutOnExit=0
    }
}

If DeleteShortcutOnExit
    FileDelete %A_Startup%\MoveDesktopAndMyDocsToRegistryLocation.lnk
