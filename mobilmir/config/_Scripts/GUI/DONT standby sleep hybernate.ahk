;https://autohotkey.com/board/topic/55496-dont-disable-shutdown-standby-screensaver/
; -- DONT -- by Zed_Gecko
; Provides a task bar menue to quickly/temporarily disable
;     * Screensaver
;     * Monitor-ShutOff
;     * User-LogOff
;     * System-Shutdown
;     * Standby
;     * Hibernate
;     * LAN-Network (see hint for non-german systems)
;
; "Homepage:" http://www.autohotkey.com/forum/topic59943.html
;
; Code based on examples by Chris, SKAN, RobOtter, The Good,  Lexikos (and SKAN again ;-))
;
; modified by Patagonier 2011-05-01:
;   * various fixes and a bit of commenting
;   * added menue entry to enable/disable LAN-Network (for non-German systems, strings in
;     Netstat_detect() need adaption)
;   * command-line-parameters' syntax changed to be more intuitive
;   * menue logic changed: ticked functions are ENabled
;   * introduced internal defaults (change line "defaults := ...")
; modified by Patagonier 2011-05-04:
;   bugfix in toggle function
;
#NoEnv
#Persistent
#SingleInstance force
#ErrorStdOut
SetWorkingDir %A_ScriptDir%

defaults := "Monitor=1 Screensaver=1 LogOff=1 Shutdown=1 Standby=0 Hibernate=0 Network=a"

Helptext_A =
(
--------------------------------------------------------------------------
_|_|_|      _|_|    _|      _|  _|_|_|_|_|
_|    _|  _|    _|  _|_|    _|      _|     
_|    _|  _|    _|  _|  _|  _|      _|     
_|    _|  _|    _|  _|    _|_|      _|     
_|_|_|      _|_|    _|      _|      _|                                                 
--------------------------------------------------------------------------
DONT allows the easy (temporary) deactivation/activation of:
   Monitor-Shutdown     `t("Monitor"      `tor "Mon"   `t)
   Screensaver          `t("Screensaver"  `tor "Scr"   `t)
   LogOff               `t("LogOff"       `tor "Log"   `t)
   Shutdown             `t("Shutdown"     `tor "Shtdwn"`t)
   Standby              `t("Standby"      `tor "Stby"  `t)
   Hibernation          `t("Hibernate"    `tor "Hib"   `t)
   LAN-Network          `t("Network"      `tor "Net"   `t)
on your System by means of a tray-icon menu.

--------------------------------------------------------------------------
Defaults
--------------------------------------------------------------------------
There is an internal default setting, determining which functions will
be disabled upon program start.
Current defaults are:
)

Helptext_A2 =
(
where `txxx=0 means: function disabled
`txxx=1 means: function enabled
`txxx=A means: function unaltered (only works for LAN-Network)
You can override these default settings by adding
command-line-parameters upon startup,
)

Helptext_Z =
(
When DONT is closed, all functions will be enabled again.
Exception: LAN-Network status will be left to latest state.
)
if A_IsCompiled
{
Helptext_B =
(
Example:
   %A_ScriptName% Scr=0
   %A_ScriptName% Monitor=1
   %A_ScriptName% Stby=0 Hib=1 Shtdwn=1

--------------------------------------------------------------------------
)
}
else
{
Helptext_B =
(
Example:
   AutoHotkey.exe %A_ScriptName% Scr=0
   AutoHotkey.exe %A_ScriptName% Monitor=1
   AutoHotkey.exe %A_ScriptName% Stby=0 Hib=1 Shtdwn=1

--------------------------------------------------------------------------
)   
}

Helptext := ""
Helptext := Helptext . "`n" Helptext_A
Helptext := Helptext . "`n" defaults
Helptext := Helptext . "`n" Helptext_A2
Helptext := Helptext . "`n" Helptext_B
Helptext := Helptext . "`n" Helptext_Z

;-------------------------------------------------------------------------
; declare/initialize variables:
state_screensave := 0
state_Monitor := 0
state_logoff := 0
state_shutdown := 0
state_standby   := 0
state_suspend   := 0
state_hibernate := 0
state_network   := Netstat_detect()


DllCall("kernel32.dll\SetProcessShutdownParameters", UInt, 0x4FF, UInt, 0)
OnMessage(0x11, "WM_QUERYENDSESSION")
state_logoff := 0
state_shutdown := 0

OnMessage(536, "OnPBMsg")     ;WM_POWERBROADCAST
state_suspend   := 0
state_standby   := 0

OnExit, ScreenSaveActivate
DllCall("SystemParametersInfo", Int,17, Int,0, UInt,NULL, Int,2)
SetTimer, CheckScreenSaveActive, 2000
state_screensave := 0
setScreensaver("false")

SetTimer, NoSleep, 10000
DllCall( "SetThreadExecutionState", UInt,0x80000003 )
state_Monitor := 0


;-------------------------------------------------------------------------
; Create the Menue
Menu, Tray, UseErrorLevel
Menu, Tray, NoStandard
Menu, What_Disable, add, Screensaver, T_Scr
Menu, What_Disable, Uncheck, Screensaver
Menu, What_Disable, add, Monitor-Off, T_Mon
Menu, What_Disable, Uncheck, Monitor-Off
Menu, What_Disable, add, LogOff, T_LgOff
Menu, What_Disable, Uncheck, LogOff
Menu, What_Disable, add, Shutdown, T_Shtdw
Menu, What_Disable, Uncheck, Shutdown
Menu, What_Disable, add, Standby, T_Stby
Menu, What_Disable, Uncheck, Standby
Menu, What_Disable, add, Hibernate, T_Hib
Menu, What_Disable, Uncheck, Hibernate
Menu, What_Disable, add, Network, T_Net
Menu, What_Disable, Uncheck, Network
Menu, Tray, add, Help, ShowHelp
Menu, Tray, add
Menu, tray, add, Enabled Functions, :What_Disable
Menu, Tray, add, Exit, StopThis

OnMessage( 0x404,"AHK_NOTIFYICON" )

; Apply defaults:   
;msgbox, %defaults%
; process internal defaults:
loop,parse,defaults,%A_Space%
{
   ;msgBox, intheLoop {%A_LoopField%} {%A_Index%}
   getDefaults(A_LoopField)
}
; overwrite with command-line-parameter-defaults:
loop, %0%
{
   getDefaults(A_LoopField)
}

Gui +Toolwindow +AlwaysonTop
Gui, Color, White, White
Gui, Add, Edit, t32 t64 t80 readonly -E0x200 -hScroll -vScroll , %Helptext%
Gui, Add, Text, vBlindCtrl
GuiControl, Focus, BlindCtrl

return
;-------------------------------------------------------------------------





;-------------------------------------------------------------------------
; Functions to set desired states

setStatus(val, ByRef state)
{  if (val ==  0) 												; disable
      state := 0	
   if (val ==  1)													; enable
      state := 1
   if (val == -1)													; toggle
			state := abs(state - 1)						
   if ((val == "A") or (val == "a"))			; no change
      state := state                      ; also for all other (non-valid) values
   return
}


T_Scr:
   Tf_Scr(-1)
return
 
Tf_Scr(val)
{
   ;msgBox, entering with={%val%}
   global state_screensave
   setStatus(val, state_screensave)
   ;msgBox, entering newstat={%state_screensave%}
   if (state_screensave)
   {
       setScreensaver("true")
       SetTimer, CheckScreenSaveActive, Off
       DllCall("SystemParametersInfo", Int,17, Int,1, UInt,NULL, Int,2)
       Menu, What_Disable, Check, Screensaver
   }
   else
   {
       DllCall("SystemParametersInfo", Int,17, Int,0, UInt,NULL, Int,2)
       setScreensaver("false")
       SetTimer, CheckScreenSaveActive, 2000
       Menu, What_Disable, Uncheck, Screensaver
   }
   return
}


T_Mon:
   Tf_Mon(-1)
return

Tf_Mon(val)
{
   global state_Monitor
   setStatus(val, state_Monitor)
   if (state_Monitor)
   {
       SetTimer, NoSleep, Off
       DllCall( "SetThreadExecutionState", UInt,0x80000000 )
      Menu, What_Disable, Check, Monitor-Off
   }
   else
   {
       SetTimer, NoSleep, 10000
       DllCall( "SetThreadExecutionState", UInt,0x80000003 )
       Menu, What_Disable, Uncheck, Monitor-Off
   }
   return
}



T_Shtdw:
   Tf_Shtdw(-1)
return

Tf_Shtdw(val) {
   global state_Shutdown
   setStatus(val, state_Shutdown)
   if (state_Shutdown)
   {
      Menu, What_Disable, Check, Shutdown
   }
   else
   {
      Menu, What_Disable, Uncheck, Shutdown
   }
   return
}


T_Hib:
   Tf_Hib(-1)
return

Tf_Hib(val) {
   global state_Hibernate
   setStatus(val, state_Hibernate)
   if (state_Hibernate)
   {
      Menu, What_Disable, Check, Hibernate
   }
   else
   {
      Menu, What_Disable, Uncheck, Hibernate
   }
   return
}

T_Stby:
   Tf_Stby(-1)
return

Tf_Stby(val) {
   global state_standby
   setStatus(val, state_standby)
   if (state_standby)
   {
      Menu, What_Disable, Check, Standby
   }
   else
   {
      Menu, What_Disable, Uncheck, Standby
   }
   return
}

T_LgOff:
   Tf_LgOff(-1)
return

Tf_LgOff(val) {
   global state_logoff
   setStatus(val, state_logoff)
   if (state_logoff)
   {
       Menu, What_Disable, Check, Logoff
   }
   else
   {
       Menu, What_Disable, Uncheck, Logoff
   }
   return
}


T_Net:
   Tf_Net(-1)
return

Tf_Net(val) {
	 global state_network
   setStatus(val, state_network)
   if (state_network)
   {
      run,ipconfig.exe /renew   LAN-Verbindung,,Hide
      Menu, What_Disable, Check, Network
   }
   else
   {
      run,ipconfig.exe /release LAN-Verbindung,,Hide
      Menu, What_Disable, Uncheck, Network
   }
   return
}



;-------------------------------------------------------------------------
; Other Functions

StopThis:
ExitApp
return

ShowHelp:
Gui, Show, , ---DONT---
return

NoSleep:
DllCall( "SetThreadExecutionState", UInt,0x80000003 )
Return

CheckScreenSaveActive:
DllCall("SystemParametersInfo", Int,16, UInt,NULL, "UInt *",SSACTIVE, Int,0)
If SSACTIVE
   DllCall("SystemParametersInfo", Int,17, Int,0, UInt,NULL, Int,2)
Return

ScreenSaveActivate:
DllCall("SystemParametersInfo", Int,17, Int,1, UInt,NULL, Int,2)
ExitApp
Return

ShowMenu:
 Menu, Tray, Show
Return


AHK_NOTIFYICON( wParam, lParam ) {
 If (lParam = 0x202) { ; WM_LBUTTONUP
   SetTimer, ShowMenu, -1
   return 0
 }
}


WM_QUERYENDSESSION(wParam, lParam)
{
   global state_logoff, state_shutdown
   ENDSESSION_LOGOFF = 0x80000000
   if (lParam & ENDSESSION_LOGOFF)  ; User is logging off.
      EventType = logoff
   else  ; System is either shutting down or restarting.
      EventType = shutdown
   if (state_%EventType%)
      return true ; Tell the OS to allow the shutdown/logoff to continue.
   else
      return false
}


OnPBMsg(wParam, lParam, msg, hwnd)
{
   global state_suspend, state_standby
   if (lParam & 1)
   {
      If ((wParam = 0) || (wParam = 4))
      {
         If (state_suspend)
            return true
         else
            return 1112363332
      }
      If ((wParam = 1) || (wParam = 5))
      {
         If (state_standby)
            return true
         else
            return 1112363332
      }
   }
}


setScreensaver(arg)
{
   If arg = true
   {
      ON=1
      RegWrite,Reg_SZ,HKEY_CURRENT_USER,Control Panel\Desktop,ScreenSaveActive,%ON%
      return
   }
   If arg = false
   {
      OFF=0
      RegWrite,Reg_SZ,HKEY_CURRENT_USER,Control Panel\Desktop,ScreenSaveActive,%OFF%
      return
   }
}



;-------------------------------------------------------------------------
; Helper Functions

getDefaults(Item)
{
   foundpos := RegExMatch(Item, "=" , StrFind )
   if (foundpos = 0)
      return
   key := substr(Item, 1, foundpos-1)
   val := substr(Item, foundpos+1)
   ;msgbox, {%key%}={%val%}
   
   Haystack := key
   
   NeedleRegEx := "i)^(Screensaver|Scrsvr|Scr)$"
   foundpos := RegExMatch(Haystack, NeedleRegEx , StrFind )
   if (foundpos > 0)
      Tf_Scr(val)

   NeedleRegEx := "i)^(Monitor|Monitor-off|Mon)$"
   foundpos := RegExMatch(Haystack, NeedleRegEx , StrFind )
   if (foundpos > 0)
      Tf_Mon(val)
      
   NeedleRegEx := "i)^(LogOff|Log)$"
   foundpos := RegExMatch(Haystack, NeedleRegEx , StrFind )
   if (foundpos > 0)
      Tf_LgOff(val)
   
   NeedleRegEx := "i)^(Shutdown|Shtdwn|Off)$"
   foundpos := RegExMatch(Haystack, NeedleRegEx , StrFind )
   if (foundpos > 0)
      Tf_Shtdw(val)
   
   NeedleRegEx := "i)^(Standby|Stndb|Stby)$"
   foundpos := RegExMatch(Haystack, NeedleRegEx , StrFind )
   if (foundpos > 0)
      Tf_Stby(val)
   
   NeedleRegEx := "i)^(Hibernate|Hib|Hbrnt)$"
   foundpos := RegExMatch(Haystack, NeedleRegEx , StrFind )
   if (foundpos > 0)
      Tf_Hib(val)
   
   NeedleRegEx := "i)^(Network|Net|Netw)$"
   foundpos := RegExMatch(Haystack, NeedleRegEx , StrFind )
   if (foundpos > 0)
      Tf_Net(val)
}



; detect current network status
Netstat_detect()
{
   StrOut := StdoutToVar_CreateProcess("ipconfig.exe")
   
   ;1) extract Info for Ethernet-Adapter "LAN-Verbindung":
   Haystack := StrOut
   NeedleRegEx := "Uis)Ethernet-Adapter LAN-Verbindung.*Standardgateway.*`n"    ;ungreedy, case-insensitve, multiline
   foundpos := RegExMatch(Haystack, NeedleRegEx , StrFind )
   ;msgbox, Haystack={%Haystack%}`n`nStrFind={%StrFind%}
   
   ;2) check, if there is an entry in the line "Standardgateway":
   Haystack := StrFind
   NeedleRegEx := "i)Standardgateway\D*\d*\.\d*\.\d*\.\d*"                      ;, case-insensitve, multiline
   foundpos := RegExMatch(StrOut, NeedleRegEx , StrFind )
   ;msgbox, Haystack={%Haystack%}`n`nStrFind={%StrFind%}`n`nFound={%foundpos%}
   if (foundpos > 0)
      Return, 1
   Else   
      Return, 0
}


; this code taken from http://www.autohotkey.com/forum/post-383144.html#383144
StdoutToVar_CreateProcess(sCmd, bStream="", sDir="", sInput="")
    {
   bStream=   ; not implemented
   sDir=      ; not implemented
   sInput=    ; not implemented
   
   DllCall("CreatePipe","Ptr*",hStdInRd
                       ,"Ptr*",hStdInWr
                       ,"Uint",0
                       ,"Uint",0)
   DllCall("CreatePipe","Ptr*",hStdOutRd
                       ,"Ptr*",hStdOutWr
                       ,"Uint",0
                       ,"Uint",0)
   DllCall("SetHandleInformation","Ptr",hStdInRd
                                ,"Uint",1
                                ,"Uint",1)
   DllCall("SetHandleInformation","Ptr",hStdOutWr
                                ,"Uint",1
                                ,"Uint",1)

   if A_PtrSize=4
      {
      VarSetCapacity(pi, 16, 0)
      sisize:=VarSetCapacity(si,68,0)
      NumPut(sisize,    si,  0, "UInt")
      NumPut(0x100,     si, 44, "UInt")
      NumPut(hStdInRd , si, 56, "Ptr")
      NumPut(hStdOutWr, si, 60, "Ptr")
      NumPut(hStdOutWr, si, 64, "Ptr")
      }
   else if A_PtrSize=8
      {
      VarSetCapacity(pi, 24, 0)
      sisize:=VarSetCapacity(si,96,0)
      NumPut(sisize,    si,  0, "UInt")
      NumPut(0x100,     si, 60, "UInt")
      NumPut(hStdInRd , si, 80, "Ptr")
      NumPut(hStdOutWr, si, 88, "Ptr")
      NumPut(hStdOutWr, si, 96, "Ptr")
      }

   DllCall("CreateProcess", "Uint", 0
                           , "Ptr", &sCmd
                          , "Uint", 0
                          , "Uint", 0
                           , "Int", True
                          , "Uint", 0x08000000
                          , "Uint", 0
                          , "Uint", 0
                           , "Ptr", &si
                           , "Ptr", &pi)

   DllCall("CloseHandle","Ptr",NumGet(pi,0))
   DllCall("CloseHandle","Ptr",NumGet(pi,A_PtrSize))
   DllCall("CloseHandle","Ptr",hStdOutWr)
   DllCall("CloseHandle","Ptr",hStdInRd)
   DllCall("CloseHandle","Ptr",hStdInWr)

   VarSetCapacity(sTemp,4095)
   nSize:=0
   loop
      {
      result:=DllCall("Kernel32.dll\ReadFile", "Uint", hStdOutRd
                                             ,  "Ptr", &sTemp
                                             , "Uint", 4095
                                             ,"UintP", nSize
                                              ,"Uint", 0)
      if (result="0")
         break
      else
         sOutput:= sOutput . StrGet(&sTemp,nSize,"CP850")
      }

   DllCall("CloseHandle","Ptr",hStdOutRd)
   Return,sOutput
   }