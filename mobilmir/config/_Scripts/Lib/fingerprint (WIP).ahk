;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

MsgBox % GetFingerprint()

GetFingerprintText(strComputer:=".") {
    objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")
    
    for path,valArray in GetQueryParameters() {
	for o in objWMIService.ExecQuery("Select " . valArray . " from " . path)
	    Loop Parse, valArray,`,
	    {
		v := Trim(o[A_LoopField])
		If (v)
		    fpl .= ( fpl ? ", " : "" ) . A_LoopField . ": " . v
	    }
	If (fpl)
	    fp .= ( fp ? "`n" : "" ) . path . ": " . fpl
	fpl := ""
	v := ""
    }
    return Trim(fp)
    Exit
}

GetQueryParameters() {
    params := { "Win32_ComputerSystemProduct" : "Name,Vendor,Version,IdentifyingNumber,UUID"
	      , "Win32_BaseBoard" : 		"Manufacturer,Model,Name,OtherIdentifyingInfo,PartNumber,Product,SerialNumber,Version"
	      , "Win32_Processor" : 		"Caption,Manufacturer,Name,ProcessorId,SocketDesignation"
	      , "Win32_NetworkAdapterConfiguration where ""MACAddress is not null""" :	"Caption,IPAddress,MACAddress" }
    return params
}

/*
;https://autohotkey.com/board/topic/60968-wmi-tasks-com-with-ahk-l/
WMI Tasks COM with AHK_L

Some examples from MSDN http://msdn.microsof...5(v=VS.85).aspx.

New users can convert all the MSDN examples given to Native AHK code, I am just giving some examples


CD-ROM drives details:
strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colItems := objWMIService.ExecQuery("Select * from Win32_CDROMDrive")._NewEnum
While colItems[objItem]
    MsgBox % "Device ID: " . objItem.DeviceID 
	. "`nDescription: " . objItem.Description 
	. "`nName: " . objItem.Name
Ping without ping.exe :
strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colPings := objWMIService.ExecQuery("Select * From Win32_PingStatus where Address = 'www.google.com'")._NewEnum ;or ip address like 192.168.1.1

While colPings[objStatus]
{
    If (objStatus.StatusCode="" or objStatus.StatusCode<>0)
        MsgBox Computer did not respond.
    Else
        MsgBox Computer responded.
}
Computer system details:
strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colSettings := objWMIService.ExecQuery("Select * from Win32_ComputerSystem")._NewEnum
Gui, Add, ListView, x0 y0 r45 w400 h500 vMyLV, Attribute|Value
GuiControl, -Redraw, MyLV 

While colSettings[strCSItem]
{
  LV_Add("","AdminPasswordStatus",strCSItem.AdminPasswordStatus )
  LV_Add("","AutomaticResetBootOption",strCSItem.AutomaticResetBootOption )
  LV_Add("","AutomaticResetCapability",strCSItem.AutomaticResetCapability )
  LV_Add("","BootROMSupported",strCSItem.BootROMSupported )
  LV_Add("","BootupState",strCSItem.BootupState )
  LV_Add("","Caption",strCSItem.Caption )
  LV_Add("","ChassisBootupState",strCSItem.ChassisBootupState )
  LV_Add("","CurrentTimeZone",strCSItem.CurrentTimeZone )
  LV_Add("","DaylightInEffect",strCSItem.DaylightInEffect )
  LV_Add("","Description",strCSItem.Description )
  LV_Add("","Domain",strCSItem.Domain )
  LV_Add("","DomainRole",strCSItem.DomainRole )
  LV_Add("","EnableDaylightSavingsTime",strCSItem.EnableDaylightSavingsTime )
  LV_Add("","FrontPanelResetStatus",strCSItem.FrontPanelResetStatus )
  LV_Add("","InfraredSupported",strCSItem.InfraredSupported )
  LV_Add("","KeyboardPasswordStatus",strCSItem.KeyboardPasswordStatus )
  LV_Add("","Manufacturer",strCSItem.Manufacturer )
  LV_Add("","Model",strCSItem.Model )
  LV_Add("","Name",strCSItem.Name )
  LV_Add("","NetworkServerModeEnabled",strCSItem.NetworkServerModeEnabled )
  LV_Add("","NumberOfLogicalProcessors",strCSItem.NumberOfLogicalProcessors )
  LV_Add("","NumberOfProcessors",strCSItem.NumberOfProcessors )
  LV_Add("","OEMStringArray",strCSItem.OEMStringArray )
  LV_Add("","PartOfDomain",strCSItem.PartOfDomain )
  LV_Add("","PauseAfterReset",strCSItem.PauseAfterReset )
  LV_Add("","PowerOnPasswordStatus",strCSItem.PowerOnPasswordStatus )
  LV_Add("","PowerState",strCSItem.PowerState )
  LV_Add("","PowerSupplyState",strCSItem.PowerSupplyState )
  LV_Add("","PrimaryOwnerContact",strCSItem.PrimaryOwnerContact )
  LV_Add("","PrimaryOwnerName",strCSItem.PrimaryOwnerName )
  LV_Add("","ResetCapability",strCSItem.ResetCapability )
  LV_Add("","ResetCount",strCSItem.ResetCount )
  LV_Add("","ResetLimit",strCSItem.ResetLimit )
  LV_Add("","Roles",strCSItem.Roles )
  LV_Add("","Status",strCSItem.Status )
  LV_Add("","SupportContactDescription",strCSItem.SupportContactDescription )
  LV_Add("","SystemStartupDelay",strCSItem.SystemStartupDelay )
  LV_Add("","SystemStartupOptions",strCSItem.SystemStartupOptions )
  LV_Add("","SystemStartupSetting",strCSItem.SystemStartupSetting )
  LV_Add("","SystemType",strCSItem.SystemType )
  LV_Add("","ThermalState",strCSItem.ThermalState )
  LV_Add("","TotalPhysicalMemory",Round(strCSItem.TotalPhysicalMemory/(1024*1024),0) . " MB")
  LV_Add("","UserName",strCSItem.UserName )
  LV_Add("","WakeUpType",strCSItem.WakeUpType )
  LV_Add("","Workgroup",strCSItem.Workgroup )
}  
GuiControl, +Redraw, MyLV 
LV_ModifyCol()
Gui, Show, w400 h500, Computer Details
Return

GuiClose:
ExitApp
Operating system details and free physical memory:
strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colSettings := objWMIService.ExecQuery("Select * from Win32_OperatingSystem")._NewEnum

Gui, Add, ListView, x0 y0 r45 w400 h500 vMyLV, Attribute|Value
GuiControl, -Redraw, MyLV 

While colSettings[objOSItem]
{
  LV_Add("","Build Number" ,objOSItem.BuildNumber )
  LV_Add("","Build Type" ,objOSItem.BuildType )
  LV_Add("","Caption" ,objOSItem.Caption )
  LV_Add("","CountryCode" ,objOSItem.CountryCode )
  LV_Add("","CreationClassName" ,objOSItem.CreationClassName )
  LV_Add("","CSDVersion" ,objOSItem.CSDVersion )
  LV_Add("","CSName" ,objOSItem.CSName )
  LV_Add("","CurrentTimeZone" ,objOSItem.CurrentTimeZone )
  LV_Add("","Distributed" ,objOSItem.Distributed )
  LV_Add("","EncryptionLevel" ,objOSItem.EncryptionLevel )
  LV_Add("","FreePhysicalMemory" ,objOSItem.FreePhysicalMemory )
  LV_Add("","FreeSpaceInPagingFiles" ,objOSItem.FreeSpaceInPagingFiles )
  LV_Add("","FreeVirtualMemory" ,objOSItem.FreeVirtualMemory )
  LV_Add("","InstallDate" ,objOSItem.InstallDate )
  LV_Add("","LargeSystemCache" ,objOSItem.LargeSystemCache )
  LV_Add("","LastBootUpTime" ,objOSItem.LastBootUpTime )
  LV_Add("","LocalDateTime" ,objOSItem.LocalDateTime )
  LV_Add("","Locale" ,objOSItem.Locale )
  LV_Add("","Manufacturer" ,objOSItem.Manufacturer )
  LV_Add("","MaxNumberOfProcesses" ,objOSItem.MaxNumberOfProcesses )
  LV_Add("","MaxProcessMemorySize" ,objOSItem.MaxProcessMemorySize )
  LV_Add("","Name" ,objOSItem.Name )
  LV_Add("","NumberOfLicensedUsers" ,objOSItem.NumberOfLicensedUsers )
  LV_Add("","NumberOfProcesses" ,objOSItem.NumberOfProcesses )
  LV_Add("","NumberOfUsers" ,objOSItem.NumberOfUsers )
  LV_Add("","Organization" ,objOSItem.Organization )
  LV_Add("","OSLanguage" ,objOSItem.OSLanguage )
  LV_Add("","OSType" ,objOSItem.OSType )
  LV_Add("","Primary" ,objOSItem.Primary )
  LV_Add("","ProductType" ,objOSItem.ProductType )
  LV_Add("","RegisteredUser" ,objOSItem.RegisteredUser )
  LV_Add("","SerialNumber" ,objOSItem.SerialNumber )
  LV_Add("","ServicePackMajorVersion" ,objOSItem.ServicePackMajorVersion )
  LV_Add("","ServicePackMinorVersion" ,objOSItem.ServicePackMinorVersion )
  LV_Add("","SizeStoredInPagingFiles" ,objOSItem.SizeStoredInPagingFiles )
  LV_Add("","Status" ,objOSItem.Status )
  LV_Add("","SuiteMask" ,objOSItem.SuiteMask )
  LV_Add("","SystemDevice" ,objOSItem.SystemDevice )
  LV_Add("","SystemDirectory" ,objOSItem.SystemDirectory )
  LV_Add("","SystemDrive" ,objOSItem.SystemDrive )
  LV_Add("","TotalSwapSpaceSize" ,objOSItem.TotalSwapSpaceSize )
  LV_Add("","TotalVirtualMemorySize" ,objOSItem.TotalVirtualMemorySize )
  LV_Add("","TotalVisibleMemorySize" ,objOSItem.TotalVisibleMemorySize )
  LV_Add("","Version" ,objOSItem.Version )
  LV_Add("","WindowsDirectory" ,objOSItem.WindowsDirectory )
}

GuiControl, +Redraw, MyLV 
LV_ModifyCol()
Gui, Show, w400 h500, Operating System Details
Return

GuiClose:
ExitApp
Properties of the mouse used on computer:
strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colItems := objWMIService.ExecQuery("Select * from Win32_PointingDevice")._NewEnum
While colItems[objItem]
    MsgBox % "Description: " . objItem.Description
    . "`nDevice ID: " . objItem.DeviceID
    . "`nDevice Interface: " . objItem.DeviceInterface
    . "`nDouble Speed Threshold: " . objItem.DoubleSpeedThreshold
    . "`nHandedness: " . objItem.Handedness
    . "`nHardware Type: " . objItem.HardwareType
    . "`nINF File Name: " . objItem.InfFileName
    . "`nINF Section: " . objItem.InfSection
    . "`nManufacturer: " . objItem.Manufacturer
    . "`nName: " . objItem.Name
    . "`nNumber Of Buttons: " . objItem.NumberOfButtons
    . "`nPNP Device ID: " . objItem.PNPDeviceID
    . "`nPointing Type: " . objItem.PointingType
    . "`nQuad Speed Threshold: " . objItem.QuadSpeedThreshold
    . "`nResolution: " . objItem.Resolution
    . "`nSample Rate: " . objItem.SampleRate
    . "`nSynch: " . objItem.Synch
List Desktop settings:
strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colItems := objWMIService.ExecQuery("Select * from Win32_Desktop")._NewEnum
While colItems[objItem] 
    MsgBox % "Border Width: " . objItem.BorderWidth 
    . "`nCaption: " . objItem.Caption 
    . "`nCool Switch: " . objItem.CoolSwitch 
    . "`nCursor Blink Rate: " . objItem.CursorBlinkRate 
    . "`nDescription: " . objItem.Description 
    . "`nDrag Full Windows: " . objItem.DragFullWindows 
    . "`nGrid Granularity: " . objItem.GridGranularity 
    . "`nIcon Spacing: " . objItem.IconSpacing 
    . "`nIcon Title Face Name: " . objItem.IconTitleFaceName 
    . "`nIcon Title Size: " . objItem.IconTitleSize 
    . "`nIcon Title Wrap: " . objItem.IconTitleWrap 
    . "`nName: " . objItem.Name 
    . "`nPattern: " . objItem.Pattern 
    . "`nScreen Saver Active: " . objItem.ScreenSaverActive 
    . "`nScreen Saver Executable: " . objItem.ScreenSaverExecutable 
    . "`nScreen Saver Secure: " . objItem.ScreenSaverSecure 
    . "`nScreen Saver Timeout: " . objItem.ScreenSaverTimeout 
    . "`nSetting ID: " . objItem.SettingID 
    . "`nWallpaper: " . objItem.Wallpaper 
    . "`nWallpaper Stretched: " . objItem.WallpaperStretched 
    . "`nWallpaper Tiled: " . objItem.WallpaperTiled
List BIOS details
strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colSettings := objWMIService.ExecQuery("Select * from Win32_BIOS")._NewEnum

While colSettings[objBiosItem]
{
  MsgBox % "BIOSVersion : " . objBiosItem.BIOSVersion 
  . "`nBuildNumber : " . objBiosItem.BuildNumber 
  . "`nCaption : " . objBiosItem.Caption 
  . "`nCurrentLanguage : " . objBiosItem.CurrentLanguage 
  . "`nDescription : " . objBiosItem.Description 
  . "`nInstallableLanguages : " . objBiosItem.InstallableLanguages 
  . "`nInstallDate : " . objBiosItem.InstallDate 
  . "`nListOfLanguages : " . objBiosItem.ListOfLanguages 
  . "`nManufacturer : " . objBiosItem.Manufacturer 
  . "`nName : " . objBiosItem.Name 
  . "`nPrimaryBIOS : " . objBiosItem.PrimaryBIOS 
  . "`nReleaseDate : " . objBiosItem.ReleaseDate 
  . "`nSerialNumber2 : " . objBiosItem.SerialNumber 
  . "`nSMBIOSBIOSVersion : " . objBiosItem.SMBIOSBIOSVersion 
  . "`nSMBIOSMajorVersion : " . objBiosItem.SMBIOSMajorVersion 
  . "`nSMBIOSMinorVersion : " . objBiosItem.SMBIOSMinorVersion 
  . "`nSMBIOSPresent : " . objBiosItem.SMBIOSPresent 
  . "`nSoftwareElementID : " . objBiosItem.SoftwareElementID 
  . "`nSoftwareElementState : " . objBiosItem.SoftwareElementState 
  . "`nStatus : " . objBiosItem.Status 
  . "`nTargetOperatingSystem : " . objBiosItem.TargetOperatingSystem 
  . "`nVersion : " . objBiosItem.Version 
}

*/
