;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; 1st argument is always archive name
; 2nd arg could be either another archive (and so on) or 1st argument for setup executable
global LocalDistributivesDrive="d:"

If %0%
{
    EnvGet exe7z, exe7z
    If (exe7z) {
        exe7z := Trim(exe7z, """")
    } Else {
        ;fails for unknown reason. Works when TryInvokeFunc has no Try, but this causes unhandled exceptions -- exe7z := TryInvokeFunc({find7zGUIorAny: [ A_LineFile "\..\..\..\Soft\PreInstalled\utils" ]})
        exe7z := TryInvokeFunc({find7zexe: ["7zg.exe"]}, {find7zexe: ["7z.exe"]}, {find7zaexe: [ A_LineFile "\..\..\..\Soft\PreInstalled\utils" ]})
        If (!exe7z) {
            FileSelectFile exe7z, 3, 7z.exe, Путь к исполняемому файлу 7-Zip (7z.exe`, 7zg.exe либо 7za.exe), Portable Executable (*.exe)
            If (!exe7z)
                ExitApp -1
        }
    }

    Menu Tray, Tip, Installing Intel Zip
    zipname=%1%
    If %2%
    {
	IfExist %2%
	{
	    Loop %0%
		InstallLatestByMask(%A_Index%)
	} Else {
	    CommandLine := DllCall( "GetCommandLine", "Str" )
	    ExecCommand := SubStr(CommandLine, InStr(CommandLine,A_ScriptName,1)+StrLen(A_ScriptName)+2)
	    args := SubStr(ExecCommand, InStr(ExecCommand,zipname,1)+StrLen(zipname)+2)
	    InstallLatestByMask(zipname, args)
	}
    } Else {
	InstallLatestByMask(zipname)
    }
} Else {
    MsgBox В качестве аргументов необходимо передать названия (или маски) файлов`, которые надо установить.
}

Exit

InstallLatestByMask(path,args="") {
    Loop %path%
	If ( A_LoopFileTimeModified > LatestTimeFound )
	    LatestArchive := A_LoopFileLongPath, LatestTimeFound := A_LoopFileTimeModified
    If args
	Install(LatestArchive,args)
    Else
	Install(LatestArchive)
}

Install(pathSrc,args="") {
    global exe7z
    static CurrentScriptCopied=0
    
    IfNotExist %pathSrc%
	MsgBox Source %pathSrc% not found!

    If (!CurrentScriptCopied) {
	SplitPath A_ScriptDir, , , , , ScriptDrive
	ThisScriptLocalDistPath := LocalDistributivesDrive . SubStr(A_ScriptDir, StrLen(ScriptDrive)+1)
	FileCreateDir %ThisScriptLocalDistPath%
	IfExist %ThisScriptLocalDistPath%\.
	    FileCopy %A_ScriptFullPath%, %ThisScriptLocalDistPath%, 1
	CurrentScriptCopied=1
    }
    
    SplitPath pathSrc, SrcZipName, SrcZipDir, , SrcZipNamewoExt, SrcZipDrive
    LocalDistPath := LocalDistributivesDrive . SubStr(SrcZipDir, StrLen(SrcZipDrive)+1)
    FileCreateDir %LocalDistPath%
    IfExist %LocalDistPath%\.
    {
	FileCopy %SrcZipDir%\*.ahk, %LocalDistPath%, 1
	FileCopy %SrcZipDir%\*.cmd, %LocalDistPath%, 1
	FileCopy %pathSrc%, %LocalDistPath%, 1
	If (!ErrorLevel) {
	    SplitPath pathSrc, SrcZipFName
	    pathSrc = %LocalDistPath%\%SrcZipFName%
	}
    }

    TempExtractPath=%A_Temp%\%A_ScriptName% %SrcZipNamewoExt%
    
    RunWait "%exe7z%" x -aoa -y -o"%TempExtractPath%" -- "%pathSrc%",,UseErrorLevel
    If (ErrorLevel) {
	If (ErrorLevel=="ERROR") {
	    MsgBox 7-Zip ("%exe7z%") не запустился :(
	    return
	} Else 
	    MsgBox При распаковке "%pathSrc%" 7-Zip ("%exe7z%") сообщил об ошибке %ErrorLevel%.
    }
    If (!InStr(FileExist(TempExtractPath), "D")) {
	MsgBox "%pathSrc%" не распаковался в "%TempExtractPath%"!
	return
    }

    Loop Files, %TempExtractPath%\SetupChipset.exe, R ; newer inf driver has different executable name and command line arguments
    {
	SetupPath:=A_LoopFileLongPath
	SetupDir:=A_LoopFileDir
	If (!args) {
	    args=-s -norestart -log "%A_Temp%\%SrcZipNamewoExt% Install.log"
	}
    }
    If (!SetupPath) {
	Loop Files, %TempExtractPath%\Setup.exe, R
	{
	    SetupPath=%A_LoopFileLongPath%
	    SetupDir=%A_LoopFileDir%
	    If (!args) {
		args=-s -overwrite -report "%A_Temp%\%SrcZipNamewoExt% Install.log"
	    }
	}
    }
    
    If (SetupPath) {
	TrayTip Установка Intel'овского zip'а, Запуск %SetupPath%
	RunWait "%SetupPath%" %args%,%SetupDir%,UseErrorLevel
	Sleep 1000
	If (ErroLevel=="ERROR") {
	    ErrorText = Win32: %A_LastError%`, "%SetupPath%" не запустился!
	} Else {
	    ErrorText := ErrorTextForCode(ErrorLevel)
	    If (ErrorText)
		ErrorText := ErrorLevel . " – " . ErrorText
	    Else
		ErrorText := ErrorLevel . " (ищите описание в интернете)"
	}
	; 14 = reboot required, 5 = no matching devices found, 3010 = reboot required
	If ErrorLevel in 0,5,14,3010
	{
	    TrayTip,, Установка закончена с кодом %ErrorText% (всё нормально).`nУдаление временной папки.
	    FileRemoveDir %TempExtractPath%, 1
	} Else {
	    MsgBox При установке произошел сбой`, код ошибки %ErrorText%. Временная папка "%TempExtractPath%" не будет удалена автоматически.
	}
    } Else {
	MsgBox Не найден исполняемый файл`, который надо запускать для установки. Архив распаковывался в папку "%TempExtractPath%"`, можно проверить в ней и исправить скрипт.
    }
}

ErrorTextForCode(code) {
;Коды ошибок установщика Intel: https://communities.intel.com/message/165076
;Новые установщики используют MSI, коды ошибок MSI: https://support.microsoft.com/en-us/kb/229683
static ErrorsText := {0:	"0x0	Success"
		    , 1:	"0xA001	Bad command line"
		    , 2:	"0xA002	User is not an administrator"
		    , 3:	"0xA003	The OS is not supported for this product"
		    , 5:	"0xA005	No devices were found that matched package INF files"
		    , 7:	"0xA007	User refused a driver downgrade"
		    , 9:	"0xA009	User canceled the installation"
		    ,10:	"0xA00A	Another install is already active"
		    ,11:	"0xA00B	Error while extracting files"
		    ,12:	"0xA00C	Nothing to do"
		    ,13:	"0xA00D	A system restart is needed before setup can continue"
		    ,14:	"0xA00E	Setup has completed successfully but a system restart is required"
		    ,15:	"0xA00F	Setup has completed successfully and a system restart has been initiated"
		    ,16:	"0xA010	Bad installation path"
		    ,17:	"0xA011	Error while installing driver"
		    ,255:	"(see Win32 error code in log.)	General install failure"
		    ,1602:	"(MSI) User cancel installation."
		    ,1603:	"(MSI) Fatal error during installation."
		    ,3010:	"(MSI) A restart is required to complete the install. This does not include installs where the ForceReboot action is run. Note that this error will not be available until future version of the installer."}
    return ErrorsText[code]
}

TryInvokeFunc(fnNames*) {
    ; fNames: "fnNameWoParams", {fnName: [fnParams*]}
    local i,fn,fnName,fnParams,rv
    For i,fn in fnNames
	If (IsObject(fn)) {
	    For fnName, fnParams in fn
		If (IsFunc(fnName) && rv := %fnName%(fnParams*))
		    Try return rv
	} Else If (IsFunc(fn) && rv := %fn%())
	    Try return rv
}

#include *i <find7zexe> ; only available when running from Srv0
;#include *i %A_LineFile%\..\..\..\config\_Scripts\Lib\find7zexe.ahk ; only available when running local copy (with Distributives\config)
