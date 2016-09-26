#NoEnv

FileAppend Uninstalling JRE 6u22 (F0), *
RunWait MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216022F0} /qn ;6u22
FileAppend Uninstalling JRE 6u22 (FF), *
RunWait MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216022FF} /qn ;6u22
FileAppend Uninstalling JRE 6u31 (FF), *
RunWait MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216031FF} /qn ;6u31
FileAppend Uninstalling JRE 6u35 (FF), *
RunWait MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216035FF} /qn ;6u35
FileAppend Uninstalling JRE 6u37 (FF), *
RunWait MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216037FF} /qn ;6u37
