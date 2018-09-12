;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; https://superuser.com/a/1289407
;// CoCreateInstance(CLSID_FhConfigMgr, NULL, CLSCTX_INPROC_SERVER, IID_IFhConfigMgr, &fh)
;newslot native fhPtr
;call ole32.dll!CoCreateInstance /return uint (blockptr(guid {ED43BB3C-09E9-498a-9DF6-2177244C6DB4}), nullptr, int 1, blockptr(guid {6A5FEA5B-BF8F-4EE5-B8C3-44D8A0D7331C}), slotptr fhPtr)
;newslot native fh
;copyslot fh = fhPtr dereferenced
;newslot block vtbl = nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr
;copyslot vtbl = fh dereferenced

;// fh->CreateDefaultConfiguration(TRUE)
;newslot native createDefaultConfiguration
;copyslot createDefaultConfiguration = vtbl field 4
;call funcat createDefaultConfiguration /call thiscall /return uint (slotdata fhPtr, int 1)

MsgBox % "LoadConfiguration → " FhConfigMgr("LoadConfiguration")
MsgBox % "CreateDefaultConfiguration → " FhConfigMgr("CreateDefaultConfiguration", "Int", TRUE)

;// fh->ProvisionAndSetNewTarget("\\localhost\FileHistory$\", "Local Disk")
;newslot native provisionAndSetNewTarget
;copyslot provisionAndSetNewTarget = vtbl field 14
;call funcat provisionAndSetNewTarget /call thiscall /return uint (slotdata fhPtr, bstr "\\\\localhost\\FileHistory$\\", bstr "Local Disk")

;// fh->SetLocalPolicy(FH_RETENTION_TYPE, FH_RETENTION_UNLIMITED)
;newslot native setLocalPolicy
;copyslot setLocalPolicy = vtbl field 9
;call funcat setLocalPolicy /call thiscall /return uint (slotdata fhPtr, int 1, int 1)

;// fh->SetBackupStatus(FH_STATUS_ENABLED)
;newslot native setBackupStatus
;copyslot setBackupStatus = vtbl field 11
;call funcat setBackupStatus /call thiscall /return uint (slotdata fhPtr, int 2)

;// fh->SaveConfiguration()
;newslot native saveConfiguration
;copyslot saveConfiguration = vtbl field 5
;call funcat saveConfiguration /call thiscall /return uint (slotdata fhPtr)

;// FhServiceOpenPipe(TRUE, &fhPipe)
;newslot native fhPipe
;call fhsvcctl.dll!FhServiceOpenPipe /return int (int 1, slotptr fhPipe)

;// FhServiceReloadConfiguration(fhPipe)
;call fhsvcctl.dll!FhServiceReloadConfiguration /return int (slotdata fhPipe)

;// FhServiceClosePipe(fhPipe)
;call fhsvcctl.dll!FhServiceClosePipe /return int (slotdata fhPipe)

FhConfigMgr()
ExitApp

FhConfigMgr(ByRef fn := "", args*) { ; https://technet.microsoft.com/ru-ru/hh829807?f=255&MSPPError=-2147217396#methods
    static CLSID_IFhConfigMgr := "{6A5FEA5B-BF8F-4EE5-B8C3-44D8A0D7331C}"
         , CLSID_FhConfigMgr := "{ED43BB3C-09E9-498a-9DF6-2177244C6DB4}"
         , tbl := ""
                ;    IUnknown:
                ;      0 QueryInterface  -- use ComObjQuery instead
                ;      1 AddRef          -- use ObjAddRef instead
                ;      2 Release         -- use ObjRelease instead
                ; rest @ https://github.com/tpn/winsdk-10/blob/master/Include/10.0.10240.0/um/FhCfg.h
         , fnMap := { LoadConfiguration: 3
                    , CreateDefaultConfiguration: 4
                    , saveConfiguration: 5
                    , AddRemoveExcludeRule: 6
                    , GetIncludeExcludeRules: 7
                    , GetLocalPolicy: 8
                    , SetLocalPolicy: 9
                    , GetBackupStatus: 10
                    , SetBackupStatus: 11
                    , GetDefaultTarget: 12
                    , ValidateTarget: 13
                    , ProvisionAndSetNewTarget: 14
                    , ChangeDefaultTargetRecommendation: 15
                    , QueryProtectionStatus: 16 }

    If (tbl=="")
        tbl := ComObjCreate(CLSID_FhConfigMgr, CLSID_IFhConfigMgr)
    If (fn=="")
        return ObjRelease(tbl)
    Else
        return DllCall(vtable(tbl, fnMap[fn]), args*)
}

vtable(ptr, n) { ;example from ahk help
    ; NumGet(ptr+0) returns the address of the object's virtual function
    ; table (vtable for short). The remainder of the expression retrieves
    ; the address of the nth function's address from the vtable.
    return NumGet(NumGet(ptr+0), n*A_PtrSize)
}
