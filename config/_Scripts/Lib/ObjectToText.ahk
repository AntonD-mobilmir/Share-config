;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ObjectToText(ByRef obj) {
    return IsObject(obj) ? ObjectToText_nocheck(obj) : obj
}

ObjectToText_nocheck(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText_nocheck(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}
