@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

    %SystemRoot%\System32\net.exe USER "�����஢����" /Add /FULLNAME:"�����஢���� (��� ��஫�)" /USERCOMMENT:"�室 ��� ��஫� ��� ����㯠 � ᪠����" /passwordchg:no /passwordreq:no || EXIT /B
    %SystemRoot%\System32\wbem\wmic.exe path Win32_UserAccount where Name='�����஢����' set PasswordExpires=false
EXIT /B
)
