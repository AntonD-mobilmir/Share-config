Version 20170706
- RamDiskUI.exe: added a tooltip about the creation of other folders than Temp
- fix in RamDiskUI.exe: ImDiskTk-svc service was not created if the system is shut down without closing the GUI (regression introduced in 20160726)

Version 20170407
- fix: missing error handling for process creation could lead to unpredictable results

Version 20161231
- fix in RamDyn.exe: a bug occured with volumes larger than 4 GB (regression introduced in 20161230)

Version 20161230
- RamDyn.exe: fixed a mistake in the syntax help (since 20161120)
- added a shortcut to the homepage in the start menu
- SFX modules: added version number

Version 20161204
- service start type is no longer enforced if the service already exists

Version 20161120
- RamDyn.exe: improved cleanup function (Security Margin parameter removed)