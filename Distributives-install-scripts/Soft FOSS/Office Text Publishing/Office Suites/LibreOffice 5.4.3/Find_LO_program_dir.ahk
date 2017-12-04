;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

Find_LO_program_dir() {

    ;ToDo: also look in
    ;HKEY_CLASSES_ROOT\ [vnd.libreoffice.command, LibreOffice.*, soffice.*, office.Extension.1]
    ;\[shell\open\command, DefaultIcon]

    If (!ProgramFiles_x86)
	EnvGet ProgramFiles_x86,ProgramFiles(x86)
    For i, lProgramFiles in [ ProgramFiles_x86, A_ProgramFiles]
	Loop Files, %lProgramFiles%\LibreOffice *, D
	    If !FileExist((dir_LO_program := A_LoopFileFullPath "\program") "\soffice.bin")
		dir_LO_program=
    return dir_LO_program
}

If (A_LineFile == A_ScriptFullPath) {
    FileAppend % Find_LO_program_dir() "`n", *, CP1
}
