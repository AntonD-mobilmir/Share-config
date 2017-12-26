;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

LessAnnoyingAttentionDrawer(ByRef SubText, ByRef MainText, ByRef WinTitle, ByRef сallbackWaitLoop := "") {
    Progress zh0 M, %SubText%, %MainText%, %WinTitle%
    lastHotkeyTime := A_TickCount
    Loop
	Sleep 250
    Until A_TimeIdlePhysical > 500 ; ожидание простоя
    Loop
	Sleep 200
    Until A_TimeIdlePhysical < 200 ; ожидание любого действия пользователя

    While (IsFunc(сallbackWaitLoop) ? Func(сallbackWaitLoop).Call() : (A_TickCount - lastHotkeyTime) < 1000) ; в течение 1 с после нажатия клавиши, можно нажать ещё раз
	Sleep 200
    Progress Off
}

GuiEscape:
GuiClose:
    Sleep 200
    ExitApp
