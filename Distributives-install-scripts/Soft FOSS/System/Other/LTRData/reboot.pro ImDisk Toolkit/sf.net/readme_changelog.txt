Version 20161105
- RamDiskUI.exe: ramdisks are now created at startup even if the source to load content does not exist
- installer: switched back to the original method of shortcut creation
- executables are now compiled with MinGW 6.2.0 (instead of 5.3.0)

Version 20161025
- RamDiskUI.exe: changed the tests and message for the warning about the Windows fast startup feature
- SFX modules: if the %TEMP% folder is invalid, the current folder is now used to extract the files

Version 20161021
- ImDiskTk-svc.exe: UNC paths can now be used for ramdisk synchronization at shutdown (remote machines may still be unreachable though)
- fix in the installer/uninstaller: parameters used by the driver to mount files at startup were not saved if the user wanted to keep them

Version 20161017
- MountImg.exe: added an option to mount the image file at system startup
- ImDisk-Dlg.exe: added support for mount points
- fix in MountImg.exe x64: on Windows 8 and later, the drag and drop could fail if the file is dragged from a 32-bit application
- fix in RamDiskUI.exe: Temp folder was not created for ramdisks that have just been created on mount point
- fix in RamDiskUI.exe: the workaround for non visible drive letters in Explorer fails since 20160726 and never worked for other drive letters than R:
- various minor fixes

Version 20161005
- fix in RamDiskUI.exe: synchronization options were not properly registered (regression introduced in 20160202)

Version 20160917
- added support of NTFS compression
- fix: data synchronization at system shutdown could not working if another ramdisk was defined

Version 20160908
- new full 64-bit version
- new 7-Zip SFX modules for the installation packages with improved security
- removed support for Itanium CPUs
- installer: added a choice in case of installation in another directory
- installer: changed method of shortcut creation
- installer: renamed setup.exe to config.exe in order to avoid the Installer Detection of Windows

Version 20160729
- MountImg.exe: a right-click on "Switch to Driver Interface" now displays the main interface of imdisk.cpl
- updated spanish translation

Version 20160726
- dynamic ramdisks: TRIM commands can now replace the cleanup function for releasing the unused memory blocks
- fix: data synchronization at system shutdown was not working for dynamic ramdisks that just have been created
- executables now explicitly support DEP and ASLR

Version 20160202
- updated to driver 2.0.9
- added russian language
- RamDiskUI.exe: added a warning message for issues related to the fast startup feature of Windows
- RamDiskUI.exe: improved tooltips
- fix in General Settings panel: "Restore hidden dialog boxes" button was not working
- fix in ImDisk-Dlg.exe: two buttons were not translated
- executables are now compiled with MinGW 5.3.0 (instead of 4.7.4)