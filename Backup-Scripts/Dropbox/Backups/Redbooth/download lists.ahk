#NoEnv
#SingleInstance
global LocalAppData
EnvGet LocalAppData,LOCALAPPDATA

#include <SHGetFolderPath>
global DLDir=GetKnownFolder("Downloads")
If Not DLDir
    DLDir = %A_MyDocuments%\Downloads

global DestBaseDir:=A_ScriptDir

BackupOneRedboothProject("https://redbooth.com/export/projects/59756/tasks.xlsx", "ИТ инфраструктура-tasks.xlsx")
;BackupOneRedboothProject("https://redbooth.com/export/projects/738180/tasks.xlsx", "Закупки через ОЗ КС-tasks.xlsx")
;BackupOneRedboothProject("https://redbooth.com/export/projects/60730/tasks.xlsx", "www-Интернет-tasks.xlsx")
;BackupOneRedboothProject("https://redbooth.com/export/projects/203632/tasks.xlsx", "Задачи АХО-tasks.xlsx")

BackupOneRedboothProject(url, DownloadedFileName) {
    TrayTip,,Opening %url%
    Run "%A_AhkPath%" "%LocalAppData%\Scripts\Chrome.ahk" %url%
    
    Sleep 3000
    
    Timeout := A_TickCount + 300000

    Loop
    {
	Sleep 1000
	Loop %DLDir%\%DownloadedFileName%
	{
	    ChangeTimeout=
	    EnvSub ChangeTimeout, A_LoopFileTimeModified, Seconds
	    TrayTip
	    TrayTip,,%DownloadedFileName% age must be over 2 seconds (%ChangeTimeout% currently)
	    If (ChangeTimeout > 2) {
		SplitPath A_LoopFileName, , , , DestNameNoExt
		FormatTime BackupDate, %A_LoopFileTimeModified%, yyyy-MM-dd HH-mm
		
		DestDir = %DestBaseDir%\%DestNameNoExt% %A_Year%
		FileCreateDir %DestDir%
		TrayTip,,Moving %DownloadedFileName% to %DestDir%
		FileMove %DLDir%\%DownloadedFileName%, %DestDir%\%DestNameNoExt% %BackupDate%.%A_LoopFileExt%
		done=1
		break
	    }
	}
	TimeoutDisplay:=(Timeout-A_TickCount)//1000
	TrayTip
	TrayTip,,Waiting %DownloadedFileName% to appear (timeout %TimeoutDisplay%)
    } Until (done || A_TickCount > Timeout)
    TrayTip
    TrayTip,,Done with %DownloadedFileName%
}
