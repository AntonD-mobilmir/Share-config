;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

Find_LO_program_dir() {
    static dirsProgFiles
    ;ToDo: also look in
    ;HKEY_CLASSES_ROOT\ [vnd.libreoffice.command, LibreOffice.*, soffice.*, office.Extension.1]
    ;\[shell\open\command, DefaultIcon]
    
    If (!IsObject(dirsProgFiles)) {
	;dirsProgFiles := [ A_ProgramFiles ]
        dirsProgFiles := []
	For i, nameEnvVar in ["ProgramFiles(x86)", "ProgramFiles", "ProgramW6432"] {
            EnvGet path, %nameEnvVar%
            If (path)
                dirsProgFiles.Push(path)
	}
    }
    
    For i, lProgramFiles in dirsProgFiles
        For j, mask in [ "LibreOffice", "LibreOffice *" ]
            Loop Files, %lProgramFiles%\%mask%, D
                If (FileExist((dir_LO_program := A_LoopFileFullPath "\program") "\soffice.bin"))
                    return dir_LO_program
    return
}

If (A_LineFile == A_ScriptFullPath) {
    FileAppend % Find_LO_program_dir() "`n", *, CP1
}
