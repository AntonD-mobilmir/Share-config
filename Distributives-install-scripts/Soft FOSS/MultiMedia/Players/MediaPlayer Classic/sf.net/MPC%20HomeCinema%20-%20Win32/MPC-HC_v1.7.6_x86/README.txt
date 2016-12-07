This file includes only a short list of the changes between MPC-HC's versions.
For the older changes see:
https://github.com/mpc-hc/mpc-hc/blob/master/docs/Changelog_old.txt

Legend:
+ New
* Changed
! Fixed


1.7.6 - 05 July 2014
====================
+ ISR: Add an option to control subtitle renderer behavior regarding anamorphic video
+ ISR: Add an option to render subtitles at the source video resolution like VSFilter.
+ VSFilter: Display more informative names for external subtitles (similar to what is done with the internal subtitle renderer)
+ Add a "Copy to clipboard" feature to the "Play > Filters" menu so that the list of currently loaded filters can be copied easily
+ Add an option in the "Save Subtitle" dialog to control the export of the default style as an external ".style" file
+ Ticket #1411, Internal Subtitle Renderer/VSFilter: Support loading external PGS subtitles
* Text subtitles: When rendering to the video frame, clip subtitles that go out of the frame
* Text subtitles: Faster subtitle parsing (around 20%)
* Ticket #4144, Move the user interface language selection to the Options dialog and remove the "Language" menu.
  The increasing number of translations had reduced the usability of the menu
* Ticket #3739, Make error reporting less verbose when some non-critical DVD hooks fail
* Don't use auto-zoom feature when the window was positioned using the Aero Snap
* Don't exit fullscreen when loosing focus to a window on the same monitor
* Updated Little CMS to v2.6 (git 4da8703)
* Updated Unrar to v5.1.6
* Updated MediaInfoLib to v0.7.69
* Updated ZenLib to v0.4.29 r458
* Updated LAV Filters to stable version 0.62.0:
    - LAV Video: Support VP7 video
    - LAV Video: Use the MediaFoundation WMV decoder on Windows 7+ instead of the DMO WMV decoder
    - Ticket #4032, LAV Video: Fix some issues with DVD subtitles (flashing, overlapping and generally all kind of timing issues)
    - Ticket #3575, LAV Splitter: Alternate audio support for HLS
    - Ticket #4326, LAV Splitter: No subtitles were displayed when using the special "Forced subtitles" track created for PGS subtitles
    - Ticket #4357, LAV Video: Fix some performance regressions introduced in v0.61 (mostly visible on old operating systems like Windows XP)
* Updated Armenian, Basque, Belarusian, Bengali, British English, Catalan, Chinese (simplified and traditional), Croatian,
  Czech, Dutch, French, Galician, German, Greek, Hebrew, Hungarian, Italian, Japanese, Korean, Malay, Polish, Portuguese (Brazil),
  Romanian, Russian, Slovak, Slovenian, Spanish, Swedish, Tatar, Turkish, Ukrainian and Vietnamese translations
! The dockable bars were not updated when changing the UI language
! Statusbar: Fixed occasional flickering of text and media type icon
! D3D Fullscreen last state was inverted and wasn't properly restored with "Remember last window size and position" option
! D3D Fullscreen produced invisible window for audio-only files
! Ticket #34, VSFilter/ISR: Override placement feature was not working even if enabled
! Ticket #1574/#4171, ISR: Subtitle positioning was wrong when using default style override
! Ticket #2244, ISR: Changes in subresync bar were lost after changing style
! Ticket #2671, VSFilter: Video frames were not marked as interlaced
! Ticket #3036, Fix drag-and-drop from some applications. Drag-and-dropping a downloaded file from Chrome failed for example
! Ticket #3701, Subtitle outline was too thick when using default style override
! Ticket #4213, Fix a deadlock when starting MPC-HC in D3D fullscreen and auto-changing the monitor mode
! Ticket #4213, Fix auto-changing the monitor mode when starting in D3D fullscreen with "play 0 time" option
  or the auto-change delay greater than 0s
! Ticket #4213, D3D fullscreen: Obey "Apply default monitor mode on fullscreen exit" option
! Ticket #4214, Fix monitor mode flickering when auto-changing the monitor mode
! Ticket #4284, Auto-zoom feature didn't work properly when the taskbar was docked at the left or the top of the screen
! Ticket #4285, Fix a freeze when opening some files when EVR-CP or Sync renderer are selected
! Ticket #4285, EVR-CP and Sync renderers: Properly set the aspect ratio
! Ticket #4288, Changing the zoom level when in fullscreen mode did nothing
! Ticket #4298, The auto-change fullscreen mode monitor settings could be randomly corrupted or missing
! Ticket #4299, Frame stepping was not working for DVD
! Ticket #4307, ANSI subtitles files with Unix line endings could crash MPC-HC
! Ticket #4408, Remember window position: Ensure the window can't be completely hidden after restoring it
