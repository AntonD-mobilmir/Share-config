;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

GetDeptID() {
    PostConfigDir=%ShopBTSdir%\ExtForms\post
    Try deptID := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_SharedMailUserId.cmd", "MailUserId")
    If (!deptID && FileExist ) {
	FileReadLine deptID, %PostConfigDir%\sendemail.cfg, 1
	deptID := RegexReplace(deptID, "@k\.mobilmir\.ru$")
    }
    
    return deptID
}

#include %A_LineFile%\..\ReadSetVarFromBatchFile.ahk
