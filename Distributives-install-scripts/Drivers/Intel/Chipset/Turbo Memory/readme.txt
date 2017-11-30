************************************************************************

Intel(R) Turbo Memory Driver

1.10.0 PV Release

July 2009

************************************************************************

INFORMATION IN THIS DOCUMENT IS PROVIDED IN CONNECTION WITH 
INTEL(R) PRODUCTS.  NO LICENSE, EXPRESS OR IMPLIED, BY ESTOPPEL
OR OTHERWISE, TO ANY INTELLECTUAL PROPERTY RIGHTS IS GRANTED
BY THIS DOCUMENT. EXCEPT AS PROVIDED IN INTEL'S TERMS AND 
CONDITIONS OF SALE FOR SUCH PRODUCTS, INTEL ASSUMES NO LIABILITY
WHATSOEVER, AND INTEL DISCLAIMS ANY EXPRESS OR IMPLIED WARRANTY,
RELATING TO SALE AND/OR USE OF INTEL PRODUCTS INCLUDING LIABILITY 
OR WARRANTIES RELATING TO FITNESS FOR A PARTICULAR PURPOSE, 
MERCHANTABILITY, OR INFRINGEMENT OF ANY PATENT, COPYRIGHT OR 
OTHER INTELLECTUAL PROPERTY RIGHT. Intel products are not intended
for use in medical, life saving, or life sustaining applications.

Intel may make changes to specifications and product descriptions
at any time, without notice.

Designers must not rely on the absence or characteristics of any 
features or instructions marked "reserved" or "undefined." 
Intel reserves these for future definition and shall have no 
responsibility whatsoever for conflicts or incompatibilities
arising from future changes to them.

Intel(R) Turbo Memory technology may contain design defects or errors 
known as errata which may cause the product to deviate from published
specifications. Current characterized errata are available on request.
Contact your local Intel sales office or your distributor to obtain
the latest specifications and before placing your product order.

Intel and the Intel logo are trademarks or registered trademarks of
Intel Corporation or its subsidiaries in the United States and
other countries.

*Other names and brands may be claimed as the property of others.
Copyright (C) 2006 - 2009, Intel Corporation. All rights reserved.

****************************************************************************
*    Intel is making no claims of usability, efficacy or 
*    warranty. The INTEL SOFTWARE LICENSE AGREEMENT contained
*    herein completely defines the license and use of this 
*    software.
****************************************************************************


****************************************************************************
*    CONTENTS OF THIS DOCUMENT
****************************************************************************

This document contains the following sections:

1.   Overview
2.   System Requirements
3.   Language Support
4.   Determining support for Intel(R) Matrix Storage Manager and
     Intel(R) Turbo Memory
5.   Installing the Software
6.   Verifying Installation of the Software
7.   Verifying Windows ReadyBoost* and Windows ReadyDrive* status
8.   Manually enabling/disabling Windows ReadyBoost and Windows
     ReadyDrive
9.   Intel(R) User Pinning Software
10.  Identifying the Software Version Number
11.  Uninstalling the Software

****************************************************************************
* 1 OVERVIEW
****************************************************************************

This document describes in detail the correct steps to follow when
installing driver support for Intel(R) Turbo Memory, including operating
system and motherboard configuration requirements.

****************************************************************************
* 2 SYSTEM REQUIREMENTS
****************************************************************************

1.   The system must be 1 of the following systems, and have the correct
       version of the Intel(R) Turbo Memory Hardware:
     - Intel(R) Mobile 965 Express Chipset Family Platforms supporting
       AHCI Mode
     - Intel(R) 3-Series Chipset Platforms supporting AHCI or RAID Mode
     - Mobile Intel(R) 4 Series Express Chipset Platforms supporting AHCI
       or RAID Mode
     - Intel(R) 4 Series Chipsets Platforms supporting AHCI or RAID Mode

2.   The system should contain at least the minimum system 
     memory required by the operating system.  For Microsoft Windows
     Vista* and Microsoft Windows 7*, the recommendation is at least 
     1GB of system memory with an absolute minimum of 512MB. 

3.   The system must be running the following operating system:

     - Microsoft Windows Vista x32 Edition* (SP2)
     - Microsoft Windows Vista x64 Edition* (SP2)
     - Microsoft Windows 7 x32 Edition* (RC)
     - Microsoft Windows 7 x64 Edition* (RC)

     No other operating systems are supported.

4.   For Intel(R) 965 Express Chipset Family Platforms, the system
     must be configured in Enhanced AHCI Mode. Please review motherboard
     BIOS setup documentation on how to configure these modes.

5.   For Intel(R) 3 Series Chipset based Platforms, the system BIOS
     must be placed into AHCI or RAID mode. Please review motherboard BIOS
     setup documentation on how to configure these modes.

6.  For Mobile Intel(R) 4 Series Chipset based Platforms, the system BIOS
     must be placed into AHCI or RAID Mode.  Please review motherboard BIOS
     setup documentation on how to configure these modes.

7.   For Intel(R) 4 Series Chipset based Platforms, the system BIOS must be
     placed into AHCI or RAID Mode.  Please review motherboard BIOS setup
     documentation on how to configure these modes..

****************************************************************************
* 3 LANGUAGE SUPPORT
****************************************************************************

Below is a list of languages (and their abbreviations) for which
Intel(R) Turbo Memory software has been localized.  The language
code is listed in parenthesis after each language.     

     CHS -> Chinese (Simplified)    (0804)
     CHT -> Chinese (Traditional)   (0404)
     ENU -> English (United States) (0409)
     FRA -> French (International)  (040C)
     DEU -> German                  (0407)
     ITA -> Italian                 (0410)
     JPN -> Japanese                (0411)
     KOR -> Korean                  (0412)
     ESP -> Spanish                 (0C0A)

****************************************************************************
* 4 DETERMINING SUPPORT FOR INTEL(R) MATRIX STORAGE MANAGER AND INTEL(R)
    TURBO MEMORY
****************************************************************************

To use this readme effectively, check your system mode.
The easiest way to determine the mode is to identify how 
the Serial ATA controller is presented within the Device
Manager. The following procedure will guide you through 
determining the mode.

1.   On the Start menu, select Control Panel.

2.   Open the 'System' applet (you may first 
     have to select 'Switch to Classic View').

3.   Under the 'Tasks' tab on the left, click on the 
     'Device Manager' option.

     Note:  From this point forward, it will be assumed
            the Device Manager is being viewed in "Devices
            by type" mode.

4.   In the Device Manager, look for an entry named 
     'SCSI and RAID Controllers'.

     If this entry is not present, go to step 6.  Otherwise,
     expand it and look for the following controller:

     - 'Intel(R) ICH8M SATA RAID Controller' 

     If the above controller is present, the system is 
     an ICH8M system in RAID mode.  Intel(R) Turbo Memory
     driver is not supported in this configuration and you 
     should continue to step 8 below.
     
5.   Look for the following controller: 
 
     - 'Intel(R) ICH8R/ICH9R SATA RAID Controller' 
 
     If the above controller is present, the system is an 
     ICH9R system in RAID mode.  Intel(R) Turbo Memory 
     driver is supported in this configuration and you 
     should continue to Section 5.

6.    From the Device Manager, look for an entry named 
     'IDE ATA/ATAPI controllers'. If this entry is 
     present, expand it and look for the following
     controllers:

     - 'Intel(R) 82801HEM/HBM SATA AHCI Controller'
     
     - 'Intel(R) ICH9M-E/M SATA AHCI Controller'

     If one of the above controllers is present, the system is
     in AHCI mode and the Intel(R) Matrix Storage Manager
     is already installed.  Proceed to Section 5.

7.   Look for the following controller:

     - 'Standard AHCI 1.0 Serial ATA Controller'    
      
     If the above controller is present, the system is 
     in AHCI mode and has been installed in Microsoft 
     Native AHCI Mode.  Proceed to Section 5.
 
8.   Your system does not appear to be running in AHCI mode.
     No other modes are supported by the Intel(R) Matrix
     Storage Manager driver and the Intel(R) Turbo Memory 
     driver.

     If you believe that your system is running in AHCI mode 
     and you do not see any of the controllers listed above, 
     you may choose to contact your system manufacturer or 
     place of purchase for assistance.

****************************************************************************
* 5  INSTALLING THE SOFTWARE
****************************************************************************

----------------------------------------------------------------------------
5.1  General Installation Notes
----------------------------------------------------------------------------

1.   This driver package will conditionally install both the
     Intel(R) Matrix Storage Manager and the Intel(R) Turbo Memory
     driver.

2)   The installer supports an over install from a previous version of
     the Intel(R) Turbo Memory Driver package.

3)   The installer will over install any version of the Intel(R) Matrix
     Storage Manager previously installed on the system, as each release
     of Intel(R) Turbo Memory is validated with a specific version of the
     Intel Matrix Storage Manager.

4.   Refer to Section 6 on how to verify that the Intel(R) Matrix
     Storage Manager and the Intel(R) Turbo Memory drivers are correctly
     installed.

5.   Refer to Section 7 on how to verify that Windows ReadyBoost and, if
     applicable, Windows ReadyDrive are correctly enabled.

6.   Refer to Section 8 to enable Windows ReadyBoost and, if applicable,
     Windows ReadyDrive if either are unexpectedly disabled. 

----------------------------------------------------------------------------
5.2  Windows Automated Installer* Installation from Hard
     Drive or CD-ROM
----------------------------------------------------------------------------
    
1.   Download the Intel(R) Turbo Memory Driver Package.  Double-click
     to begin the setup process.

2.   The 'Welcome to the Setup Program' window appears. Click on 
     the 'Next' button to continue.

3.   The 'License Agreement' window appears. If you agree to these 
     terms, click on the 'Yes' button to continue.

4.   The Readme File Information appears.  Click on 'Next'.

5.   The Setup Progress window appears and the setup proceeds.

6.   For unsigned drivers (non-PV), the Windows Security popup appears
     asking whether you like to install this device software.  The user
     has the option to select the 'Always trust software from Intel
     Corporation' check box.  Click on Install' to install the
     Intel(R) Turbo Memory Driver and the Intel(R) Matrix Storage
     Driver.  Realize that not checking this box correctly will cause
     installation to fail and exit.  

7.   The Windows Automated Installer* wizard Complete window states 
     that installation is complete and to click Next to continue.  
     Click on 'Next' to continue.

8.   The Windows Automated Installer* wizard states that the system 
     should be restarted.  Click 'Finish' to continue and restart
     the system.

     Note: On certain systems, after completing step 8, the system 
           might re-enumerate and reinstall the HDD controller after
           the installation of the Intel(R) Matrix Storage Driver.  In
           these circumstances, the user may be asked to restart the
           system one more time.

9.   Refer to Section 6 on how to verify that the Intel(R) Matrix
     Storage Manager and the Intel(R) Turbo Memory drivers are correctly
     installed.

10.  Refer to Section 7 on how to verify that Windows ReadyBoost and
     Windows ReadyDrive are correctly configured.

11.  Refer to Section 8 to enable Windows ReadyBoost and, if applicable,
     Windows ReadyDrive if either are unexpectedly disabled. 

----------------------------------------------------------------------------
5.3  Windows INF-based Installation of Intel(R) Matrix Storage
     Driver or Intel(R) Turbo Memory Driver, from any
     storage device.  
----------------------------------------------------------------------------

     Note: Use this method to install the drivers if and only 
           if the Windows Automated Installer* mechanism does not 
           work.

     Note: Automatic DFOROM Update is a feature of Intel(R) Turbo
           Memory that requires installation via the installer to operate
           properly.  If a DFOROM-Driver mismatch exists on a given
           platform that supports the Windows ReadyDrive feature due to
           Intel(R) Turbo Memory support, Windows ReadyDrive will not get
           enabled on that platform until the DFOROM is properly updated
           via a re-installation of the Driver Package.

     Note: It is expected the provided installation zip file is extracted
           and used for all manual install procedures, as this will allow
           the user to quickly know where the applicable files are located.

1.   Open Device Manager (Refer to Section 4 on how to open the
     Device Manager)

2.   To manually install the Intel(R) Matrix Storage Manager
     on a Montevina platform or on platforms supporting the Intel(R)
     Mobile 965 Express Chipset Family, conduct the following 
     steps:

     2a. Expand the IDE ATA/ATAPI Controllers Entry
     2b. Right click on 'Standard AHCI 1.0 Serial ATA Controller'
         and select 'Update Driver Software'
     2c. In the window that asks 'How do you want to search for
         driver software', click on 'Browse my computer for driver
         software'
     2d. In the window 'Browse for driver software on your
         computer', set the 'Search for driver software in
         this location:' window to the appropriate root location
         of the extracted zip, make sure the 'Include
         Subfolders' box is checked, then press 'Next'.
     2e. Windows might give a Security warning that 'The publisher
         could not be verified.  Are you sure you want to install this
         device software?'  Click on 'Install'.
     2f. A window will be displayed with the message that 'Windows
         has successfully updated your driver software'.  Click
         on 'Close'.
     2g. Windows may pop up a 'System Settings Change' window asking
         the user to restart the computer.  Click on 'Yes' if it
         does appear.  Otherwise, close all windows and perform
         a manual restart.
     2h. To verify that the driver was loaded correctly refer to 
         Section 6. 
     2I. Go on to step 5 of this section to manually install the
         Intel(R) Turbo Memory Driver.

     Note: On certain systems, the system might enumerate and
           reinstall the HDD controller after the installation of 
           the Intel(R) Matrix Storage Driver.  In these circumstances,
           the user may be asked to restart the system one more time.

3.   To manually install the the Intel(R) Matrix Storage Manager
     on platforms supporting the Intel(R) Series 3 Express Chipset
     Family in AHCI mode, conduct the following steps:

     3a. Expand the IDE ATA/ATAPI Controllers Entry
     3b. Right click on 'Standard AHCI 1.0 Serial ATA Controller'
         and select 'Update Driver Software'
     3c. In the window that asks 'How do you want to search for
         driver software', click on 'Browse my computer for driver
         software'
     3d. In the window 'Browse for driver software on your
         computer', set the 'Search for driver software in
         this location:' window to the appropriate root location
         of the extracted zip, make sure the 'Include
         Subfolders' box is checked, then press 'Next'.
     3e. Windows might give a Security warning that 'The publisher
         could not be verified.  Are you sure you want to install this
         device software?'  Click on 'Install'.
     3f. A window will be displayed with the message that 'Windows
         has successfully updated your driver software'.  Click
         on 'Close'.
     3g. Windows may pop up a 'System Settings Change' window asking
         the user to restart the computer.  Click on 'Yes' if it
         does appear.  Otherwise, close all windows and perform
         a manual restart.
     3h. To verify that the driver was loaded correctly refer to 
         Section 6. 
     3I. Go on to step 5 of this section to manually install the
         Intel(R) Turbo Memory Driver.

     Note: On certain systems, the system might enumerate and
           reinstall the HDD controller after the installation of 
           the Intel(R) Matrix Storage Driver.  In these circumstances,
           the user may be asked to restart the system one more time.

4.   To manually install the the Intel(R) Matrix Storage Manager
     on platforms supporting the Intel(R) Series 3 Express Chipset
     Family in RAID mode, conduct the following steps:

     4a. Expand the Storage Controllers Entry
     4b. Right click on 'Intel(R) ICH8R/ICH9R SATA RAID Controller'
         and select 'Update Driver Software'
     4c. In the window that asks 'How do you want to search for
         driver software', click on 'Browse my computer for driver
         software'
     4d. In the window 'Browse for driver software on your
         computer', set the 'Search for driver software in
         this location:' window to the appropriate root location
         of the extracted zip, make sure the 'Include
         Subfolders' box is checked, then press 'Next'.
     4e. Windows might give a Security warning that 'The publisher
         could not be verified.  Are you sure you want to install this
         device software?'  Click on 'Install'.
     4f. A window will be displayed with the message that 'Windows
         has successfully updated your driver software'.  Click
         on 'Close'.
     4g. Windows may pop up a 'System Settings Change' window asking
         the user to restart the computer.  Click on 'Yes' if it
         does appear.  Otherwise, close all windows and perform
         a manual restart.
     4h. To verify that the driver was loaded correctly refer to 
         Section 6. 
     4I. Go on to step 5 of this section to manually install the
         Intel(R) Turbo Memory Driver.

     Note: On certain systems, the system might enumerate and
           reinstall the HDD controller after the installation of 
           the Intel(R) Matrix Storage Driver.  In these circumstances,
           the user may be asked to restart the system one more time.

5.   To manually install the Intel(R) Turbo Memory Driver on all
     supported platforms, conduct the following steps:

     5a. Look for the device named 'PCI Memory Controller" with a
         yellow exclamation mark under 'Other devices'.
     5b. Right click on this device and select 'Update Driver 
         Software'
     5c. In the window that asks 'How do you want to search for
         driver software', click on 'Browse my computer for driver
         software'
     5d. In the window 'Browse for driver software on your
         computer', set the 'Search for driver software in
         this location:' window to the appropriate root location
         of the extracted zip, make sure the 'Include
         Subfolders' box is checked, then press 'Next'.
     5e. Windows may give a Security warning that 'The publisher
         could not be verified.  Are you sure you want to install this
         device software?'  Click on 'Install'.
     5f. A window will be displayed with the message that 'Windows
         has successfully updated your driver software'.  Click
         on 'Close'.
     5g. Windows may pop up a 'System Settings Change' window asking
         the user to restart the computer.  Click on 'Yes' if it
         does appear.  Otherwise, close all windows and perform
         a manual restart.
     5h. Refer to Section 6 on how to verify that the Intel(R) Turbo
         Memory driver is correctly installed.
     5i  Refer to Section 7 on how to verify that Windows ReadyBoost
         and, if applicable, Windows ReadyDrive are correctly enabled.
     5j. Refer to Section 8 to enable Windows ReadyBoost and, if
         applicable, Windows ReadyDrive if either are unexpectedly
         disabled. 

----------------------------------------------------------------------------
5.4  F6-Floppy installation of Intel(R) Matrix Storage Driver.
----------------------------------------------------------------------------
    
     Note:  Help to install the Intel(R) Matrix Storage Manager via the F6
            process will not be provided as the supported operating systems
            do not require this installation procedure for either AHCI or
            RAID Mode.

****************************************************************************
* 6. VERIFYING INSTALLATION OF THE SOFTWARE
****************************************************************************

1.   Open Device Manager (Refer to Section 4 on how to open the
     Device Manager)

2.   To determine the Intel(R) Matrix Storage Manager Driver version 
     on platforms supporting the Intel(R) Mobile 965 Express Chipset
     Family, conduct the following steps:
     2a. Expand the 'IDE ATA/ATAPI Controllers' entry
     2b. Right-click on 'Intel(R) 82801HEM/HBM SATA AHCI Controller'
     2c. Select 'Properties'
     2d. Select the 'Driver' tab
     2e. Select the 'Driver Details' button
     2f. If the 'iaStor.sys' file is displayed, then driver 
         installation was successful. Close Device Manager.

3.   To determine the Intel(R) Matrix Storage Manager Driver version 
     on Montevina platforms, conduct the following steps:
     2a. Expand the 'IDE ATA/ATAPI Controllers' entry
     2b. Right-click on 'Intel(R) ICH9M-E SATA AHCI Controller'
     2c. Select 'Properties'
     2d. Select the 'Driver' tab
     2e. Select the 'Driver Details' button
     2f. If the 'iaStor.sys' file is displayed, then driver 
         installation was successful. Close Device Manager.

4.   To determine if the Intel(R) Matrix Storage Manager Driver version
     on platforms supporting the Intel(R) 3 Series Chipsets, conduct
     the following steps:
     3a. Expand the 'IDE ATA/ATAPI Controllers' entry
     3b. Right-click on 'Intel(R) ICH9R SATA AHCI Controller'
     3c. Select 'Properties'
     3d. Select the 'Driver' tab
     3e. Select the 'Driver Details' button
     3f. If the 'iaStor.sys' file is displayed, then driver 
         installation was successful. Close Device Manager.

5.   To determine if the Intel(R) Matrix Storage Manager Driver version
     on platforms supporting the Intel(R) 3 Series Chipsets, conduct
     the following steps:
     4a. Expand the 'Storage Controllers' entry
     4b. Right-click on 'Intel(R) ICH8R/ICH9R SATA RAID Controller'
     4c. Select 'Properties'
     4d. Select the 'Driver' tab
     4e. Select the 'Driver Details' button
     4f. If the 'iaStor.sys' file is displayed, then driver 
         installation was successful. Close Device Manager.

6.   To determine the Intel(R) Turbo Memory Driver Version on all
     suppported platforms, conduct the following steps:
     5a. Expand the 'Storage Controllers' entry
     5b. Right-click on 'Intel(R) Turbo Memory Controller' 
     5c. Select 'Properties'
     5d. Select the 'Driver' tab
     5e. Select the 'Driver Details' button
     5f. If the 'iaNvStor.sys' file is displayed, then driver 
         installation was successful. Close Device Manager.

****************************************************************************
* 7  VERIFYING WINDOWS READYBOOST AND WINDOWS READYDRIVE STATUS
****************************************************************************

     Note:  This section requires that the Intel(R) Turbo Memory
            Console Application is loaded onto the system.

1.   Execute the Intel(R) Turbo Memory Console Application by selecting
     it in the Start Menu.  To open, select Start -> Intel(R) Turbo
     Memory -> Intel(R) Turbo Memory Console.

2.   The application displays the status for both Windows ReadyDrive and
     Windows ReadyBoost.

     2a. Windows ReadyBoost can have a status of enabled or disabled.  This
         feature will not show an enabled status until the operating system
         has enabled it (normally this takes less than 1 minute after the
         operating system has fully loaded).   See the release notes for
         more details.

     2b. Windows ReadyDrive can have a status of enabled or
         disabled. 

     Note:  The installation process should correctly configure both
            features, so the checkboxes in the console should never be
            touched by the end user.  If the system happens to get
            incorrectly configured during installation time, refer to
            section 8 to manually enable Windows ReadyBoost and, if
            applicable, Windows ReadyDrive.

****************************************************************************
* 8  MANUALLY ENABLING/DISABLING WINDOWS READYBOOST AND WINDOWS READYDRIVE
****************************************************************************

     Note:  This section requires that the Intel(R) Turbo Memory
            Console Application is loaded onto the system.

1.   Execute the Intel(R) Turbo Memory Console Application by selecting
     it in the Start Menu.  To open, select Start -> Intel(R) Turbo
     Memory -> Intel(R) Turbo Memory Console.

2.   The application displays the status for both Windows ReadyBoost and
     Windows ReadyDrive as supported by Intel(R) Turbo Memory Technology.

3.   If either Windows ReadyBoost or Windows ReadyDrive is disabled,
     the user has the option to set either feature to enabled if the
     checkbox for the feature is not grayed out.  for any checkbox that
     is selectable:

     3a.  Click on the "Enable ReadyDrive" or "Enable ReadyBoost" check 
          box.
     3b.  Close the console.
     3c.  Reboot the system.
     3d.  The features checked in the console will be enabled upon
          next boot.

4.   If either Windows ReadyBoost or Windows ReadyDrive is enabled,
     the user has the option to set either feature to disabled if the
     checkbox for the feature is not grayed out.  for any checkbox that
     is selectable:

     4a.  Uncheck the "Enable ReadyDrive" or "Enable ReadyBoost" check 
          box.
     4b.  Close the GUI.
     4c.  Reboot the system.
     4d.  The features un-checked in the console will be disabled upon
          next boot.

     Note:  For systems that support the Windows ReadyDrive feature,
            unchecking the box will not fully disable the feature.  See
            the release notes for more details.

****************************************************************************
* 9  INTEL USER PINNING SOFTWARE
****************************************************************************

Intel supports the User Pinning Graphical User Interface with Intel(R)
Turbo Memory module of size 4 GB.  The Intel(R) Turbo Memory Driver Package
will automatically detect the presence of a 4 GB module and install
the User Pinning GUI.  The User Pinning GUI comes with a comprehensive 
CHM based help file that gives an overview of User Pinning and steps to
pin and unpin user applications into the Non-volatile cache. To open the 
help file launch the User Pinning GUI (Start Menu->All Programs->Intel(R) 
Turbo Memory->ITMDashboard) and click on the question mark icon located 
on the bottom right corner of the User Pinning GUI. Please refer to this 
help file for further details on User Pinning.

****************************************************************************
* 10 IDENTIFYING THE SOFTWARE VERSION NUMBER
****************************************************************************

1.   Open Device Manager (Refer to Section 4 on how to open the
     Device Manager)

2.   To determine the Intel(R) Matrix Storage Manager Driver version 
     on platforms supporting the Intel(R) Mobile 965 Express Chipset
     Family, conduct the following steps:
     2a. Expand the 'IDE ATA/ATAPI Controllers' entry
     2b. Right-click on 'Intel(R) 82801HEM/HBM SATA AHCI Controller'
     2c. Select 'Properties'
     2d. Select the 'Driver' tab
     2e. The software version should be displayed after the
         'Driver Version' string.

3.   To determine the Intel(R) Matrix Storage Manager Driver version 
     on Montevina platforms, conduct the following steps:
     2a. Expand the 'IDE ATA/ATAPI Controllers' entry
     2b. Right-click on 'Intel(R) ICH9M-E SATA AHCI Controller'
     2c. Select 'Properties'
     2d. Select the 'Driver' tab
     2e. The software version should be displayed after the
         'Driver Version' string.

4.   To determine if the Intel(R) Matrix Storage Manager Driver version
     on platforms supporting the Intel(R) 3 Series Chipsets, conduct
     the following steps:
     3a. Expand the 'IDE ATA/ATAPI Controllers' entry
     3b. Right-click on 'Intel(R) ICH9R SATA AHCI Controller'
     3c. Select 'Properties'
     3d. Select the 'Driver' tab
     3e. The software version should be displayed after the
         'Driver Version' string.

5.   To determine if the Intel(R) Matrix Storage Manager Driver version
     on platforms supporting the Intel(R) 3 Series Chipsets, conduct
     the following steps:
     4a. Expand the 'Storage Controllers' entry
     4b. Right-click on 'Intel(R) ICH8R/ICH9R SATA RAID Controller'
     4c. Select 'Properties'
     4d. Select the 'Driver' tab
     4e. The software version should be displayed after the
         'Driver Version' string.

6.   To determine the Intel(R) Turbo Memory Driver Version on all
     supported platforms, conduct the following steps:
     5a. Expand the 'Storage Controllers' entry
     5b. Right-click on 'Intel(R) Turbo Memory Controller' 
     5c. Select 'Properties'
     5d. Select the 'Driver' tab
     5e. The software version should be displayed after the
         'Driver Version' string.

****************************************************************************
* 11 UNINSTALLING THE SOFTWARE
****************************************************************************

1.   On the Start menu, select the Control Panel.

2.   Open the 'Programs and Features' applet (you may first 
     have to select 'Switch to Classic View').

3.   Select 'Intel(R) Turbo Memory and Intel(R) Matrix Storage Manager'.

4.   Right click, select 'Uninstall/Change' and execute.

5.   The Windows Automated Uninstaller* wizard opens with message
     'Welcome to the Uninstallation Program'.  Click on 'Next'.

6.   The Windows Automated Uninstaller* wizard executes and uninstalls 
     the software.  Click on 'Next' to continue.

7.   The Windows Automated UnInstaller* wizard states that the system 
     should be restarted.  Click 'Finish' to continue and restart the 
     system.
     
****************************************************************************
INTEL SOFTWARE LICENSE AGREEMENT
****************************************************************************

INTEL SOFTWARE LICENSE AGREEMENT (Organizational Use)

IMPORTANT - READ BEFORE COPYING, INSTALLING OR USING. 

Do not use or load this software and any associated materials (collectively, the "Software") until you have carefully read the following terms and conditions. By loading or using the Software, you agree to the terms of this Agreement. If you do not wish to so agree, do not install or use the Software.

LICENSE. This Software is licensed for use only in conjunction with Intel component products.  Use of the Software in conjunction with non-Intel component products is not licensed hereunder. You may copy the Software onto your organization's computers for your organization's use, and you may make a reasonable number of back-up copies of the Software, subject to these conditions: 
1. You may not copy, modify, rent, sell, distribute or transfer any part of the Software, except as provided in this Agreement, and you agree to prevent unauthorized copying of the Software.
2. You may not reverse engineer, decompile or disassemble the Software. 
3. You may not sublicense the Software.
4. The Software may contain the software or other property of third party suppliers, some of which may be identified in, and licensed in accordance with, an enclosed "license.txt" file or other text or file. 

OWNERSHIP OF SOFTWARE AND COPYRIGHTS. Title to all copies of the Software remains with Intel or its suppliers. The Software is copyrighted and protected by the laws of the United States and other countries, and international treaty provisions. You may not remove any copyright notices from the Software.  Intel may make changes to the Software, or to items referenced therein, at any time and without notice, but is not obligated to support or update the Software. Except as otherwise expressly provided, Intel grants no express or implied right under Intel patents, copyrights, trademarks or other intellectual property rights. You may transfer the Software only if the recipient agrees to be fully bound by these terms and if you retain no copies of the Software.

LIMITED MEDIA WARRANTY.  If the Software has been delivered by Intel on physical media, Intel warrants the media to be free from material physical defects for a period of (90) ninety days after delivery by Intel. If such a defect is found, return the media to Intel for replacement or alternate delivery of the Software, as Intel may select.

EXCLUSION OF OTHER WARRANTIES. EXCEPT AS PROVIDED ABOVE, THE SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED WARRANTY OF ANY KIND, INCLUDING WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT OR FITNESS FOR A PARTICULAR PURPOSE.  Intel does not warrant or assume responsibility for the accuracy or completeness of any information, text, graphics, links or other items contained within the Software.

LIMITATION OF LIABILITY. IN NO EVENT SHALL INTEL OR ITS SUPPLIERS BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, LOST PROFITS, BUSINESS INTERRUPTION OR LOST INFORMATION) ARISING OUT OF THE USE OF OR THE INABILITY TO USE THE SOFTWARE, EVEN IF INTEL HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. SOME JURISDICTIONS PROHIBIT EXCLUSION OR LIMITATION OF LIABILITY FOR IMPLIED WARRANTIES OR CONSEQUENTIAL OR INCIDENTAL DAMAGES, SO THE ABOVE LIMITATION MAY NOT APPLY TO YOU. YOU MAY ALSO HAVE OTHER LEGAL RIGHTS THAT VARY FROM JURISDICTION TO JURISDICTION. 

TERMINATION OF THIS AGREEMENT. Intel may terminate this Agreement at any time if you violate its terms. Upon termination, you will immediately destroy the Software or return all copies of the Software to Intel.
 
APPLICABLE LAWS. Claims arising under this Agreement shall be governed by the laws of California, excluding its principles of conflict of laws and the United Nations Convention on Contracts for the Sale of Goods. You may not export the Software in violation of applicable export laws and regulations. Intel is not obligated under any other agreements, unless they are in writing and signed by an authorized representative of Intel.

GOVERNMENT RESTRICTED RIGHTS. The Software is provided with "RESTRICTED RIGHTS." Use, duplication or disclosure by the Government is subject to restrictions as set forth in FAR52.227-14 and DFAR252.227-7013 et seq. or their successors. Use of the Software by the Government constitutes acknowledgment of Intel's proprietary rights therein. Contractor or Manufacturer is Intel Corporation, 2200 Mission College Blvd., Santa Clara, CA 95052.
