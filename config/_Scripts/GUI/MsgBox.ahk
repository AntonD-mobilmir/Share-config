#NoEnv

If (A_Args.Length() < 2) {
    MsgBox %1%
} Else {
    ;MsgBox [, Options, Title, Text, Timeout]
    ;Options:
    ;OK (that is, only an OK button is displayed) 0 0x0 
    ;OK/Cancel 1 0x1 
    ;Abort/Retry/Ignore 2 0x2 
    ;Yes/No/Cancel 3 0x3 
    ;Yes/No 4 0x4 
    ;Retry/Cancel 5 0x5 
    ;Cancel/Try Again/Continue 6 0x6 
    ;Makes the 2nd button the default 256 0x100 
    ;Makes the 3rd button the default 512 0x200 

    ;Icon Hand (stop/error) 16 0x10 
    ;Icon Question 32 0x20 
    ;Icon Exclamation 48 0x30 
    ;Icon Asterisk (info) 64 0x40 

    ;Makes the 2nd button the default 256 0x100 
    ;Makes the 3rd button the default 512 0x200 

    MsgBox % A_Args[1], %2%, %3%, %4%
    IfMsgBox OK
        Exit 100
    IfMsgBox Yes
        Exit 101
    IfMsgBox Retry
        Exit 102
    IfMsgBox Continue
        Exit 103
    IfMsgBox TryAgain
        Exit 104
    IfMsgBox Cancel
        Exit 200
    IfMsgBox No
        Exit 201
    IfMsgBox Abort
        Exit 202
    IfMsgBox Ignore
        Exit 203
    IfMsgBox Timeout
        Exit 300
}
