03/31/2010
This is the readme file for UUD32Win V2.40, which contains an overview and 
installation notes.

Overview
--------
UUD32Win is a multipart MIME Base64, MIME Quoted-Printable, UUEncode, XXEncode,
Binhex4, BNews & yEncode decoder, with an easy to use interface. These message 
formats are commonly used to send data through Email and the Internet.

UUD32Win supports single or multiple files. It handles corrupted or incomplete
headers commonly found in non-MIME aware mail programs. It has provisions for
dealing with indented messages and recursively encoded messages.  It can also 
identify many file types by data alone, and provide the proper file extension. 
There is no need to strip message headers or otherwise format the data that
goes in to UUD32Win.

This is a Windows 32bit program that is compatible with all Win32 platforms
from Win95 to WinME, NT4.0 to Windows Vista.

UUD32Win uses a simple Windows style interface, giving you two lists to work
with, a list of input files, and a list of decoded output files. You may input
data via File Open, Drag & Drop, Clipboard Paste, Command Line arguments, or
DDE. Output filenames are automatically detected from the input files. Output
files are color coded to show you at a glance the status of the decoded file.
Once processed, files may be extracted individually, all at once, or you may
double-click on the file to launch the associated application. This is handy 
when processing many messages saved from USENET newsgroups.

Installation
------------
After running uud32inst.exe to install the application, or extracting the zip 
archive, you may want to set the file association in the preferences dialog 
found under the options menu. The sample file "multtest.b64" is a valid Base64 
encoded file that fails to decode properly with many other decoder programs. 

Portable Use
------------
A portable application is one that does not modify windows settings or registry
entries when run. UUD32Win will operate in this mode when the application name 
contains 'PE' such as "UUD32PE.EXE". When running in 'PE' mode, settings are 
stored in a uudwin.ini file located in the same folder as the application 
if it is writable, otherwise it will default to the user's 'application data' 
folder. Note, if you change the file associations checkboxes in preferences 
UUD32Win will make changes to the windows registry in order to satisfy your request.
A uudwin.ini located in the application folder is chosen over any other if it
is writeable, regardless of uud32win's application name.


Recent Changes
--------------
V2.40 2010/03/31
- Fix bug in rename pattern generation
- Created new Extract dialog based on Windows FileSave Dialog, which is a lot faster for 
  systems with thousands of files in folders.
- Suppress redraw when updating filenames in output list after rename, finishes much quicker
- Add option to not always pick last (n/n) in subject for part number. Rework part # detection
- Allow .db as an extension in same file type detector as MSApp .xls, .doc etc.
- Missing-start yEnc files shown in gray(missing start) instead of blue(incomplete)

V2.38 2009/01/25
- Added additional command-line parameters /report=<file> /listdump=<file> for use
  with /extract command

V2.36 2009/01/10
- Restore your last view type (details/list/icon etc.) in File Open dialog
- Add parameters to "Rename from Subject" to allow renaming by author, time, date, etc.
- Return error code when decode fails and app exits
- Add par2 filetype detection
- fix lost subjects when scanning filenames wrapped in quotes
- fix corrupted UU extract picking up non-uudata
- show UAC to launch executables when normally blocked by Vista
- other minor fixes


2007/12/01
- don't confuse "day # of #" for part numbers in subject
 
V2.35 2007/10/12
- Support local .ini file for portable use. (Won't work for /program files/ folder
  in Vista). 
- Read .lnk files, and allow directories to be dropped/or added via cmdline
- Decodes Usenet FACE: header in addition to X-Face:
- Bug fixes including correct naming of mulitipart files & elimination of partial
  pieces when output filenames are duplicates, but are from different sources.
  Better wildcard pattern generation in rename. No longer mishandles varying length
  filenames and extensions.
- Added HTML help & popup help.

2007/06/26
- Allow decode of very short B64 files, fix message/partial decoding

-V2.34  2007/03/14
- Correct endless loop processing files ending with multiple <CR>

-V2.33
- Correct duplicate file renaming, erroneously tied to "You choose duplicate part" option.

-V2.32
- Save Temp path in Preferences dialog
- Limit subject-named text files to 100 chars
- Correct filenames exceeding MAX_PATH length during extract.
- Correct /outdir=* extraction for files in current working dir (no longer write to root of disk)

-V2.31
- New resizeable extract dialog with faster browser tree fill (no more NT3.51)
- Corrected problems with duplicate files when "disable duplicate file renaming" is checked.
- Fixes for Vista usermode registry access
 
-V2.30
- yEnc now can match parts on total file size if filenames match
- yEnc can now fill in part number & total parts if missing from header (Fix ZoneAlarm corruption)
- yEnc strict decoding allows merging parts, leaving gaps in output
- Moved .INI file to user's Application Data\UUD32Win folder 
- New "Rename from subject" tool
- Filetype detection enable/disable

-V2.20
- Correct decode of mutipart yenc files with CRC32 in each part. (bug introduced
  in previous build)

-V2.19
- Correct decoding of multipart multifile yEnc data
- Fix error in wildcard renaming
- Add disable auto-rename advanced preference
- Add message date to message.txt files when present
- Other minor decoding fixes

-V2.16
- Correct minor bug which sometimes caused UU encoding detection to fail

-V2.15
- Increased filename buffer to allow many thousands of input
  files to be selected in the file open dialog.
- Fixed CTRL-DEL of multipart yEnc files
- Fixed binhex decode problem

- V2.14
- Added strict yEnc decode option
- Many changes related to duplicate parts
- Fixed decode errors for some text & quoted-printable formats
- Corrected GPF during monitored stream decode operations
- Compiled for speed, which increased EXE size slightly

- V2.13
- Fixed erroneous duplicate part when monitoring file
- Fixed bug that causes long rescan of file when monitoring
- Fixed grouping problem when force 8.3 filename selected
- other minor bugs

- V2.12
- Corrected truncated extraction of certain yEnc format files.
- Flag multipart yEnc entries as incomplete when num parts < max part#
- Added flashing status bar indicator when errors are detected during extraction
- Updated help file.

- V2.11
- Added support for yEncoder format.
- Added support for Agent's headerless message archive format
- Reworked data type detection. It now works with Binhex & yEncoder formats
- support 3 line wrapped UUEncoded filenames
- Now handles input files of up to 4GB in size. (Contact me for versions
  without input file size restrictions.)


Contacting the author
---------------------
Bugs, comments, suggestions are welcome. 
Since UUD32Win is being distributed freely, feel free to pass it on in it's
unmodified form. I'd like to hear from you if you find this program useful!
I work on UUD32Win in my spare time, and feel it's pretty much complete, but I
am open to suggestions for future versions. Updates can usually be found at
http://www.marks-lab.com along with contact information at the bottom of the page.

Files included in this archive:
-------------------------------
UUD32WIN.EXE     - The application
UUD32WIN.HLP     - Old application Help file
UUDWIN.CHM       - Application Help file
README.TXT      This file
MULTTEST.MM     A MIME Base64 test message with three files in 5 parts


Good Luck!

	Mark Spankus

