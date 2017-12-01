;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ExtractHostnameFromCardName(ByRef cardTitle, ByRef mTVID:="") {
    ;https://support.microsoft.com/en-us/help/909264
    ;NetBIOS names: 1-15 chars, cannot use «\/:*?<>|."» - but \ and / must be screened, and " must be doubled
    ;DNS names allowed chars: only A-Za-z0-9- and unicode
    ;DNS names disallowed chars: «,~:!@#$%^&'.){}_ », first char is alplanum
    
    ;test example: Мин.Воды Танк \\mvtnk-k2 mvtnk@ {AthIIX2 220, 2GB DDR2}
    If (   RegexMatch(cardTitle, "i)(?<!aka)(?<!\\\\)\\\\(?P<Hostname>[a-z\d][a-z\d-]+[k]?[a-z\d])(\s+(.*\s)?(\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\))?|$)", m)
        || RegexMatch(cardTitle, "i)(?<!aka)(?<!\\\\)\\\\(?P<Hostname>[^\\\/:*?<>|.""]{1,15})(\s+(.*\s)?(\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\))?|$)", m)
        || RegexMatch(cardTitle, "i)^(?P<Hostname>[a-z\d][a-z\d-]+[a-z\d])(\s+(.*\s)?(\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\))?|$)", m)
        || RegexMatch(cardTitle, "i)^(?P<Hostname>[^\\\/:*?<>|.""]{1,15})(\s+(.*\s)?(\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\))?|$)", m)
        || RegexMatch(cardTitle, "i)^(?P<Hostname>[^\\\/:*?<>|.""]+)(\s.*)?$", m) )
	return mHostname
    mTVID=
    return
}
