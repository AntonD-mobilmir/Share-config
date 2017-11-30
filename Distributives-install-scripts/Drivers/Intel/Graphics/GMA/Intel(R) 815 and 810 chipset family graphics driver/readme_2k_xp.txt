************************************************************
*
*  Production Version Release
*  Graphics Driver for
*  Intel(R) 810/810E/810E2/815/815E/815EM/815G/815EG Chipsets
*  Microsoft* Windows* 2000
*  Microsoft* Windows* XP
*  Driver Revision: 6.13.01.3004
*
*  6.6 Production Version                                    
*
*
*  February 11, 2002
*              
*	NOTE:  This document refers to systems containing the 
*         following Intel products:   
*
*	 Intel(R) 810 Chipset                                 
*	 Intel(R) 810E Chipset                                
* 	 Intel(R) 810E2 Chipset                                
*	 Intel(R) 815 Chipset                                 
*	 Intel(R) 815E Chipset                                
*	 Intel(R) 815EM Chipset 
*	 Intel(R) 815G Chipset 
*	 Intel(R) 815EG Chipset 
*		
*		
*  Installation Information
*                                                                     
*
*  This document makes references to products developed by 
*  Intel. There are some restrictions on how these products 
*  may be used and what information may be disclosed to 
*  others. Please read the Disclaimer section and contact 
*  your Intel field representative if you would like more 
*  information.
* 
************************************************************
************************************************************
*  DISCLAIMER: Intel is making no claims of usability, 
*  efficacy or warranty.  The INTEL SOFTWARE LICENSE AGREEMENT 
*  contained herein completely defines the license and use of 
*  this software.

************************************************************
************************************************************

************************************************************
* CONTENTS OF THIS DOCUMENT
************************************************************

This document contains the following sections:

1.  System Requirements
2.  Localized Language Abbreviations
3.  Installing the Software
4.  Verifying Installation of the Software
5.  Identifying the Software Version Number
6.  Uninstalling the Software
7.  Setup Installation Switches Available
8.  Self-Extracting EXE Installation Switches Available

************************************************************
* 1. SYSTEM REQUIREMENTS
************************************************************

1.  The system must contain one of the following Intel 
    Chipsets:

          Intel(R) 810 chipset
          Intel(R) 810E chipset
          Intel(R) 810E2 chipset
          Intel(R) 815 chipset
          Intel(R) 815E chipset   
          Intel(R) 815EM chipset   
          Intel(R) 815G chipset   
          Intel(R) 815EG chipset                       

2.  The software should be installed on systems with Microsoft
    Windows 2000 with at least 64 MB of system memory or 
    Microsoft Windows XP with at least 128 MB of system memory.

3.  There should be sufficient hard disk space in the <TEMP>
    directory on the system in order to install this
    software.

    The drivers included with this distribution package are
    designed to function with all released versions of
    Microsoft Windows 2000 and Microsoft Windows XP.

Please check with your system provider to determine the 
operating system and Intel(R) Chipset used in your system.

************************************************************
* 2.  LOCALIZED LANGUAGE ABBREVIATIONS
************************************************************

The following list contains the abbreviations of all
languages into which the driver has been localized. You may
have to refer to this section while using this document.

chs -> Mainland Chinese
cht -> Traditional Chinese
dan -> Danish
deu -> German
eng -> International English
enu -> English
esp -> Spanish
fin -> Finnish
fra -> French
frc -> French Canadian
ita -> Italian
jpn -> Japanese
kor -> Korean
nld -> Dutch
nor -> Norwegian
plk -> Polish
ptb -> Brazilian Portuguese
ptg -> Portuguese
rus -> Russian
sve -> Swedish
tha -> Thai

************************************************************
* 3.  INSTALLING THE SOFTWARE
************************************************************

General Installation Notes:

1.  The operating system must be installed prior to the
    installation of the driver.
    
    NOTE:  When upgrading from Windows 98 or Me, Windows* XP
    may indicate that the graphics driver should be upgraded
    first.  You should continue to install the operating
    system and only install the graphics driver after the
    Windows XP operating system installation is complete.

2.  This installation procedure is specific only to the 
    version of driver and installation file included in this 
    release.


3.1  INSTALLSHIELD (AUTOMATED) INSTALL FROM CD-ROM or WEB DOWNLOAD

1.  To install from a CD, insert the CD-ROM.  If autorun is
    enabled, the installer will begin automatically.
    Otherwise, enter the "Graphics" directory on the CD-ROM
    and double-click "SETUP.EXE".  Continue on to step 3.

2.  To install from a Web download, you will download either a 
    ZIP file or an EXE file from the Web.
    a. If it is an EXE file, double-click the file you
       downloaded and the Read Me file will be displayed.
       Click "Next".  Choose a location to Save the installation
       files and click "Next".  If an "Overwrite Protection" window
       appears, click "Yes to All" so that the installation files
       are replaced with the version you are installing.  Continue
       on to step 3.
    b. If it is a ZIP file, you must unzip it using a
       utility such as WinZip* or PKZip*, then enter the
       directory into which you unzipped the files.  Enter
       the "Graphics" subdirectory and double-click
       "SETUP.EXE".  Continue on to step 3.

3.  Click "Next" on the Welcome screen.

4.  Read the license agreement and click "Yes" to continue.

5.  The driver files will now be installed. When the install
    finishes, choose the "Yes.." option to restart, and click
    "Finish" to restart your computer. The driver should
    now be loaded. To determine if the driver has been loaded
    correctly, refer to the Verifying Installation section
    below.


3.2 MANUAL INSTALL FROM WEB DOWNLOAD (WINDOWS XP INSTRUCTIONS)

1.  Download "WIN2K_XP##.ZIP" from the Web, where "##" is the 
    driver version.  You must unzip it using a utility such
    as WinZip* or PKZip*.  Transfer the files to a CD if you
    wish to install from the CD-ROM.

2.  Click the "Start" button.

3.  Click the "Control Panel" icon.

4.  If the Control Panel is currently in Category View, click
    the "Switch to Classic View" link on the left side.

5.  Click the "Display" icon.  You should be in the "Display
    Properties" window.

6.  Click on the "Settings" tab.

7.  Click the "Advanced" button.

8.  Click the "Adapter" tab.

9.  Click the "Properties" button.

10. Click on the "Driver" tab.

11. Click the "Update Driver..." button.

12. The "Hardware Update Wizard" window should now
    open.

13. Select the following option: "Install from a list or 
    specific location (Advanced)".  Click the "Next" button.

14. Select the following option: "Don't search. I will choose 
    the driver to install". Click the "Next" button.

15. Click the "Have Disk" button.  Click "Browse...".

16. Enter the directory where you unzipped WIN2K_XP##.ZIP and 
    then enter the "Graphics" subdirectory. Next, enter the
    "WIN2000" subdirectory. At this point, the "I81XNT5.INF"
    file should be highlighted. Click "Open".
 
17. Click "OK". The "Select Device" screen should open and
    it may have several options to choose from. Select the
    display adapter that your system contains. Click "Next".
    If a warning appears saying that Windows cannot verify
    that this device driver is compatible with your
    hardware, click "Yes."
    
18. The driver should install. Click "Finish" when done.
    
19. Click "Close" and click "Yes" to reboot. The driver
    should now be loaded. To determine if the driver has 
    been loaded correctly, refer to the Verifying
    Installation section below.


3.3 MANUAL INSTALL FROM WEB DOWNLOAD (WINDOWS 2000 INSTRUCTIONS)

1.  Download "WIN2K_XP##.ZIP" from the Web, where "##" is the 
    driver version.  You must unzip it using a utility such
    as WinZip* or PKZip*.  Transfer the files to a CD if you
    wish to install from the CD-ROM.

2.  From the desktop, click on "My Computer".

3.  Click the "Control Panel" item.

4.  Click the "System" icon.  You should be in the "System
    Properties" window.
    
5.  Click on the "Hardware" tab

6.  Click the "Device Manager" button.

7.  Double-click the "Display Adapters" icon.

8.  The current list of adapters is displayed.

9.  Click on the adapter (e.g., VGA) that this driver is
    replacing.

10. Click on the "Driver" tab.

11. Click the "Update Driver..." button.

12. The "Upgrade Device Driver Wizard" window should now
    open.

13. Click the "Next" button.

14. Select the following option: "Display a list of the
    known drivers for this device so that I can choose a
    specific driver". Click the "Next" button.

15. Click the "Have Disk" button.  Click "Browse...".

16. Enter the directory where you unzipped WIN2K_XP##.ZIP and 
    then enter the "Graphics" subdirectory. Next, enter the
    "Win2000" subdirectory. At this point, the "I81XNT5.INF"
    file should be highlighted. Click "Open".
 
17. Click "OK". The "Select Device" screen should open and
    it may have several options to choose from. Select the
    display adapter that your system contains. Click "Next".
    If a warning appears saying that Windows cannot verify
    that this device driver is compatible with your
    hardware, click "Yes."
    
18. Click "Next". The driver should install. Click "Finish"
    when done.
    
19. Click "Close" and click "Yes" to reboot. The driver
    should now be loaded. To determine if the driver has 
    been loaded correctly, refer to the Verifying
    Installation section below.


************************************************************
* 4.  VERIFYING THE INSTALLATION OF THE SOFTWARE
************************************************************

4.1 VERIFYING THE INSTALLATION (WINDOWS XP INSTRUCTIONS)

1.  Click the "Start" button.

2.  Click the "Control Panel" icon.

3.  If the Control Panel is currently in Category View, click
    the "Switch to Classic View" link on the left side.

4.  Click the "System" icon.  You should be in the "System
    Properties" window.
    
5.  Click on the "Hardware" tab

6.  Click the "Device Manager" button.

7.  Double-click the "Display Adapters" icon.

8.  The Intel(R) Graphics Controller should be listed.
    If not, the driver is not installed correctly.  To check
    the version of the driver, refer to the section below.


4.2 VERIFYING THE INSTALLATION (WINDOWS 2000 INSTRUCTIONS)

1.  From the desktop, click on "My Computer".

2.  Click the "Control Panel" item.

3.  Click the "System" icon.  You should be in the "System
    Properties" window.
    
4.  Click on the "Hardware" tab

5.  Click the "Device Manager" button.

6.  Double-click the "Display Adapters" icon.

7.  The Intel(R) Graphics Controller should be listed.
    If not, the driver is not installed correctly.  To check
    the version of the driver, refer to the section below.


************************************************************
* 5.  IDENTIFYING THE SOFTWARE VERSION NUMBER
************************************************************

5.1 IDENTIFYING THE VERSION NUMBER (WINDOWS XP INSTRUCTIONS)

1.  Click the "Start" button.

2.  Click the "Control Panel" icon.

3.  If the Control Panel is currently in Category View, click
    the "Switch to Classic View" link on the left side.

4.  Click the "Display" icon.  You should be in the "Display
    Properties" window.

5.  Click on the "Settings" tab.

6.  Click the "Advanced" button.

7.  Click on the "Intel(R) Graphics Technology" tab.  The
    graphics driver version should be listed on this screen.


5.2 IDENTIFYING THE VERSION NUMBER (WINDOWS 2000 INSTRUCTIONS)    
    
1.  Click the "Start" button.

2.  Click the "Settings" item.

3.  Click the "Control Panel" item.

4.  Click the "Display" icon.  You should be in the "Display
    Properties" window.

5.  Click on the "Settings" tab.

6.  Click the "Advanced" button.

7.  Click on the "Intel(R) Graphics Technology" tab.  The
    graphics driver version should be listed on this screen.   

************************************************************
* 6.  UNINSTALLING THE SOFTWARE
************************************************************

6.1 UNINSTALLING THE SOFTWARE (WINDOWS XP INSTRUCTIONS)

1.  Click the "Start" button.

2.  Click the "Control Panel" icon.

3.  If the Control Panel is currently in Category View, click
    the "Switch to Classic View" link on the left side.

4.  Click the "Display" icon.  You should be in the "Display
    Properties" window.

5.  Click on the "Settings" tab.

6.  Click the "Advanced" button.

7.  Click the "Adapter" tab.

8.  Click on the "Properties" button.

9.  Click the "Driver" tab.

10. Click the "Uninstall" button.

11. A "Confirm Device Removal" window appears.  Click "OK",
    then click "Yes" when asked to restart the system.


6.2 UNINSTALLING THE SOFTWARE (WINDOWS 2000 INSTRUCTIONS)
    
1.  Click the "Start" button.

2.  Click the "Settings" item.

3.  Click the "Control Panel" item.

4.  Click the "Display" icon.  You should be in the "Display
    Properties" window.

5.  Click on the "Settings" tab.

6.  Click the "Advanced" button.

7.  Click the "Adapter" tab.

8.  Click on the "Properties" button.

9.  Click the "Driver" tab.

10. Click the "Uninstall" button.

11. A "Confirm Device Removal" window appears.  Click "OK",
    then click "Yes" when asked to restart the system.


************************************************************
* 7.  SETUP INSTALLATION SWITCHES AVAILABLE
************************************************************

The switches in the SETUP.EXE file will have the following 
syntax.  Switches are not case sensitive and may be 
specified in any order (except for the -s switch).  Switches 
must be separated by spaces.

SETUP [-b] [-g{xx[x]}] [-overwrite] [-nolic]
[-16x640x480x60] [-l{lang_value}] [-f2<path\logfile>] [-s]

-b  Forces a system reboot after the installation completes
when used with -s (silent mode).  In non-silent mode, this
switch has no effect.  In silent mode, the absence of this
switch forces the Setup.exe to complete without rebooting
(the user must manually reboot to conclude the installation
process).

-g{xx[x]}  Forces the configuration of a specific language 
version of the driver during the install.  The absence of
this switch will cause the installation to utilize the
language of the OS locale as its default.  Detailed
requirements for the Install Dialog language settings are
given in the Localized Language Abbreviations section.

-overwrite  Installs the graphics driver regardless of the
version of previously installed driver.  In non-silent
mode, the absence of this switch will prompt the user to
confirm overwrite of a newer Intel Graphics driver.  In
silent mode, the absence of this switch means that the
installation will abort any attempts to regress the revision
of the Intel Graphics driver.

-nolic	Suppresses the display of the license agreement
screen.  In non-silent mode, the absence of this switch
will only prompt the user to view and accept the license
agreement. The functionality of this switch is automatically
included during silent installations.

-16x640x480x60 (-<bits>x<x_pixels>x<y_pixels>x<vert_refresh>)
Sets the four default display parameters: bits per pixel,
pixels per line, pixels per column, and vertical refresh
rate.

-l{lang_value}  Specifies the language used for the
installation user interface.  The absence of this switch
will cause the installation to utilize the language of the
OS as its default. Detailed requirements for the Install 
Dialog language settings are given in the Localized Language
Abbreviations section.

-s  Run in silent mode. The absence of this switch causes
the install to be performed in verbose mode.

-f2<path\logfile>  Specifies an alternate location and name 
of the log file created by a silent install. By default,
Setup.log log file is created and stored during a silent
install in the same directory as that of Setup.ins.

************************************************************
* 8.  SELF-EXTRACTING EXE INSTALLATION SWITCHES AVAILABLE
************************************************************

For a driver that is packaged as a self-extracting EXE file,
such as WINXXX.EXE, switches can be passed to SETUP.EXE by
having them follow the -A switch for the self-extracting EXE
file.

WINXXX [-s] [-A <setup switches>]

-s  Extract files to the TEMP directory in silent mode.  The
absence of this switch cause the self-extracting EXE to
prompt the user for the path to extract the files.

-A  Used to pass parameters to SETUP.EXE.  Switches for
SETUP.EXE follow this switch.

************************************************************
* INTEL SOFTWARE LICENSE AGREEMENT
*   (OEM/IHV/ISV Distribution & Single User)
************************************************************
IMPORTANT - READ BEFORE COPYING, INSTALLING OR USING. 
Do not use or load this software and any associated
materials (collectively, the "Software") until you have
carefully read the following terms and conditions. By
loading or using the Software, you agree to the terms of
this Agreement. If you do not wish to so agree, do not
install or use the Software.

Please Also Note:
* If you are an Original Equipment Manufacturer (OEM),
  Independent Hardware Vendor (IHV), or Independent
  Software Vendor (ISV) this complete LICENSE AGREEMENT 
  applies;
* If you are an End-User, then only Exhibit A, the INTEL
  SOFTWARE LICENSE AGREEMENT, applies.

---------------------------------------------------------
For OEMs, IHVs, and ISVs:

LICENSE.  This Software is licensed for use only in conjunction
with Intel component products.  Use of the Software in 
conjunction with non-Intel component products is not licensed
hereunder.  Subject to the terms of this Agreement, Intel
grants to You a nonexclusive, nontransferable, worldwide,
fully paid-up license under Intel's copyrights to:
  a) use, modify, and copy Software internally for Your own
     development and maintenance purposes; and
  b) modify, copy and distribute Software, including derivative
     works of the Software, to Your end-users, but only
     under a license agreement with terms at least as
     restrictive as those contained in Intel's Final,
     Single-User License Agreement, attached as Exhibit A;
     and
  c) modify, copy and distribute the end-user documentation
     that may accompany the Software, but only in
     association with the Software.
If You are not the final manufacturer or vendor of a
computer system or software program incorporating the
Software, then You may transfer a copy of the Software,
including derivative works of the Software (and related
end-user documentation), to Your recipient for use in
accordance with the terms of this Agreement, provided such
recipient agrees to be fully bound by the terms hereof. You
shall not otherwise assign, sublicense, lease or in any
other way transfer or disclose Software to any third party.
You shall not reverse-compile, disassemble or otherwise
reverse-engineer the Software.

Except as expressly stated in this Agreement, no license or
right is granted to You directly or by implication,
inducement, estoppel or otherwise. Intel shall have the
right to inspect or have an independent auditor inspect
Your relevant records to verify Your compliance with the
terms and conditions of this Agreement.

CONFIDENTIALITY.  If You wish to have a third-party
consultant or subcontractor ("Contractor") perform work on
Your behalf that involves access to or use of Software,
You shall obtain a written confidentiality agreement from
the Contractor that contains terms and obligations with
respect to access to or use of Software no less restrictive
than those set forth in this Agreement and excluding any
distribution rights, and use for any other purpose.
Otherwise, You shall not disclose the terms or existence of
this Agreement or use Intel's name in any publications,
advertisements or other announcements without Intel's
prior written consent. You do not have any rights to use
any Intel trademarks or logos.

OWNERSHIP OF SOFTWARE AND COPYRIGHTS.  Title to all copies
of the Software remains with Intel or its suppliers. The
Software is copyrighted and protected by the laws of the
United States and other countries, and by international
treaty provisions. You may not remove any copyright notices
from the Software. Intel may make changes to the Software,
or to items referenced therein, at any time without notice,
but is not obligated to support or update the Software.
Except as otherwise expressly provided, Intel grants no
express or implied right under Intel patents, copyrights,
trademarks or other intellectual property rights. You may
transfer the Software only if the recipient agrees to be
fully bound by these terms and if you retain no copies of
the Software.

LIMITED MEDIA WARRANTY.  If the Software has been delivered
by Intel on physical media, Intel warrants the media to be
free from material, physical defects for a period of ninety(90)
days after delivery by Intel. If such a defect is found,
return the media to Intel for replacement or alternate
delivery of the Software as Intel may select.

EXCLUSION OF OTHER WARRANTIES. EXCEPT AS PROVIDED ABOVE,
THE SOFTWARE IS PROVIDED "AS IS," WITHOUT ANY EXPRESS OR
IMPLIED WARRANTY OF ANY KIND, INCLUDING WARRANTIES OF
MERCHANTABILITY, NONINFRINGEMENT OR FITNESS FOR A
PARTICULAR PURPOSE.  Intel does not warrant or assume
responsibility for the accuracy or completeness of any
information, text, graphics, links or other items
contained within the Software.

LIMITATION OF LIABILITY. IN NO EVENT SHALL INTEL OR ITS
SUPPLIERS BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING,
WITHOUT LIMITATION, LOST PROFITS, BUSINESS INTERRUPTION OR
LOST INFORMATION) ARISING OUT OF THE USE OF OR INABILITY TO
USE THE SOFTWARE, EVEN IF INTEL HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES. SOME JURISDICTIONS PROHIBIT
EXCLUSION OR LIMITATION OF LIABILITY FOR IMPLIED WARRANTIES
OR CONSEQUENTIAL OR INCIDENTAL DAMAGES, SO THE ABOVE
LIMITATION MAY NOT APPLY TO YOU. YOU MAY ALSO HAVE OTHER
LEGAL RIGHTS THAT VARY FROM JURISDICTION TO JURISDICTION. 

TERMINATION OF THIS AGREEMENT.  Intel may terminate this
Agreement at any time if you violate its terms. Upon
termination, you will immediately destroy the Software or
return all copies of the Software to Intel.
 
APPLICABLE LAWS.  Claims arising under this Agreement shall
be governed by the laws of California, excluding its
principles of conflict of laws and the United Nations
Convention on Contracts for the Sale of Goods. You may not
export the Software in violation of applicable export laws
and regulations. Intel is not obligated under any other
agreements unless they are in writing and signed by an
authorized representative of Intel.

GOVERNMENT RESTRICTED RIGHTS.  The Software is provided
with "RESTRICTED RIGHTS." Use, duplication or disclosure
by the Government is subject to restrictions as set forth
in FAR52.227-14 and DFAR252.227-7013 et seq. or their
successors. Use of the Software by the Government
constitutes acknowledgment of Intel's proprietary rights
therein. Contractor or Manufacturer is Intel Corporation,
2200 Mission College Blvd., Santa Clara, CA 95052.

---------------------------------------------------------
EXHIBIT "A"
INTEL SOFTWARE LICENSE AGREEMENT (Final, Single User)

IMPORTANT - READ BEFORE COPYING, INSTALLING OR USING. 
Do not use or load this software and any associated
materials (collectively, the "Software") until you have
carefully read the following terms and conditions. By
loading or using the Software, you agree to the terms of
this Agreement. If you do not wish to so agree, do not
install or use the Software.

LICENSE.  You may copy the Software onto a single computer
for your personal, non-commercial use, and you may make one
back-up copy of the Software, subject to these conditions: 
1. This Software is licensed for use only in conjunction
   with Intel component products.  Use of the Software in
   conjunction with non-Intel components is not licensed
   hereunder.
2. You may not copy, modify, rent, sell, distribute or
   transfer any part of the Software except as provided in
   this Agreement, and you agree to prevent unauthorized
   copying of the Software.
3. You may not reverse-engineer, decompile or disassemble
   the Software. 
4. You may not sublicense or permit simultaneous use of the
   Software by more than one user.
5. The Software may contain the software or other property
   of third-party suppliers, some of which may be identified
   in, and licensed in accordance with, any enclosed
   "license.txt" file or other text or file. 

OWNERSHIP OF SOFTWARE AND COPYRIGHTS.  Title to all copies
of the Software remains with Intel or its suppliers. The
Software is copyrighted and protected by the laws of the
United States and other countries, and international treaty
provisions. You may not remove any copyright notices from
the Software. Intel may make changes to the Software, or to
items referenced therein, at any time without notice, but
is not obligated to support or update the Software. Except
as otherwise expressly provided, Intel grants no express or
implied right under Intel patents, copyrights, trademarks
or other intellectual property rights. You may transfer the
Software only if the recipient agrees to be fully bound by
these terms and if you retain no copies of the Software.

LIMITED MEDIA WARRANTY.  If the Software has been delivered
by Intel on physical media, Intel warrants the media to be
free from material, physical defects for a period of ninety(90)
days after delivery by Intel. If such a defect is found,
return the media to Intel for replacement or alternate
delivery of the Software as Intel may select.

EXCLUSION OF OTHER WARRANTIES. EXCEPT AS PROVIDED ABOVE,
THE SOFTWARE IS PROVIDED "AS IS," WITHOUT ANY EXPRESS OR
IMPLIED WARRANTY OF ANY KIND, INCLUDING WARRANTIES OF
MERCHANTABILITY, NONINFRINGEMENT OR FITNESS FOR A
PARTICULAR PURPOSE.  Intel does not warrant or assume
responsibility for the accuracy or completeness of any
information, text, graphics, links or other items contained
within the Software.

LIMITATION OF LIABILITY. IN NO EVENT SHALL INTEL OR ITS
SUPPLIERS BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING,
WITHOUT LIMITATION, LOST PROFITS, BUSINESS INTERRUPTION OR
LOST INFORMATION) ARISING OUT OF THE USE OF OR INABILITY TO
USE THE SOFTWARE, EVEN IF INTEL HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES. SOME JURISDICTIONS PROHIBIT
EXCLUSION OR LIMITATION OF LIABILITY FOR IMPLIED WARRANTIES
OR CONSEQUENTIAL OR INCIDENTAL DAMAGES, SO THE ABOVE
LIMITATION MAY NOT APPLY TO YOU. YOU MAY ALSO HAVE OTHER
LEGAL RIGHTS THAT VARY FROM JURISDICTION TO JURISDICTION. 

TERMINATION OF THIS AGREEMENT.  Intel may terminate this
Agreement at any time if you violate its terms. Upon
termination, you will immediately destroy the Software or
return all copies of the Software to Intel.
 
APPLICABLE LAWS.  Claims arising under this Agreement shall
be governed by the laws of California, excluding its
principles of conflict of laws and the United Nations
Convention on Contracts for the Sale of Goods. You may not
export the Software in violation of applicable export laws
and regulations. Intel is not obligated under any other
agreements unless they are in writing and signed by an
authorized representative of Intel.

GOVERNMENT RESTRICTED RIGHTS.  The Software is provided
with "RESTRICTED RIGHTS." Use, duplication or disclosure
by the Government is subject to restrictions as set forth
in FAR52.227-14 and DFAR252.227-7013 et seq. or their
successors. Use of the Software by the Government
constitutes acknowledgment of Intel's proprietary rights
therein. Contractor or Manufacturer is Intel Corporation,
2200 Mission College Blvd., Santa Clara, CA 95052.
 
SLAOEMISV1/RBK/January 21, 2000
************************************************************
************************************************************
Information in this document is provided in connection with
Intel products. Except as expressly stated in the INTEL
SOFTWARE LICENSE AGREEMENT contained herein, no license,
express or implied, by estoppel or otherwise, to any
intellectual property rights is granted by this document.
Except as provided in Intel's Terms and Conditions of Sale
for such products, Intel assumes no liability whatsoever,
and Intel disclaims any express or implied warranty,
relating to sale and/or use of Intel products, including
liability or warranties relating to fitness for a particular
purpose, merchantability or infringement of any patent,
copyright or other intellectual property right. Intel
products are not intended for use in medical, lifesaving,
or life-sustaining applications.

************************************************************
* Intel Corporation disclaims all warranties and liabilities
* for the use of this document, the software and the
* information contained herein, and assumes no
* responsibility for any errors which may appear in this
* document or the software, nor does Intel make a commitment
* to update the information or software contained herein.
* Intel reserves the right to make changes to this document
* or software at any time, without notice.
************************************************************

*Other names and brands may be claimed as the property of others

Copyright (c) Intel Corporation, 1998-2003