﻿;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

EndsWith(ByRef long, ByRef short) {
    return short = SubStr(long, -StrLen(short)+1)
}
