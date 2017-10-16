@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET src=R:\
SET dst=Q:\
SET exclusions=/XJ /XF *.!qB *.~* ~* /XD "System Volume Information" "$RECYCLE.BIN" "Recovery" "Temp"
SET commonOpt=/SL /TEE /ZB /EFSRAW /COPY:DATSO /DCOPY:DAT /R:1 /NP
rem без /NP, пишет проценты в лог :(
rem /ETA неинтерактивный. Пишет перед началом, и всё.
SET /A unbuffSize=64*1024*1024
SET "log=R:\%~n0.log"
)
(
MOVE /Y "%log%" "%log%.bak"
%SystemRoot%\System32\robocopy.exe %src% %dst% %exclusions% %commonOpt% /MIN:%unbuffSize% /J /E /M /UNILOG+:"%log%"
%SystemRoot%\System32\robocopy.exe %src% %dst% %exclusions% %commonOpt% /E /M /UNILOG+:"%log%"
%SystemRoot%\System32\robocopy.exe %src% %dst% %exclusions% %commonOpt% /MIR /UNILOG+:"%log%"
EXIT /B
)


rem -------------------------------------------------------------------------------
rem    ROBOCOPY     ::     Robust File Copy for Windows                              
rem -------------------------------------------------------------------------------

rem   Started : 2 октября 2017 г. 10:51:43
rem               Usage :: ROBOCOPY source destination [file [file]...] [options]

rem              source :: Source Directory (drive:\path or \\server\share\path).
rem         destination :: Destination Dir  (drive:\path or \\server\share\path).
rem                file :: File(s) to copy  (names/wildcards: default is "*.*").

rem ::
rem :: Copy options :
rem ::
rem                  /S :: copy Subdirectories, but not empty ones.
rem                  /E :: copy subdirectories, including Empty ones.
rem              /LEV:n :: only copy the top n LEVels of the source directory tree.

rem                  /Z :: copy files in restartable mode.
rem                  /B :: copy files in Backup mode.
rem                 /ZB :: use restartable mode; if access denied use Backup mode.
rem                  /J :: copy using unbuffered I/O (recommended for large files).
rem             /EFSRAW :: copy all encrypted files in EFS RAW mode.

rem   /COPY:copyflag[s] :: what to COPY for files (default is /COPY:DAT).
rem                        (copyflags : D=Data, A=Attributes, T=Timestamps).
rem                        (S=Security=NTFS ACLs, O=Owner info, U=aUditing info).

 
rem                /SEC :: copy files with SECurity (equivalent to /COPY:DATS).
rem            /COPYALL :: COPY ALL file info (equivalent to /COPY:DATSOU).
rem             /NOCOPY :: COPY NO file info (useful with /PURGE).
rem             /SECFIX :: FIX file SECurity on all files, even skipped files.
rem             /TIMFIX :: FIX file TIMes on all files, even skipped files.

rem              /PURGE :: delete dest files/dirs that no longer exist in source.
rem                /MIR :: MIRror a directory tree (equivalent to /E plus /PURGE).

rem                /MOV :: MOVe files (delete from source after copying).
rem               /MOVE :: MOVE files AND dirs (delete from source after copying).

rem      /A+:[RASHCNET] :: add the given Attributes to copied files.
rem      /A-:[RASHCNET] :: remove the given Attributes from copied files.

rem             /CREATE :: CREATE directory tree and zero-length files only.
rem                /FAT :: create destination files using 8.3 FAT file names only.
rem                /256 :: turn off very long path (> 256 characters) support.

rem              /MON:n :: MONitor source; run again when more than n changes seen.
rem              /MOT:m :: MOnitor source; run again in m minutes Time, if changed.

rem       /RH:hhmm-hhmm :: Run Hours - times when new copies may be started.
rem                 /PF :: check run hours on a Per File (not per pass) basis.

rem              /IPG:n :: Inter-Packet Gap (ms), to free bandwidth on slow lines.

rem                 /SL :: copy symbolic links versus the target.

rem             /MT[:n] :: Do multi-threaded copies with n threads (default 8).
rem                        n must be at least 1 and not greater than 128.
rem                        This option is incompatible with the /IPG and /EFSRAW options.
rem                        Redirect output using /LOG option for better performance

rem  /DCOPY:copyflag[s] :: what to COPY for directories (default is /DCOPY:DA).
rem                        (copyflags : D=Data, A=Attributes, T=Timestamps).

rem            /NODCOPY :: COPY NO directory info (by default /DCOPY:DA is done).

rem          /NOOFFLOAD :: copy files without using the Windows Copy Offload mechanism.

rem ::
rem :: File Selection Options :
rem ::
rem                  /A :: copy only files with the Archive attribute set.
rem                  /M :: copy only files with the Archive attribute and reset it.
rem     /IA:[RASHCNETO] :: Include only files with any of the given Attributes set.
rem     /XA:[RASHCNETO] :: eXclude files with any of the given Attributes set.

rem  /XF file [file]... :: eXclude Files matching given names/paths/wildcards.
rem  /XD dirs [dirs]... :: eXclude Directories matching given names/paths.

rem                 /XC :: eXclude Changed files.
rem                 /XN :: eXclude Newer files.
rem                 /XO :: eXclude Older files.
rem                 /XX :: eXclude eXtra files and directories.
rem                 /XL :: eXclude Lonely files and directories.
rem                 /IS :: Include Same files.
rem                 /IT :: Include Tweaked files.

rem              /MAX:n :: MAXimum file size - exclude files bigger than n bytes.
rem              /MIN:n :: MINimum file size - exclude files smaller than n bytes.

rem           /MAXAGE:n :: MAXimum file AGE - exclude files older than n days/date.
rem           /MINAGE:n :: MINimum file AGE - exclude files newer than n days/date.
rem           /MAXLAD:n :: MAXimum Last Access Date - exclude files unused since n.
rem           /MINLAD:n :: MINimum Last Access Date - exclude files used since n.
rem                        (If n < 1900 then n = n days, else n = YYYYMMDD date).

rem                 /XJ :: eXclude Junction points. (normally included by default).

rem                /FFT :: assume FAT File Times (2-second granularity).
rem                /DST :: compensate for one-hour DST time differences.

rem                /XJD :: eXclude Junction points for Directories.
rem                /XJF :: eXclude Junction points for Files.

rem ::
rem :: Retry Options :
rem ::
rem                /R:n :: number of Retries on failed copies: default 1 million.
rem                /W:n :: Wait time between retries: default is 30 seconds.

rem                /REG :: Save /R:n and /W:n in the Registry as default settings.

rem                /TBD :: wait for sharenames To Be Defined (retry error 67).

rem ::
rem :: Logging Options :
rem ::
rem                  /L :: List only - don't copy, timestamp or delete any files.
rem                  /X :: report all eXtra files, not just those selected.
rem                  /V :: produce Verbose output, showing skipped files.
rem                 /TS :: include source file Time Stamps in the output.
rem                 /FP :: include Full Pathname of files in the output.
rem              /BYTES :: Print sizes as bytes.

rem                 /NS :: No Size - don't log file sizes.
rem                 /NC :: No Class - don't log file classes.
rem                /NFL :: No File List - don't log file names.
rem                /NDL :: No Directory List - don't log directory names.

rem                 /NP :: No Progress - don't display percentage copied.
rem                /ETA :: show Estimated Time of Arrival of copied files.

rem           /LOG:file :: output status to LOG file (overwrite existing log).
rem          /LOG+:file :: output status to LOG file (append to existing log).

rem        /UNILOG:file :: output status to LOG file as UNICODE (overwrite existing log).
rem       /UNILOG+:file :: output status to LOG file as UNICODE (append to existing log).

rem                /TEE :: output to console window, as well as the log file.

rem                /NJH :: No Job Header.
rem                /NJS :: No Job Summary.

rem            /UNICODE :: output status as UNICODE.

rem ::
rem :: Job Options :
rem ::
rem        /JOB:jobname :: take parameters from the named JOB file.
rem       /SAVE:jobname :: SAVE parameters to the named job file
rem               /QUIT :: QUIT after processing command line (to view parameters). 
rem               /NOSD :: NO Source Directory is specified.
rem               /NODD :: NO Destination Directory is specified.
rem                 /IF :: Include the following Files.

rem ::
rem :: Remarks :
rem ::
rem        Using /PURGE or /MIR on the root directory of the volume will 
rem        cause robocopy to apply the requested operation on files inside 
rem        the System Volume Information directory as well. If this is not 
rem        intended then the /XD switch may be used to instruct robocopy 
rem        to skip that directory.
