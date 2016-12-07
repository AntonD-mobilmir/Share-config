#NoEnv

srcMask=%A_ScriptDir%\Far*.x86.*.7z

If %1%
    outDir=%1%
Else
    outDir=c:\Program Files\FAr

Loop %srcMask%
{
    If A_LoopFileName > %Latest%
    {
	Latest=%A_LoopFileName%
	srcFile=%A_LoopFileFullPath%
    }
}

RunWait 7zg.exe x -aoa -r -o"%outDir%" -x!*.map -x!*cze.* -x!*ger.* -x!*hun.* -x!*pol.* -x!*sky.* -x!*spa.* -x!Encyclopedia -x!PluginSDK -x!FExcept -- "%srcFile%"
