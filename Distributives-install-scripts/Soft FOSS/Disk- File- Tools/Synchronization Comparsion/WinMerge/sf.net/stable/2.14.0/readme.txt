This is WinMerge 2.14.0 stable version.
It is recommended always to use stable versions for most users.

This is the first stable version of WinMerge which does not ship with 
an ANSI version, consequently support for Windows 95, 98, ME and NT4 is dropped.
The last stable version to support those was version 2.12.4.

---

Source in this release includes:
- all files from the subversion repository
- note that Web folder was removed - it is now own repository at
  http://bitbucket.org/kimmov/winmerge-web

Binaries include: 
- WinMergeU.exe
- expat and pcre dll:s
- Manual
- Filters
- Plugins
- ShellExtension dll (UNICODE & 64-bit versions)
- Translation PO files

---

Changes since the latest stable version 2.12.4:

WinMerge 2.14.0 - 2013-02-02 (r7596)
  Bugfix: Shell extension uses unquoted program path (patches:#3023)
  Translation updates:
  - Dutch (patches:#3020)
  - Slovenian (patches:#3021)

WinMerge 2.13.22 - 2013-01-13 (r7585)
  Translation updates:
  - Turkish (patches:#2967)
  - Russian (patches:#3017)
  - Norwegian (patches:#3018)
  - Danish (patches:#3019)

WinMerge 2.13.21 - 2012-12-30 (r7575)
  Update PCRE to version 8.10
  Update SCEW to version 1.1.2
  Improve startup time (#2788142)
  Add menuitems for selecting automatic or manual prediffing (#2638608)
  Add accelerator keys for Shell context menu (#2823536)
  Improve editing of linefilter regular expressions (#3015416)
  Allow editing context line count in patch creator (#2092180)
  Improve color options organization (#2818451)
  Add /xq command line switch for closing WinMerge after identical files
    and not showing message (#2827836)
  Allow setting codepage from command line (#2725549)
  Allow giving encoding name as custom codepage (#2813825, #3010934)
  Add new options dialog panel for folder compare options (#2819626)
  Add options GUI for quick compare limit (#2825628)
  Write config log as UTF-8 file (r7057)
  Bugfix: Untranslated string ("Merge.rc:nnnn") was displayed 
    in status bar (#3025855)
  Bugfix: Pane headers not updated after language change (#2923684)
  Bugfix: Quick contents compare didn't ignore EOL byte differences (#2929005)
  Bugfix: Compare by size always checked file times too (#2919510)
  Bugfix: Crash when pasting from clipboard (#3109525)
  Bugfix: Keeps verifing path even turned off in options (#3111581)
  Bugfix: Crash after deleting text (#3109521)
  Bugfix: Added EOL chars between copied file/path names (#2817546)
  Bugfix: Created new matching folder to wrong folder (#2890961)
  Bugfix: Strange scrolling effect in location pane (#2942869)
  Bugfix: Plugin error after interrupting folder compare (#2919475)
  Bugfix: "+" and "-" from the number block don't work in the editor (#3306182)
  Bugfix: Date format did not respect Regional Settings (#3175189)
  Bugfix: When selecting multiple files in Patch Generator dialog,
    "Swap" button led to an error.  (#3043635, #3066200)
  Bugfix: WinMerge contained a vulnerability in handling project files (#3185386)
    (http://www.zeroscience.mk/mk/vulnerabilities/ZSL-2011-4997.php)
  Installer: Remove OpenCandy from the InnoSetup installer (r7572, r7539)
  New translation: Basque (#3387142)
  Translation updates:
  - French (#3412030)
  - Hungarian (#3164982)
  - Spanish (#3412937)

WinMerge 2.13.20 - 2010-10-20 (r7319)
  Add missing keywords to Pascal highlighter (#2834192)
  Recognize .ascx files as ASP files (#3042393)
  Fix help locations (#2988974)
  Show only "Copy to other side" item in file compare
    context menu (#2600787)
  Expand/collapse folders from keyboard (#2203904)
  Improve detecting XML files in file compare (#2726531)
  Initialize folder selection dialog to currently selected folder in
    options dialog (r6570)
  New translation: Persian (#2877121, #3065119)
  New translation: Serbian (#3017674, #3065119)
  Installer: Drop Windows 9x/ME/NT4 support and use Microsoft runtime
    libraries installer (#3070254)
  Installer: Remove Uninstall shortcut from start menu folder (#3076909)
  Installer: Don't install quick launch icon for Windows 7 (#3079966)
  Installer: Add OpenCandy to the InnoSetup installer (#3088720)
  Bugfix: WinMerge was vulnerable to DLL hijacking as described in
    Microsoft Security Advisory (2269637)  (#33056008)
  Bugfix: Location pane focus enabled "Save" (#3022292)
  Bugfix: "Copy and advance" toolbar icons not automatically enabled (#3033325)
  Translation updates:
  - Bulgarian (#3082392)
  - Chinese (#3033324)
  - Dutch (#2804979)
  - French (#2850842, #2968200)
  - Slovenian (#2917796, #2932094, #2934354, #3070136)
  - Spanish (#2930734)
  - Turkish (#2825132, #2827817)
  - Ukrainian (#2817835)
