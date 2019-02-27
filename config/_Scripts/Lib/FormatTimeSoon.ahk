;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

FormatTimeSoon(amount, unit := "Minutes", format := "Time") {
    timeoutMsgVal := ""
    timeoutMsgVal += %amount%, %unit%
    FormatTime timeoutMsgText, %timeoutMsgVal%, %format%
    return timeoutMsgText
}
