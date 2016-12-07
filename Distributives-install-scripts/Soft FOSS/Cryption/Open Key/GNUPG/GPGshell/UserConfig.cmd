IF NOT DEFINED APPDATA (
    "%SystemDrive%\SysUtils\ResKit\setx.exe" APPDATA "~USERPROFILE~\Application Data"
    SET APPDATA=%USERPROFILE%\Application Data
)

REG ADD "HKEY_CURRENT_USER\Software\VB and VBA Program Settings\GPGshell"
REG ADD "HKEY_CURRENT_USER\Software\VB and VBA Program Settings\GPGshell\GPGkeys" /v "AskedForNewKey" /d "1" /f
REG ADD "HKEY_CURRENT_USER\Software\VB and VBA Program Settings\GPGshell\Settings" /v "Language" /d "Russian" /f
REG ADD "HKEY_CURRENT_USER\Software\VB and VBA Program Settings\GPGshell\Settings" /v "ShellHomeDir" /d "%APPDATA%\gnupg" /f
REG ADD "HKEY_CURRENT_USER\Software\VB and VBA Program Settings\GPGshell\Settings" /v "SetGnuPGHome" /d "0" /f
REG ADD "HKEY_CURRENT_USER\Software\VB and VBA Program Settings\GPGshell\Settings" /v "UsePgpDump" /d "0" /f
