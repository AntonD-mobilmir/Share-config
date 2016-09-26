#NoEnv
#SingleInstance ignore

appname=LibreOffice
binaryname=soffice.bin
shutdowntext=Требуется закрыть %appname%. За 10 секунд до перезагрузки процесс %binaryname% будет остановлен`, и перезагрузка не произойдёт`, но не сохранённые изменения документов будут утеряны.
interactivequerytime=300

stage:=0
stage1:=10
stage2:=stage1+interactivequerytime

GroupAdd binaryownedwindowsgroup, ahk_exe %binaryname%
EnvGet RunInteractiveInstalls,RunInteractiveInstalls

Loop
{
    If (killprocess==1) {
	Loop
	{
	    Process Close, %binaryname%
	} Until !ErrorLevel
	killprocess=0
    }
    
    Process Exist, %binaryname%
    If (ErrorLevel==0) {
	If (shutdowntime)
	    Run "%A_WinDir%\System32\shutdown.exe" /a
	Exit 0 ; 0 means it's ok, no process running
    }
    
    If (stage<stage1) { ; stage 0 -- close LO windows and check for currently-exiting LO
	IfWinExist ahk_group binaryownedwindowsgroup
	{
	    TrayTip Установка %appname%, Интерактивное завершение %binaryname%
	    ToolTip Сейчас %appname% будет закрыт!
	    Sleep 3000
	    ToolTip
	    If (stage==1) { ; Try soft-close (Alt+F4) first
		PostMessage 0x112, 0xF060,,, ahk_group binaryownedwindowsgroup ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
		Process WaitClose, %binaryname%, %interactivequerytime%
	    } Else { ; Then Get more insisting
		WinClose ahk_group binaryownedwindowsgroup,,%interactivequerytime%
		Process WaitClose, %binaryname%, %interactivequerytime%
	    }
	} ; Else Process exists, but no window, just Wait to make sure it's not currently exiting with its window hidden
    } Else If (stage<stage2) { ; stage 1 -- check ask if there's user, and forcely close soffice.bin unless he cancels or declines
	If (RunInteractiveInstalls!=0) {
	    TrayTip Установка %appname%, Интерактивное завершение %binaryname%
	    MsgBox 35, Установка %appname%, Процесс %binaryname% в данный момент запущен. Если %appname% будет запущен во время обновления`, установленный экземлпяр будет поврежден`, и потребуется переустановка. Закрыть его принудительно?, %interactivequerytime%
	    IfMsgBox Cancel
		Exit 1 ; 1 means cancel by user request
	    IfMsgBox No
		Exit 0 ; bad decision, but as user said
	    IfMsgBox TIMEOUT
		If (A_TimeIdle > stage2*1000)
		    killprocess:=1
	    IfMsgBox Yes
		killprocess:=1
	} Else {
	    If (!shutdowntime) {
		shutdowntime:=interactivequerytime+10
		stopshutdown:=A_TickCount+interactivequerytime*1000
		Run "%A_WinDir%\System32\MSG.EXE" * /TIME %interactivequerytime% %shutdowntext%,,UseErrorLevel
		Run "%A_WinDir%\System32\shutdown.exe" /r /c "%shutdowntext%" /t %shutdowntime%,,UseErrorLevel
	    } Else If (A_TickCount >= stopshutdown) {
		killprocess=1
	    }
	}
    } Else { ;stage 2
	Exit 1 ; failure
    }

    Sleep 1000
    stage++
}
