*******************2K_XP***********************************
*  Production Version Releases
*  
*
*  Microsoft Windows* 2000                                                       
*  Microsoft Windows* XP                                                         
*  Driver Revision: 6.14.10.4497
*
*  Package: 26137
*
*  Production Version 14.19.50.4497                                              
*
*
*  February 8, 2006
*
*  NOTE:  This document refers to systems containing the 
*         following Intel chipsets: 
*
*     Intel(R) 855GM Chipset                               
*     Intel(R) 852GM Chipset                               
*     Intel(R) 855GME Chipset                              
*     Intel(R) 852GME Chipset                              
*     Intel(R) 910GL Express Chipset                       
*     Intel(R) 915GV Express Chipset                       
*     Intel(R) 945G Express Chipset                        
*     Mobile Intel(R) 915GM Express Chipset                
*     Mobile Intel(R) 910GML Express Chipset               
*     Mobile Intel(R) 915GMS Express Chipset               
*     Intel(R) 915G Chipset                                
*     Intel(R) 945GM Express Chipset                                  
*	                               
*	
*  Installation Information
*
*  This document makes references to products developed by
*  Intel. There are some restrictions on how these products
*  may be used, and what information may be disclosed to
*  others. Please read the Disclaimer section and contact
*  your Intel field representative if you would like more
*  information.
*
***********************************************************
***********************************************************
*  DISCLAIMER: Intel is making no claims of usability,
*  efficacy or warranty.  The INTEL SOFTWARE LICENSE
*  AGREEMENT contained herein completely defines the 
*  license and use of this software.
*
*  This document contains information on products in the 
*  design phase of development. The information here is 
*  subject to change without notice. Do not finalize a 
*  design with this information.
***********************************************************
***********************************************************

***********************************************************
*  CONTENTS OF THIS DOCUMENT
***********************************************************

This document contains the following sections:

1.  System Requirements
2.  Localized Language Abbreviations
3.  Installing the Software
4.  Verifying Installation of the Software
5.  Identifying the Software Version Number
6.  Uninstalling the Software
7.  Installation Switches Available

***********************************************************
* 1.  SYSTEM REQUIREMENTS
***********************************************************

1.  The system must contain one of the following Intel
    Chipsets:

      Intel(R) 855GM Chipset                               
      Intel(R) 852GM Chipset                               
      Intel(R) 855GME Chipset                              
      Intel(R) 852GME Chipset                              
      Intel(R) 910GL Express Chipset                       
      Intel(R) 915GV Express Chipset                       
      Intel(R) 945G Express Chipset                        
      Mobile Intel(R) 915GM Express Chipset                
      Mobile Intel(R) 910GML Express Chipset               
      Mobile Intel(R) 915GMS Express Chipset               
      Intel(R) 915G Chipset                                
      Intel(R) 945GM Express Chipset                       
     


2.  The software should be installed on systems with at
    least 128 MB of system memory.

3.  There should be sufficient hard disk space in the 
    <TEMP> directory on the system in order to install 
    this software.

    The drivers included with this distribution package are
    designed to function with all released versions of
    Microsoft Windows* 2000 and Microsoft Windows* XP.

Please check with your system provider to determine the
operating system and Intel Chipset used in your system.

***********************************************************
* 2.  LOCALIZED LANGUAGE ABBREVIATIONS
***********************************************************

The following list contains the hexadecimal key of all
languages into which the driver has been localized. You may
have to refer to this section while using this document.

0804 -> Simplified Chinese
0404 -> Chinese Traditional
0006 -> Danish
0013 -> Dutch
0009 -> English (United States)
000B -> Finnish
0C0C -> French (Canadian)
040C -> French (Standard)
0007 -> German
0010 -> Italian
0011 -> Japanese
0012 -> Korean
0014 -> Norwegian
0015 -> Polish
0416 -> Portuguese (Brazil)
0816 -> Portuguese (Standard)
0019 -> Russian
000A -> Spanish
001D -> Swedish
001E -> Thai
0005 -> Czech
0008 -> Greek
000E -> Hungarian
001F -> Turkish



***********************************************************
* 3.  INSTALLING THE SOFTWARE
***********************************************************

General Installation Notes:

1.  The operating system must be installed prior to the
    installation of the driver.

2.  This installation procedure is specific only to the 
    version of driver and installation file included in 
    this release.

3.  This procedure assumes that all of the software
    associated with this release is located in the same
    directory.



MANUAL "HAVE-DISK" INSTALLATION INSTRUCTIONS
--------------------------------------------

To install from a Web download, you will download a ZIP 
file from the Web.  You must unzip it using a utility such
as WinZip* or PKZip*. 
      

Microsoft Windows* 2000 Installation Instructions
-------------------------------------------------

1.  Right click on "My Computer" icon and then click on 
    "Properties".

2.  Click on "Hardware" tab and select the "Device 
    Manager..." button. (NOTE: IF UPDATING DRIVER GO TO 
    STEP 3B)

3a. Double click "Video Controller (VGA Compatible)". 
    (Go To STEP 4)

3b. Double click "Display adapters". Double click on the 
    graphics controller shown.

4.  Click on "Driver" tab and select "Update Driver...".

5.  Click on the "Next" button.

6.  Select the following option: "Display a list of the 
    known drivers for this device so that I can choose a 
    specific driver". Click on the "Next" button.
    (NOTE: IF UPDATING DRIVER GO TO STEP 8)

7.  Select "Display adapters". Click on the "Next" button.

8.  Click on the "Have Disk..." button and then the 
    "Browse" button.

9.  Enter the directory where you unzipped the file you
    downloaded, and then enter the "Win2000" subdirectory. 
    Highlight the "ialmnt5.INF" file. Click on the "Open"
    button. 

10. Click on the "OK" button. A window listing all of the
    available display types should open. Select the display
    adapter that your system contains and then click on the
    "Next" button. 

11. Click on the "Next" button. The operating system will 
    install the driver. Click on the "Finish" button when 
    done.

12. Click on the "Close" button and then click on the "Yes"
    button to reboot. The driver should now be loaded. 
    

    

To determine if the driver has been loaded correctly, refer 
to the Verifying Installation section below.



Microsoft Windows* XP Installation Instructions 
-----------------------------------------------

1.  Click "Start" then right click on "My Computer" icon 
    and then click on "Properties".

2.  Click on "Hardware" Tab and select "Device Manager". 
    (NOTE: IF UPDATING DRIVER GO TO STEP 3B)

3a. Double click "Video Controller (VGA Compatible)". 
    (Go To STEP 4)

3b. Select "Display adapters" then Double click on the 
    graphics controller shown.  

4.  Click on "Driver" tab and select "Update Driver...".

5.  Select the following option: "Install from a list or
    specific location (Advanced)". Click on the "Next" 
    button.

6.  Select the following option: "Don't search.  I will 
    choose the driver to install".  Click on the "Next" 
    button. (NOTE: IF UPDATING DRIVER GO TO STEP 8)

7.  Select "Display adapters". Click on the "Next" button.

8.  Click on the "Have Disk..." button and then the 
    "Browse" button.

9.  Enter the directory where you unzipped the file you 
    downloaded, and then enter the "Win2000" subdirectory.
    Highlight the "ialmnt5.INF" file. Click on the 
    "Open" button. 

10. Click on the "OK" button. A window listing all of the
    available display types should open. Select the display
    adapter that your system contains and then click on the
    "Next" button. 

11. The operating system will install the driver.
    Click on the "Finish" button when done.

12. Click on the "Close" button. If a dialogue asking to 
    reboot the system is displayed, Click on the "Yes"
    button to automatically reboot. Otherwise, manually 
    restart the system. The driver should now be loaded.

To determine if the driver has been loaded correctly, refer 
to the Verifying Installation section below.


AUTOMATED INSTALL USING SETUP.EXE
---------------------------------

1. To install from a Web download, you will download a ZIP
   file from the Web. You must unzip it using a utility 
   such as WinZip* or PKZip*. 

2. Click the 'Start' button in the task bar, click 'Run...' 
   and then select 'Setup.exe' from the hard drive 
   directory where the driver files are stored.  The 
   Install dialog will appear.

3. click 'Next' to continue.  

4. Read License Agreement and click Yes to proceed.
 
5. When the 'Setup COMPLETE' message appears click 
   'Finish' to restart your computer.

Setup install switches are listed in section 7 below.  


***********************************************************
* 4.  VERIFYING INSTALLATION OF THE SOFTWARE
***********************************************************

1.  Double Click on the "My Computer" icon, then double 
    click on the "Control Panel" icon, and then double 
    click on the "System" icon.

2.  Click on "Hardware" Tab and select "device manager". 
    Click on the "Display Adapters" icon. The Intel 
    Graphics Driver should be listed.  If not, the driver
    is not installed correctly. To check the version of 
    the driver, refer to the section below.

***********************************************************
* 5.  IDENTIFYING THE SOFTWARE VERSION NUMBER
***********************************************************

1.  Double Click on the "My Computer" icon, then click
    on "Properties".

2.  Click on the "Hardware" tab and select
    "Device Manager".

3.  Select "Display adapters" then double click on the
    graphics controller shown.
    
4.  Click on "Driver" tab. The graphics driver version   
    should be listed on driver version.

***********************************************************
* 6.  UNINSTALLING THE SOFTWARE
***********************************************************

NOTE: This procedure assumes the above installation process
was successful. This uninstallation procedure is specific
only to the version of the driver and installation files
included in this package.

1.  Click on the "My Computer" icon, then click on the
    "Control Panel" icon, and then click on the "Add/Remove
    Programs" icon.

2.  Select Intel(R) Graphics Media Accelerator Driver
    Software.
    
3.  Click the "Remove" button to uninstall the driver. 

***********************************************************
* 7.  INSTALLATION SWITCHES AVAILABLE
***********************************************************

The switches in the SETUP.EXE file will have the following
syntax. Switches are not case sensitive and may be
specified in any order (except for the -s switch). Switches
must be separated by spaces.

SETUP [-b] [-overwrite][-nolic] 
[-bits x x_pixels x y_pixels x vert_refresh]
[-l{lang_value}] [-s] [-f2<path\logfile>]

GFX-INSTALL CUSTOM SWITCHES

-b  Forces a system reboot after the installation 
completes. In non-silent mode, the absence of this switch 
will prompt the user to reboot. In silent mode, the absence
of this switch forces the Setup.exe to complete without 
rebooting (the user must manually reboot to conclude the 
installation process).

-overwrite  Installs the graphics driver regardless of the
version of previously installed driver.  In non-silent 
mode, the absence of this switch will prompt the user to 
confirm overwrite of a newer Intel Graphics driver. In 
silent mode, the absence of this switch means that the 
installation will abort any attempts to regress the 
revision of the Intel(R) Extreme Graphics driver.

-nolic	Suppresses the display of the license agreement
screen. In non-silent mode, the absence of this switch will
only prompt the user to view and accept the license
agreement. The functionality of this switch is auto-
matically included during silent installations.

-[bits per pixels]x[x_pixels]x[y_pixels]x[vert_refresh].  
Sets the four default display parameters: bits per pixel,
pixels per line, pixels per column and vertical refresh 
rate. For example: If you want 16 bits per pixel, 1024 
pixels per line, 768 pixels per column, and a vertical 
refresh rate of 75Hz, you would input the following at 
the command line "-16x1024x768x75".

-l{lang_value}  The switch specifies the language used for
the Gfx-Install user interface. The absence of this switch
will cause the installation to utilize the language of the
OS as its default. Hexadecimal values for the supported 
languages can be found in the localized langauage 
abbreviations section of this readme.

-s  Run in silent mode. The absence of this switch causes
the install to be performed in verbose mode.

-f2<path\logfile>  Specifies an alternate location and name
of the log file created by a silent install. By default,
the log file is created and stored during a silent
install in the windows temp directory as IntelGFX.log
(<WINDIR>\Temp\IntelGFX.log).


***********************************************************
* INTEL SOFTWARE LICENSE AGREEMENT
*   (OEM/IHV Distribution & Single User)
***********************************************************
IMPORTANT - READ BEFORE COPYING, INSTALLING OR USING. 
Do not use or load this software and any associated 
materials (collectively, the "Software") until you have 
carefully read the following terms and conditions. By 
loading or using the Software, you agree to the terms of 
this Agreement. If you do not wish to so agree, do not 
install or use the Software.

Please Also Note:
    a) If you are an Original Equipment Manufacturer (OEM),
       Independent Hardware Vendor (IHV), or Independent 
       Software Vendor (ISV), this complete LICENSE 
       AGREEMENT applies;
    b) If you are an End-User, then only Exhibit A, the 
       INTEL SOFTWARE LICENSE AGREEMENT, applies.

---------------------------------------------------------
For OEMs, IHVs, and ISVs:

LICENSE. This Software is licensed for use only in 
conjunction with Intel component products.  Use of the 
Software in conjunction with non-Intel component products
is not licensed hereunder. Subject to the terms of this 
Agreement, Intel grants to You a nonexclusive, 
nontransferable, worldwide, fully paid-up license under 
Intel’s copyrights to:
    a) use, modify and copy Software internally for Your 
       own development and maintenance purposes; and
    b) modify, copy and distribute Software, including 
       derivative works of the Software, to Your end-users,
       but only under a license agreement with terms at 
       least as restrictive as those contained in Intel's 
       Final, Single User License Agreement, attached as 
       Exhibit A; and
    c) modify, copy and distribute the end-user 
       documentation which may accompany the Software, 
       but only in association with the Software. If You
       are not the final manufacturer or vendor of a 
       computer system or software program incorporating 
       the Software, then You may transfer a copy of the 
       Software, including derivative works of the Software
       (and related end-user documentation) to Your 
       recipient for use in accordance with the terms of 
       this Agreement, provided such recipient agrees to be
       fully bound by the terms hereof.  You shall not 
       otherwise assign, sublicense, lease, or in any other
       way transfer or disclose Software to any third 
       party. You shall not reverse- compile, disassemble 
       or otherwise reverse-engineer the Software.

Except as expressly stated in this Agreement, no license or
right is granted to You directly or by implication, 
inducement, estoppel or otherwise. Intel shall have the 
right to inspect or have an independent auditor inspect 
Your relevant records to verify Your compliance with the
terms and conditions of this Agreement.

CONFIDENTIALITY.   If You wish to have a third party 
consultant or subcontractor ("Contractor") perform work on 
Your behalf which involves access to or use of Software, 
You shall obtain a written confidentiality agreement from
the Contractor which contains terms and obligations with
respect to access to or use of Software no less restrictive
than those set forth in this Agreement and excluding any
distribution rights, and use for any other purpose. 
Otherwise, You shall not disclose the terms or existence of
this Agreement or use Intel's name in any publications, 
advertisements, or other announcements without Intel's 
prior written consent.  You do not have any rights to use 
any Intel trademarks or logos.

OWNERSHIP OF SOFTWARE AND COPYRIGHTS. Title to all copies 
of the Software remains with Intel or its suppliers. The
Software is copyrighted and protected by the laws of the 
United States and other countries, and international treaty
provisions. You may not remove any copyright notices from 
the Software. Intel may make changes to the Software, or to
items referenced therein, at any time and without notice, 
but is not obligated to support or update the Software. 
Except as otherwise expressly provided, Intel grants no 
express or implied right under Intel patents, copyrights, 
trademarks, or other intellectual property rights. You
may transfer the Software only if the recipient agrees 
to be fully bound by these terms and if you retain no 
copies of the Software.

LIMITED MEDIA WARRANTY.  If the Software has been delivered
by Intel on physical media, Intel warrants the media to be
free from material physical defects for a period of ninety 
(90) days after delivery by Intel. If such a defect is 
found, return the media to Intel for replacement or 
alternate delivery of the Software as Intel may select.

EXCLUSION OF OTHER WARRANTIES. EXCEPT AS PROVIDED ABOVE,
THE SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR 
IMPLIED WARRANTY OF ANY KIND, INCLUDING WARRANTIES OF 
MERCHANTABILITY, NONINFRINGEMENT, OR FITNESS FOR A 
PARTICULAR PURPOSE. Intel does not warrant or assume 
responsibility for the accuracy or completeness of any 
information, text, graphics, links or other items 
contained within the Software.

LIMITATION OF LIABILITY. IN NO EVENT SHALL INTEL OR ITS 
SUPPLIERS BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING,
WITHOUT LIMITATION, LOST PROF¬ITS, BUSINESS INTERRUPTION
OR LOST INFORMATION) ARISING OUT OF THE USE OF OR IN¬
ABILITY TO USE THE SOFTWARE, EVEN IF INTEL HAS BEEN 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. SOME 
JURISDICTIONS PROHIBIT EXCLUSION OR LIMITA¬TION OF 
LIABILITY FOR IMPLIED WARRANTIES OR CONSEQUENTIAL OR 
INCIDENTAL DAMAGES, SO THE ABOVE LIMITATION MAY NOT APPLY
TO YOU. YOU MAY ALSO HAVE OTHER LEGAL RIGHTS THAT VARY 
FROM JURISDICTION TO JURISDICTION. 

TERMINATION OF THIS AGREEMENT. Intel may terminate this 
Agreement at any time if you violate its terms. Upon 
termination, you will immediately destroy the Software or 
return all copies of the Software to Intel.

APPLICABLE LAWS. Claims arising under this Agreement shall
be governed by the laws of California, excluding its 
principles of conflict of laws and the United Nations
Convention on Contracts for the Sale of Goods. You may not
export the Software in violation of applicable export laws
and regulations. Intel is not obligated under any other 
agreements unless they are in writing and signed by an 
authorized representative of Intel.

GOVERNMENT RESTRICTED RIGHTS. The Software is provided 
with "RESTRICTED RIGHTS." Use, duplication, or disclosure 
by the Government is subject to restrictions as set forth
in FAR52.227-14 and DFAR252.227-7013 et seq. or their 
successors. Use of the Software by the Government 
constitutes acknowledg¬ment of Intel's proprietary rights
therein. Contractor or Manufacturer is Intel Corporation, 
2200 Mission College Blvd., Santa Clara, CA 95052.

---------------------------------------------------------
EXHIBIT "A" 
INTEL END-USER SOFTWARE LICENSE AGREEMENT (Final, Single 
User)

IMPORTANT - READ BEFORE COPYING, INSTALLING OR USING. 
Do not use or load this software and any associated 
materials (collectively, the "Software") until you have 
carefully read the following terms and conditions. By 
loading or using the Software, you agree to the terms of 
this Agreement. If you do not wish to so agree, do not 
install or use the Software.

LICENSE. You may copy the Software onto a single computer 
for your personal, noncommercial use, and you may make 
one back-up copy of the Software, subject to these 
conditions: 
1.  This Software is licensed for use only in conjunction 
    with Intel component products.  Use of the Software in 
    conjunction with non-Intel component products is not 
    licensed hereunder. 
2.  You may not copy, modify, rent, sell, distribute or 
    transfer any part of the Software except as provided in
    this Agreement, and you agree to prevent unauthorized 
    copying of the Software.
3.  You may not reverse engineer, decompile, or disassemble
    the Software. 
4.  You may not sublicense or permit simultaneous use of 
    the Software by more than one user.
5.  The Software may contain the software or other property
    of third party suppliers, some of which may be 
    identified in, and licensed in accordance with, any 
    enclosed "license.txt" file or other text or file. 

Bill
OWNERSHIP OF SOFTWARE AND COPYRIGHTS. Title to all copies
of the Software remains with Intel or its suppliers. The 
Software is copyrighted and protected by the laws of the 
United States and other countries, and international treaty
provisions. You may not remove any copyright notices from 
the Software. Intel may make changes to the Software,or to
items referenced therein, at any time without notice, but 
is not obligated to support or update the Software. Except 
as otherwise expressly provided, Intel grants no express or
implied right under Intel patents, copyrights,trademarks, 
or other intellectual property rights. You may transfer the
Software only if the recipient agrees to be fully bound by 
these terms and if you retain no copies of the Software.

LIMITED MEDIA WARRANTY.  If the Software has been delivered
by Intel on physical media, Intel warrants the media to be
free from material physical defects for a period of ninety 
(90) days after delivery by Intel. If such a defect is 
found, return the media to Intel for replacement or 
alternate delivery of the Software as Intel may select.

EXCLUSION OF OTHER WARRANTIES. EXCEPT AS PROVIDED ABOVE, 
THE SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR 
IMPLIED WARRANTY OF ANY KIND INCLUDING WARRANTIES OF
MERCHANTABILITY, NONINFRINGEMENT, OR FITNESS FOR A 
PARTICULAR PURPOSE.  Intel does not warrant or assume 
responsibility for the accuracy or completeness of any 
information, text, graphics, links or other items contained
within the Software.

LIMITATION OF LIABILITY. IN NO EVENT SHALL INTEL OR ITS 
SUPPLIERS BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING, 
WITHOUT LIMITATION, LOST PROF¬ITS, BUSINESS INTERRUPTION, 
OR LOST INFORMATION) ARISING OUT OF THE USE OF OR IN¬
ABILITY TO USE THE SOFTWARE, EVEN IF INTEL HAS BEEN 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. SOME 
JURISDICTIONS PROHIBIT EXCLUSION OR LIMITA¬TION OF 
LIABILITY FOR IMPLIED WARRANTIES OR CONSEQUENTIAL OR 
INCIDENTAL DAMAGES, SO THE ABOVE LIMITA¬TION MAY NOT APPLY
TO YOU. YOU MAY ALSO HAVE OTHER LEGAL RIGHTS THAT VARY FROM
JURISDICTION TO JURISDICTION.
 
TERMINATION OF THIS AGREEMENT. Intel may terminate this 
Agreement at any time if you violate its terms. Upon 
termination, you will immediately destroy the Software or
return all copies of the Software to Intel. 

APPLICABLE LAWS. Claims arising under this Agreement shall
be governed by the laws of California, excluding its 
principles of conflict of laws and the United Nations
Convention on Contracts for the Sale of Goods. You may not 
export the Software in violation of applicable export laws
and regulations. Intel is not obligated under any other 
agreements unless they are in writing and signed by an 
authorized representative of Intel.

GOVERNMENT RESTRICTED RIGHTS. The Software is provided with
"RESTRICTED RIGHTS." Use, duplication, or disclosure by the
Government is subject to restrictions as set forth in 
FAR52.227-14 and DFAR252.227-7013 et seq. or their 
successors. Use of the Software by the Government 
constitutes acknowledg¬ment of Intel's proprietary rights
therein. Contractor or Manufacturer is Intel Corporation,
2200 Mission College Blvd., Santa Clara, CA 95052.

SLA/OEM/IHV/RBK/ April 23, 2004
***********************************************************
* DISCLAIMER
***********************************************************
Intel is making no claims of usability, efficacy or 
warranty.The INTEL SOFTWARE LICENSE AGREEMENT contained 
herein completely defines the license and use of this 
software.
***********************************************************
Information in this document is provided in connection with
Intel products. Except as expressly stated in the INTEL
SOFTWARE LICENSE AGREEMENT contained herein, no license,
express or implied, by estoppel or otherwise, to any
intellectual property rights is granted by this document.
Except as provided in Intel's Terms and Conditions of Sale
for such products, Intel assumes no liability whatsoever,
and Intel disclaims any express or implied warranty,
relating to sale and/or use of Intel products, including
liability or warranties relating to fitness for a 
particular purpose, merchantability or infringement of any
patent, copyright or other intellectual property right. 
Intel products are not intended for use in medical, 
lifesaving, or life-sustaining applications.

***********************************************************
* Intel Corporation disclaims all warranties and 
* liabilities for the use of this document, the software 
* and the information contained herein, and assumes no
* responsibility for any errors which may appear in this
* document or the software, nor does Intel make a 
* commitment to update the information or software 
* contained herein. Intel reserves the right to make 
* changes to this document or software at any time, without
* notice.
***********************************************************

* Other names and brands may be claimed as the property of 
others.

Copyright (c) Intel Corporation, 1998-2006<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
