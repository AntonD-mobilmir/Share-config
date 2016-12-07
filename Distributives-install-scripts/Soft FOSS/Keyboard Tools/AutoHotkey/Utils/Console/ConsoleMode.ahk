#SingleInstance, Off
#NoTrayIcon
Compile("Exit")

Description = Toggle Console Mode...

IfNotExist, %1%.PreConsoleMode
 FileCopy, %1%, %1%.PreConsoleMode
RegRead, OutputVar, HKCR, .bin\shell\%Description%\command
If OutputVar <> %A_ScriptDir%\%A_ScriptName% `%1
{
 Msgbox, 4, %Description%, Install to context menu?
 IfMsgBox, Yes
 {
  RegWrite, REG_SZ, HKCR, .bin\shell\%Description%\command,,%A_ScriptDir%\%A_ScriptName% `%1
; Above invalidates NoOpen regkey, so uncomment this to prevent double clicking .bins...
;  RegWrite, REG_SZ, HKCR, .bin\shell\Open\command,,
  MsgBox, 0, %Description%, Installed`, now right click`n`nAutoHotkeySC.bin file...
 }
 Else
  MsgBox, 0, %Description%, Not installed...
 ExitApp -1
}

ifNotExist %1%
{
 MsgBox, 0, %Description%, File not found...
 ExitApp -1
}
file = %1%
if 2 not in ,C,G
 ExitApp -1
mode = %2%

SubSystem := ToggleConsole(file, mode)
Subsystem_ := (Subsystem=3) ? "CONSOLE" : "GUI"
MsgBox,,%Description%, Changed mode to %Subsystem_%.
ExitApp

ToggleConsole(file, mode) {
; Define Win32 constants.
GENERIC_READ  := 0x80000000
GENERIC_WRITE := 0x40000000
OPEN_EXISTING := 0x3
IMAGE_DOS_SIGNATURE := 0x5A4D
IMAGE_NT_SIGNATURE := 0x4550
IMAGE_SIZEOF_FILE_HEADER := 20
IMAGE_SUBSYSTEM_WINDOWS_GUI := 2
IMAGE_SUBSYSTEM_WINDOWS_CUI := 3

; Open file for read/write.
hfile := DllCall("CreateFile", "str", file, "uint", GENERIC_READ|GENERIC_WRITE, "uint", 0, "uint", 0, "uint", OPEN_EXISTING, "uint", 0, "uint", 0)
if hfile = -1
    ErrorExit("CreateFile failed")

; Verify EXE signature.
e_magic := SeekNumRead(hfile, 0, "ushort")
if (e_magic != IMAGE_DOS_SIGNATURE)
    ErrorExit("Bad exe file: no DOS sig")

; Get offset of IMAGE_NT_HEADERS.
e_lfanew := SeekNumRead(hfile, 60, "int")

; Verify NT signature.
ntSignature := SeekNumRead(hfile, e_lfanew, "uint")
if (ntSignature != IMAGE_NT_SIGNATURE)
    ErrorExit("Bad exe file: no NT sig")

; Calculate offset of IMAGE_OPTIONAL_HEADER and its Subsystem field.
offset_optional_header := e_lfanew + 4 + IMAGE_SIZEOF_FILE_HEADER
offset_Subsystem := offset_optional_header + 68

; Read current subsystem.
Subsystem := SeekNumRead(hfile, offset_Subsystem, "UShort")
; Toggle subsystem (do this even if it will be overridden, to validate):
if (Subsystem = IMAGE_SUBSYSTEM_WINDOWS_GUI)
    Subsystem := IMAGE_SUBSYSTEM_WINDOWS_CUI
else if (Subsystem = IMAGE_SUBSYSTEM_WINDOWS_CUI)
    Subsystem := IMAGE_SUBSYSTEM_WINDOWS_GUI
else
    ErrorExit("Bad subsystem: " Subsystem)

; Allow override on command-line:
if mode !=  ; i.e. it is C or G
    Subsystem := IMAGE_SUBSYSTEM_WINDOWS_%mode%UI

; Write new subsystem.
SeekNumWrite(Subsystem, hfile, offset_Subsystem, "UShort")

DllCall("CloseHandle", "uint", hfile)
Return %SubSystem%
}


; SeekNumRead: Seek to absolute offset and read a number of the specified type.
SeekNumRead(hfile, offset, type) {
    Seek(hfile, offset)
    VarSetCapacity(v,8), bytesToRead := NumPut(0,v,0,type)-&v
    if !(DllCall("ReadFile", "uint", hfile, "uint", &v, "uint", bytesToRead, "uint*", bytesRead, "uint", 0) && bytesRead == bytesToRead)
        ErrorExit("Read failed")
    return NumGet(v,0,type)
}

; SeekNumWrite: Seek to absolute offset and write a number of the specified type.
SeekNumWrite(num, hfile, offset, type) {
    Seek(hfile, offset)
    VarSetCapacity(v,8), bytesToWrite := NumPut(num,v,0,type)-&v
    if !(DllCall("WriteFile", "uint", hfile, "uint", &v, "uint", bytesToWrite, "uint*", bytesWritten, "uint", 0) && bytesWritten == bytesToWrite)
        ErrorExit("Write failed")
}

Seek(hfile, offset) {
    static FILE_BEGIN := 0
    if DllCall("SetFilePointer", "uint", hfile, "int", offset, "uint", 0, "uint", FILE_BEGIN) = -1
        ErrorExit("Seek failed")
}

ErrorExit(msg) {
    MsgBox %msg%`n  ErrorLevel=%ErrorLevel% A_LastError=%A_LastError%
    global hfile
    if (hfile != "" && hfile != -1)
        DllCall("CloseHandle", "uint", hfile)
    ExitApp
}