;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet SystemDrive, SystemDrive

GoodDirs =
(LTrim
$Recycle.Bin\
BOOT\
Common_Scripts\
Documents and Settings\
Local_Scripts\
PerfLogs\
Program Files (x86)\
Program Files\
ProgramData\
Recovery\
squid\
System Volume Information\
SysUtils\
Users\
Windows\

)

GoodFiles =
(LTrim
autoexec.bat
bootmgr
BOOTNXT
config.sys
swapfile.sys

)

foundList =

Loop Files, %SystemDrive%\*.*, D
{
    If (!InStr(GoodDirs, A_LoopFileName . "\"))
	foundList .= "`n" . A_LoopFileName . "\"
}

Loop Files, %SystemDrive%\*.*, F
{
    If (!InStr(GoodFiles, A_LoopFileName))
	foundList .= "`n" . A_LoopFileName
}

If (foundList) {
    MsgBox На %SystemDrive% обнаружены папки и файлы`, которых нет в списке стандартных. Если это мусор`, удалите перед продолжением`, пожалуйста:`n%foundList%
}
