;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

WMIGetUserFullname(ByRef ParsedParts := "") {
    ; If ParsedParts=2, parse full name as "Surname Patronym GivenName" and return "GivenName Surname"
    ;   also returns actual number of words in user's full name
    ;https://autohotkey.com/board/topic/60968-wmi-tasks-com-with-ahk-l/
    strComputer:="."
    objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")
    ;For o in objWMIService.ExecQuery("Select Model,InterfaceType,SerialNumber From Win32_DiskDrive where InterfaceType<>'USB'")
	;MsgBox % o.Model
    For o in objWMIService.ExecQuery("Select FullName From Win32_UserAccount where Name='" A_UserName "'")
	winUserFullName := o.FullName
    objWMIService :=
    
    If (winUserFullName) {
        If (ParsedParts == 2) {
            StringSplit sFIOpt, winUserFullName, %A_Space%
            If (IsByRef ParsedParts)
                ParsedOnly := sFIOpt0
            If (sFIOpt0 == 3) ; Фамилия Имя Отчество
                return sFIOpt2 " " sFIOpt1
        }
        return winUserFullName
    }
}
