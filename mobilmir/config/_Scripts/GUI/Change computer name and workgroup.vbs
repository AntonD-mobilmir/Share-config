'---Start of UAC workaround code
If WScript.Arguments.length =0 Then
  Set objShell = CreateObject("Shell.Application")
  objShell.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34) & " uac", "", "runas", 1
Else
	'---End UAC part one
	'---start computername change---
	Set objNetwork = CreateObject("WScript.Network")
	Set objShell = CreateObject("WScript.Shell")
	strComputer = objNetwork.ComputerName
	
	strNewName = InputBox("Enter new computer name: ", "Computer name changer", strComputer)
	
	Set objComputer = GetObject("winmgmts:{impersonationLevel=Impersonate}!\\.\root\cimv2:Win32_ComputerSystem.Name='" & strComputer & "'")
	
	If Vartype(strNewName) = 0 Or strNewName = strComputer Then
		MsgBox "Cancelled." & vbCrLf & vbCrLf & "Computer name will remain as: " & strComputer, vbInformation, "Cancelled by user"
	Else
		MsgBox "About to rename computer to: " & strNewName
		ErrCode = objComputer.Rename(strNewName)
		If ErrCode = 0 Then
			MsgBox "Computer renamed correctly and will change after reboot.", vbInformation, "Success!"
		Else
			MsgBox "Eror changing computer name. Error code: " & ErrCode, vbInformation, "Error!"
		End If
	End If
	'---end computername change---
	
	'---start workgroup rename---
	
	Set objNetwork = CreateObject("WScript.Network")
	strComputer = objNetwork.ComputerName
	Set objComputer = GetObject("winmgmts:{impersonationLevel=Impersonate}!\\.\root\cimv2:Win32_ComputerSystem.Name='" & strComputer & "'")
	strDomain = objComputer.Domain
	Set objShell = CreateObject("WScript.shell")
	
	strNewWorkgroup = InputBox("Enter new Workgroup name: ","Workgrup name changer", strDomain)
	
	If Vartype(strNewWorkgroup) = 0 Or strNewWorkgroup = strDomain Then
		MsgBox "Cancelled." & vbCrLf & vbCrLf & "Workgroup name will remain as: " & strDomain, vbInformation, "Cancelled by user"
	Else
		MsgBox "About to rename workgroup to: " & strNewWorkgroup
		ErrCode = objComputer.JoinDomainOrWorkGroup(strNewWorkgroup)
		If ErrCode = 0 Then
			MsgBox "Workgroup renamed correctly and will change after reboot.", vbInformation, "Success!"
		Else
			MsgBox "Eror changing Workgroup name. Error code: " & ErrCode, vbInformation, "Error!"
			'---end workgroup rename---
		End If
	End If
	
	'---end workgroup rename---
	'---start reboot---
	intResponse = MsgBox("Do you want to reboot now?", vbYesNo, "Reboot")
	If intResponse = vbYes Then
		Set objShell = wscript.CreateObject("wscript.shell")
		objShell.Run "shutdown.exe /R /T 5 /C ""Rebooting your computer now!"" "
	End If
	'---End of UAC workaround code	
End If
