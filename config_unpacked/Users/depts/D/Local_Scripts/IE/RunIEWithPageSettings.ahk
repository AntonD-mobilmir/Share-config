#NoEnv
#NoTrayIcon
#SingleInstance

EnvGet ProgramFiles_with_IE,ProgramFiles(x86)
If Not ProgramFiles_with_IE
    EnvGet ProgramFiles_with_IE,ProgramFiles

EnvGet SystemRoot,SystemRoot

RunWait %SystemRoot%\System32\REG.exe IMPORT "%A_ScriptDir%\%1%.reg",,Hide UseErrorLevel
Run "%ProgramFiles_with_IE%\Internet Explorer\iexplore.exe" %2%
