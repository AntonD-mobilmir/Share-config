Intel(R) Network Connections Software Version 18.7 Release Notes
================================================================
August 19, 2013

This release includes software and drivers for Intel(R) PRO/100,
Intel(R) Gigabit, and Intel(R) 10GbE network adapters and integrated 
network connections.

Contents
========

- What's New in This Release
- Operating System Support
- Installing Drivers and Intel(R) PROSet for Windows* Device Manager
- User Guides
- Intel Fiber Optic Adapters
- Saving and Restoring Adapter Settings in Microsoft Windows operating systems
- Teaming Notes
- Jumbo Frames
- Power Management and System Wake
- Microsoft* Windows* 8.1 and Windows Server* 2012 R2 Notes
- Microsoft* Windows* 8 and Windows Server* 2012 Notes
- Microsoft* Windows* 7 and Windows Server* 2008 R2 Notes
- Novell* NetWare* Notes
- Intel(R) 82562V and 82562GT 10/100 Network Connection Notes
- Intel(R) 10GbE Network Adapter Notes
- Quad Port Server Adapter Notes
- Known Issues
- Customer Support


What's New in This Release
==========================

- Support for the Intel(R) Ethernet Converged Network Adapter X520-Q1
- Support for the Intel(R) Ethernet Controller X540
- Support for the Intel(R) Ethernet Converged Network Adapter X520-4
- Support for configuration via Windows PowerShell


Operating System Support
========================

The most recent software and drivers for unsupported operating systems 
can be found on the Intel Customer Support website at 
http://www.intel.com/support/go/network/adapter/home.htm

Some older Intel(R) Ethernet Adapters do not have full software support for 
the most recent versions of Microsoft Windows*. Many older Intel Ethernet 
Adapters have base drivers supplied by Microsoft Windows. Lists of supported 
devices per OS are available at: 
http://www.intel.com/support/go/network/adapter/nicoscomp.htm


Installing Drivers and Intel(R) PROSet for Windows* Device Manager
==================================================================

You must have administrator rights to install or use Intel PROSet for 
Windows Device Manager. Intel recommends the following procedure for installing
drivers:
 1) Cancel any Found New Hardware Wizard screens that open.
 2) Start the autorun located on the CD or in your download directory.
 3) Click "Install Drivers and Software" and follow the instructions in the
    install wizard.

Intel(R) PROSet functionality is integrated with the Windows Device 
Manager. To configure Intel(R) Ethernet Adapters and Controllers, 
open the Windows Device Manager. Do not open adapter, team, or VLAN 
properties from the network control panel as you may be prompted to 
reboot your system.

You must upgrade PROSet when upgrading drivers. Failure to do so will 
result in instability and missing tabs in Windows Device Manager.

For software and driver versions prior to Release 16.2, if you have Fibre Channel 
over Ethernet (FCoE) boot enabled on any devices in the system, you will not be 
able to upgrade your drivers. You must disable FCoE boot before upgrading your 
ethernet drivers. This issue is resolved in Release 16.2 and beyond.

Intel PROSet for Windows* Device Manager is not supported on the 
following devices
----------------------------------------------------------------
* Intel(R) 82552 10/100 Network Connection 
* Intel(R) 82567V-3 Gigabit Network Connection

Intel PROSet fails to install
-----------------------------
A possible cause could be the Windows Modules Installer service is disabled. 
The installer for Intel PROSet requires this service. You can enable this 
service from the Administrative Tools -> Component Services control panel.


User Guides
===========

Several user guides for Intel Network Connections are available for 
this product.  You may access them in the following ways: 
- On Windows-based systems, start the autorun program on the Intel CD, 
  then click "View User Guides".
- Double-click "index.htm" located in the root of the Intel CD.
- Go to http://support.intel.com. 

User Guide Known Issues
-----------------------
  "A script on this page is causing Microsoft Internet Explorer 
  to run slowly" error
  -------------------------------------------------------------
  Upgrading to Microsoft Internet Explorer version 6 or later will resolve
  this issue.


Intel Fiber Optic Adapters
==========================

Caution: The fiber optic ports may utilize Class 1 or Class 1M laser 
devices. Do not stare into the end of a fiber optic connector 
connected to a "live" system.  Do not use optical instruments to 
view the laser output. Using optical instruments increases eye hazard.  
Laser radiation is hazardous and may cause eye injury.  To inspect a 
connector, receptacle or adapter end, be sure that the fiber optic 
device or system is turned off, or the fiber cable is disconnected 
from the "live" system. 

The Intel Gigabit and 10GbE network adapters with fiber optic connections
operate only at their native speed and only at full-duplex.  Therefore
you do not need to make any adjustments.  Use of controls or
adjustments or performance of procedures other than those specified
herein may result in hazardous radiation exposure.  The laser module 
contains no serviceable parts.  


Saving and Restoring Adapter Settings in Microsoft Windows
operating systems
==========================================================

You can save and then restore adapter settings through the script 
SavResDX.vbs.  Intel PROSet is required for SavResDX.vbs to function 
correctly. The Restore operation requires the same operating system 
as when the configuration was saved.

  Major Operating system upgrades and saving your configuration
  -------------------------------------------------------------
  Your network device settings, including teams and VLANs, are not saved
  when you upgrade your operating system. You must reinstall your network
  drivers and software and reconfigure your network devices. This applies
  for upgrading from one version of Microsoft Windows to another 
  (i.e., upgrading from Windows 7 to Windows 8), not applying a service
  pack.


Teaming Notes
=============

Intel devices that are not supported by Intel(R) PROSet can still be added to 
teams. These devices are supported by the Multi-Vendor Teaming functionality 
of ANS teams.

Microsoft Server 2012 NIC Teaming (LBFO)
----------------------------------------
Intel(R) Advanced Network Services (ANS) teaming and VLANs are incompatible 
with Microsoft Server 2012 NIC Teaming (LBFO). Do not create an LBFO team 
using ports that are part of an ANS team or ANS VLAN.

DCB is not compatible with Microsoft Server 2012 NIC Teaming (LBFO)
------------------------------------------------------------------- 
Data Center Bridging (DCB) is incompatible with Microsoft Server 2012 NIC 
Teaming (LBFO). Do not create an LBFO team using Intel 10G ports when DCB is 
installed. Do not install DCB if Intel 10G ports are part of an LBFO team.
Install failures and persistent link loss may occur if DCB and LBFO are used 
on the same port. Installing Microsoft's Hot fix KB 2818790 will resolve the issue.
This issue only affects Microsoft Windows Server 2012.

RLB is not supported when a team is added to a virtual NIC
----------------------------------------------------------
Virtual NICs cannot be created on a team with Receive Load Balancing enabled.
Receive Load Balancing is automatically disabled if you create a virtual NIC 
on a team.

Team setup requirement
----------------------
Before creating a team, make sure each adapter is configured similarly. Check
each adapter's settings in Intel PROSet. Settings to check include QoS Packet
Tagging, Jumbo Frames, and the various offloads. If team members implement 
Advanced features differently, the team will align the settings with the least 
capable adapter. 

Changing Offload Settings for an Adapter in an ANS Team
-------------------------------------------------------
When you disable an offload setting for an adapter in an ANS team, the team
reloads and the team capabilities are recalculated. As a result, the offload 
setting is disabled for the remaining adapters in the ANS team. 

Intel PROSet does not reflect the fact that the offload setting is disabled 
for the remaining adapters in the team.

If you re-enable the offload setting for the original adapter in the team, 
the settings will not be applied until the system is rebooted or the team 
is reloaded.

IEEE 802.3ad teaming on Cisco trunks
------------------------------------
When implementing 802.3ad teams on Cisco switch ports in trunking mode, 
set the native/untagged VLAN for these ports to ID 1.  Otherwise, you may 
experience traffic loss or lack of failover between aggregators.  See your 
Cisco documentation for information about setting the native VLAN ID.


Teaming Known Issues
--------------------
 
  Unexpected performance drop or disabled ANS team member
  -------------------------------------------------------
  Using non-Intel cmdlets, such as the Set-NetAdapterAdvancedProperty cmdlet
  provided in Microsoft PowerShell*, to change settings for an ANS-teamed 
  adapter may cause the team to stop using that adapter to pass traffic. 
  You may see this as reduced performance or the adapter being disabled 
  in the PROSet Teaming GUI. You can repair the issue by changing the 
  setting back to its previous state, or by removing the adapter from 
  the ANS team and then adding it back.
 
  Network Connections window shows the team as disabled or network
  cable unplugged
  ----------------------------------------------------------------
  After adding a VLAN to the team, this is normal.  The connection
  protocols are now bound to the VLAN on the team. You can configure the
  connection protocols in the Properties for the VLAN.

  Team name doesn't change in Device Manager
  ------------------------------------------
  If you modify a team name from the team property sheet, it may take
  several minutes for the name to change in Device Manager. Closing and
  opening Device Manager will load the new name.

  Removing a teamed adapter from a hot-plug system
  ------------------------------------------------
  When you physically remove an adapter that is part of a team or a VLAN, 
  you must reboot or reload the team/VLAN before using that adapter in the 
  same network. This will prevent Ethernet address conflicts. 

  VLANs remain after team removal
  -------------------------------
  When you remove a team, some of the VLANs bound to that team may remain. 
  You can manually remove the VLANs to correct the issue.

  Changing speed and duplex of adapters in a team
  -----------------------------------------------
  When you add an adapter to a Link Aggregation team using Intel PROSet, 
  make sure that the adapter is running at the same speed and duplex of 
  the other adapters in the team.

  Compatibility notes for Multi Vendor Teaming
  --------------------------------------------
  Attempting to hot-add a non-Intel adapter to a team may cause system 
  instability.  If you do hot-add a non-Intel adapter to a team, make sure 
  you restart the computer or reload the team. 

  IEEE 802.3ad teaming with Foundry switches
  ------------------------------------------
  Foundry switches require an even number of ports in an aggregated link. If 
  you remove an adapter from an 802.3ad team connected to a Foundry switch, 
  make sure you maintain an even number of adapters in the team.


Jumbo Frames and Jumbo Packets
==============================

Jumbo Frames and MACSec are not compatible on the Intel(R) 82579LM and 
Intel(R) 82579V Network Connections. If MACSec is enabled on a platform 
containing either part, you will not be able to enable Jumbo Frames on 
the connection.

Limited Jumbo Frame Size
------------------------
Some Intel gigabit adapters and connections that support Jumbo Frames have a 
frame size limit of 4K bytes. The following device have this limitation: 
 Intel(R) 82577LM Gigabit Network Connection
 Intel(R) 82578DM Gigabit Network Connection

The following devices do not support jumbo frames:
 Intel(R) PRO/1000 Gigabit Server Adapter
 Intel(R) PRO/1000 PM Network Connection
 Intel(R) 82562V 10/100 Network Connection
 Intel(R) 82562GT 10/100 Network Connection
 Intel(R) 82566DM Gigabit Network Connection
 Intel(R) 82566DC Gigabit Network Connection
 Intel(R) 82566DC-2 Gigabit Network Connection
 Intel(R) 82562V-2 10/100 Network Connection
 Intel(R) 82562G-2 10/100 Network Connection
 Intel(R) 82562GT-2 10/100 Network Connection
 Intel(R) 82567LF Gigabit Network Connection
 Intel(R) 82567V Gigabit Network Connection
 Intel(R) 82567LF-2 Gigabit Network Connection
 Intel(R) 82567V-2 Gigabit Network Connection
 Intel(R) 82567LF-3 Gigabit Network Connection
 Intel(R) 82552 10/100 Network Connection 
 Intel(R) 82577LC Gigabit Network Connection
 Intel(R) 82578DC Gigabit Network Connection
 Intel(R) 82567V-3 Gigabit Network Connection
 Intel(R) 82567V-4 Gigabit Network Connection

The Intel PRO/1000 PL Network Connection supports jumbo frames in Microsoft* 
Windows* operating systems only when Intel(R) PROSet for Windows Device 
Manager is installed.


Power Management and System Wake
================================

Not all systems support every wake setting. There may be BIOS or Operating
System settings that need to be enabled for your system to wake up. In 
particular, this is true for Wake from S5 (also referred to as Wake from power off).

Microsoft Windows 7 and Windows Server 2008 R2 do not support Wake on 
directed packet. Systems with these operating systems will not wake on a 
ping or other directed packet.

System does not wake when expected
----------------------------------
Under Microsoft Windows 7 or Windows Server 2008 R2, the system may not wake 
when sent an ARP packet. Forcing your system into Home Networking mode
(instead of work or public mode) will resolve the issue. You can set the 
network mode during install or from the Networking Control Panel.
However, if the network is disconnected and reconnected, and a DHCP server
is not available or if there is no default gateway defined, it appears to 
the operating system that the network is undefined and the OS will reset 
it to public.

Under Microsoft Windows 8 or Windows Server 2012, the system may not wake even 
though Wake on LAN settings are enabled. Disabling Fast Startup in the 
operating system should resolve the issue.

System does not wake on link
----------------------------
On a driver-only installation, if you change 'Wake on Link Settings' to 
Forced and change 'Wake on Magic Packet' and 'Wake on Pattern Match' to Disabled, 
the system may not wake up when expected. In order to "Wake on Link" 
successfully, check the Power Management tab and make sure that "Allow 
this device to wake the computer" is checked.  You may also need to change
'Wake on Magic Packet' or 'Wake on Pattern Match' to Enabled.

On Microsoft* Windows* 7, or later, you must enable Wake on Magic Packet or 
Wake on Pattern Match for Wake on Link to function properly.

Directed Packets may not wake the system
----------------------------------------
On some systems, quad port server adapters may not wake when 
configured to wake on directed packet. If you experience problems 
waking on directed packets, you must configure the adapter to 
use Magic Packets*.

Power Management options are unavailable or missing
---------------------------------------------------
If you install only the base drivers, later install Intel(R) PROSet for 
Windows Device Manager, then remove Intel PROSet, the settings on the Power 
Management tab on the Adapter Property Sheet may be unavailable or missing 
altogether. You must reinstall Intel PROSet to resolve the issue.

Low power link speed slower than expected
-----------------------------------------
If you disable the "Reduce Power During Standby" setting and remove power 
from the system, your system may link at 10Mbps when power is restored, 
instead of 100Mbps or faster. The system will continue to link at 10Mbps 
until the operating system is loaded. This setting will be restored when 
the OS loads.

System Wakes Unexpectedly
-------------------------
On a driver only install, if you uncheck the "Allow this device to bring
the computer out of standby" option on the Power Management tab, the 
adapter will still wake the system from Standby or Hibernate. The "Wake
on Settings" option on the Advanced tab must also be set to Disabled.

Auto Connect Battery Saver (ACBS) enabled NICs do not power up when 
connected back to back
-------------------------------------------------------------------
If you have two systems, both running on batteries and both with 
ACBS-enabled NICs that are in an ACBS state, and you connect them back 
to back, the NICs will not power up. Since both NICs are powered down, 
neither one can generate a link signal to wake the other. Either connect 
AC power to one system or disable ACBS to resolve this issue.

Auto Connect Battery Saver (ACBS) does not function
---------------------------------------------------
ACBS will not function on an adapter if the adapter has forced speed 
or duplex settings. ACBS will only function if the adapter is set to 
auto-detect or auto-negotiate.

Wake on LAN is unavailable 
--------------------------
Wake on LAN is supported on port A only on the following devices:
- Intel(R) PRO/1000 GT Quad Port Server Adapter
- Intel(R) PRO/1000 PT Quad Port Server Adapter
- Intel(R) PRO/1000 PT Dual Port Network Connection
- Intel(R) PRO/1000 PT Dual Port Server Connection
- Intel(R) PRO/1000 PT Dual Port Server Adapter
- Intel(R) PRO/1000 PF Dual Port Server Adapter
- Intel(R) PRO/1000 PT Quad Port LP Server Adapter
- Intel(R) PRO/1000 PF Quad Port Server Adapter
- Intel(R) Gigabit ET2 Quad Port Server Adapter
- Intel(R) Ethernet Server Adapter I340-T4
- Intel(R) Ethernet Server Adapter I340-T2
- Intel(R) Gigabit ET Quad Port Server Adapter
- Intel(R) Gigabit EF Dual Port Server Adapter
- Intel(R) Gigabit ET Dual Port Server Adapters
- Intel(R) Gigabit VT Quad Port Server Adapter
- Intel(R) Ethernet Server Adapter I340-F4

Intel 10GbE Network Adapters do not support Wake on LAN on any port.

System Wakes-Up from a Removed VLAN
-----------------------------------
If a system goes into standby mode, and a directed packet is sent to the 
IP address of the removed VLAN, the system will wake-up.  This occurs 
because a directed packet bypasses VLAN filtering. 

Intel Network Adapters ignore consecutive Wake Up signals while
transitioning into standby mode
-----------------------------------------------------------
While sending a system into standby, occasionally a wake up packet 
arrives before the system completes the transition into standby mode.
When this happens, the system ignores consecutive wake up signals
and remains in standby mode until manually powered up using the
mouse, keyboard, or power button.

Link flap when Energy Efficient Ethernet is enabled
---------------------------------------------------
Some switches do not support Energy Efficient Ethernet (EEE) correctly. Make 
sure your switch is loaded with the latest firmware. Disabling EEE on your 
adapter may resolve this issue.


Microsoft Windows* 8.1 and Windows Server* 2012 R2 Notes
========================================================

Some older Intel(R) Ethernet Adapters do not have full software support for 
the most recent versions of Microsoft Windows*. Many older Intel Ethernet 
Adapters have base drivers supplied by Microsoft Windows. Lists of supported 
devices per OS are available at: 
http://www.intel.com/support/go/network/adapter/nicoscomp.htm

Virtual Machine Queues are not allocated until reboot
-----------------------------------------------------
On a Microsoft Windows Server 2012 R2 system with Intel(R) Ethernet Gigabit 
Server adapters installed, if you install Hyper-V and create a VM switch, 
Virtual Machine Queues (VMQ) are not allocated until you reboot the system. 
Virtual machines can send and receive traffic on the default queue, but no 
VMQs will be used until after a system reboot.

Link loss after changing the Jumbo Frames setting
-------------------------------------------------
Inside a guest partition on a Microsoft Windows Server 2012 R2 Hyper-V 
virtual machine, if you change the jumbo frame Advanced setting on an 
Intel(R) X540 based Ethernet Device or associated Hyper-V NetAdapter, you may 
lose link. Changing any other Advanced Setting will resolve the issue.

DCB QoS and Priority Flow Control do not act as expected
--------------------------------------------------------
If you use Microsoft�s Datacenter Bridging (DCB) implementation configure 
Quality of Service (QoS) and Priority Flow Control (PFC), the actual traffic 
flow segregation per traffic class may not match your configuration and PFC 
may not pause traffic as expected. If you mapped more than one priority to a 
Traffic Class, enabling only one of the priorities and disabling the others 
will work around the issue. Installing Intel�s DCB implementation will also 
resolve this issue. 
This issue affects Microsoft Windows Server 2012 and Server 2012 R2.


Microsoft Windows* 8 and Windows Server* 2012 Notes
===================================================

Some older Intel(R) Ethernet Adapters do not have full software support for 
the most recent versions of Microsoft Windows*. Many older Intel Ethernet 
Adapters have base drivers supplied by Microsoft Windows. Lists of supported 
devices per OS are available at: 
http://www.intel.com/support/go/network/adapter/nicoscomp.htm

Hot plug operations do not work as expected in the following reference designs:
  Foxcove - Hot plug operations do not work.
  Emerald Ridge - Hot plug operations work only if you have the latest BIOS.

In Intel(R) PROSet for Windows Device Manager, the help text may not initially 
be displayed. The text should appear after switching between tabs a few times in 
Intel(R) PROSet.

DCB QoS and Priority Flow Control do not act as expected
--------------------------------------------------------
If you use Microsoft�s Datacenter Bridging (DCB) implementation configure 
Quality of Service (QoS) and Priority Flow Control (PFC), the actual traffic 
flow segregation per traffic class may not match your configuration and PFC 
may not pause traffic as expected. If you mapped more than one priority to a 
Traffic Class, enabling only one of the priorities and disabling the others 
will work around the issue. Installing Intel�s DCB implementation will also 
resolve this issue. 
This issue affects Microsoft Windows Server 2012 and Server 2012 R2.


Microsoft Windows* 7 and Windows Server* 2008 R2 Notes
======================================================

Microsoft Windows 7 and Windows Server 2008 R2 do not support Wake on 
directed packet. Systems with these operating systems will not wake on a 
ping or other directed packet.

Some older Intel(R) Ethernet Adapters do not have full software support for 
the most recent versions of Microsoft Windows*. Many older Intel Ethernet 
Adapters have base drivers supplied by Microsoft Windows. Lists of supported 
devices per OS are available at: 
http://www.intel.com/support/go/network/adapter/nicoscomp.htm

Flow Control is off by default
------------------------------
The inbox drivers for Intel network devices in Windows 7 and Windows 
Server 2008 R2 have flow control turned off by default.


Novell* NetWare* Notes
======================

Newer devices do not support Netware
------------------------------------
Devices launched after 1-1-2010 do not support Novell Netware.
Devices based on the Intel(R) 82576 controller are the last to have
Netware drivers.

Novell NetWare support for PCI Express devices
----------------------------------------------
PCI Express devices are supported in NetWare version 6.5

Netware 5.1 (and later) with gigabit adapters
----------------------------------------------
When manually installing drivers in a Netware 5.1 (and later) environment, 
there may not be enough resources for all adapters during installation, 
so the parameter of all gigabit adapters' RX buffer should be equal to 
or lower than 32 (in multiples of 8). 


Intel(R) 82562V and 82562GT 10/100 Network Connection Notes
===========================================================

The Intel(R) 82562V 10/100 Network Connection and Intel(R) 82562V 10/100 
Network Connection are supported by the gigabit drivers.


Intel 10GbE Network Adapter Notes
=================================

Attaching the cable to the Intel(R) 10 Gigabit AF DA Dual Port Server Adapter
may require significant force. The cable must be latched in for proper 
operation.

When 82599-based SFP+ devices are connected back to back, they should be set to 
the same Speed/Duplex setting. Results may vary if you mix speed settings.

Some Intel(R) 10 Gigabit Network Adapters and Connections support SFP+ 
pluggable optical modules.


82599-Based Adapters
  NOTES:
  * If your 82599-based Intel(R) Network Adapter came with Intel SFP+ optics, or 
    is an Intel(R) Ethernet Server Adapter X520 type of adapter, then it only 
    supports Intel optics and/or the direct attach cables listed below.

Supplier	Type					Part Numbers
SR Modules 	 	 
Intel		DUAL RATE 1G/10G SFP+ SR (bailed)	AFBR-703SDZ-IN2
Intel		DUAL RATE 1G/10G SFP+ SR (bailed)	FTLX8571D3BCV-IT
Intel		DUAL RATE 1G/10G SFP+ SR (bailed)	AFBR-703SDDZ-IN1
LR Modules	 	 
Intel  		DUAL RATE 1G/10G SFP+ LR (bailed)	FTLX1471D3BCV-IT    
Intel  		DUAL RATE 1G/10G SFP+ LR (bailed)	AFCT-701SDZ-IN2
Intel 	 	DUAL RATE 1G/10G SFP+ LR (bailed)	AFCT-701SDDZ-IN1
QSFP Modules
Intel							E10GQSFPSR

The following is a list of 3rd party SFP+ modules and direct attach cables 
that have received some testing. Not all modules are applicable to all devices.

Supplier     	Type					Part Numbers
Finisar 	SFP+ SR bailed, 10g single rate		FTLX8571D3BCL
Avago 		SFP+ SR bailed, 10g single rate		AFBR-700SDZ
Finisar 	SFP+ LR bailed, 10g single rate		FTLX1471D3BCL
 	 	 
Finisar 	DUAL RATE 1G/10G SFP+ SR (No Bail)    	FTLX8571D3QCV-IT   
Avago 		DUAL RATE 1G/10G SFP+ SR (No Bail)	AFBR-703SDZ-IN1 
Finisar 	DUAL RATE 1G/10G SFP+ LR (No Bail)	FTLX1471D3QCV-IT
Avago 		DUAL RATE 1G/10G SFP+ LR (No Bail)	AFCT-701SDZ-IN1

Finisar	        1000BASE-T SFP                          FCLF8522P2BTL
Avago           1000BASE-T SFP                          ABCU-5710RZ
HP              1000BASE-SX SFP                         453153-001

82599-Based SFP+ adapters support all passive and active limiting direct attach 
cables that comply with SFF-8431 v4.1 and SFF-8472 v10.4 specifications.


82599-Based QSFP+ Adapters
  NOTES:
  * 82599-Based QSFP+ adapters do not support 1x40Gbps connections. They only 
    support 4x10Gbps connections. QSFP+ link partners must be configured for 
    4x10Gbps.  
  * 82599-Based QSFP+ adapters do not support automatic link speed detection. 
    The adapter�s link speed must be configured to either 10Gbps or 1Gbps to 
    match the link partners speed capabilities. Incorrect speed configurations 
    will result in failure to link. 

The Intel(R) Ethernet Converged Network Adapter X520-Q1 only supports the optics 
and direct attach cables listed below.

Supplier	Type					Part Numbers
Intel 	 	DUAL RATE 1G/10G QSFP+ SR (bailed)	E10GQSFPSR

82599-Based QSFP+ adapters support all passive and active limiting QSFP+ direct attach 
cables that comply with SFF-8436_v4.1 specifications.


82598-Based Adapters
  NOTES: 
  * Intel(R) Network Adapters that support removable optical modules 
    only support their original module type (i.e., the Intel(R) 10 Gigabit 
    SR Dual Port Express Module only supports SR optical modules). If you 
    plug in a different type of module, the driver will not load.
  * Hot Swapping/hot plugging optical modules is not supported.
  * Only single speed, 10 gigabit modules are supported.
  * LAN on Motherboard (LOMs) may support DA, SR, or LR modules. Other 
    module types are not supported. Please see your system documentation for 
    details.

The following is a list of SFP+ modules and direct attach cables that have 
received some testing. Not all modules are applicable to all devices.

Supplier      	Type 					Part Numbers
Finisar		SFP+ SR bailed, 10g single rate  	FTLX8571D3BCL
Avago		SFP+ SR bailed, 10g single rate  	AFBR-700SDZ
Finisar		SFP+ LR bailed, 10g single rate		FTLX1471D3BCL

82598-Based adapters support direct attach cables that comply with 
SFF-8431 v4.1 and SFF-8472 v10.4 specifications with the following 
exceptions: 

Supplier        Type                                    Part Numbers
Leoni           3 meter passive direct attach cable     747522301
Amphenol        3 meter passive direct attach cable     571540002

*** Active direct attach cables are not supported.

THIRD PARTY OPTIC MODULES AND CABLES REFERRED TO ABOVE ARE LISTED ONLY FOR THE 
PURPOSE OF HIGHLIGHTING THIRD PARTY SPECIFICATIONS AND POTENTIAL COMPATIBILITY, 
AND ARE NOT RECOMMENDATIONS OR ENDORSEMENT OR SPONSORSHIP OF ANY THIRD PARTY'S 
PRODUCT BY INTEL. INTEL IS NOT ENDORSING OR PROMOTING PRODUCTS MADE BY ANY THIRD 
PARTY AND THE THIRD PARTY REFERENCE IS PROVIDED ONLY TO SHARE INFORMATION 
REGARDING CERTAIN OPTIC MODULES AND CABLES WITH THE ABOVE SPECIFICATIONS. THERE 
MAY BE OTHER MANUFACTURERS OR SUPPLIERS, PRODUCING OR SUPPLYING OPTIC MODULES 
AND CABLES WITH SIMILAR OR MATCHING DESCRIPTIONS. CUSTOMERS MUST USE THEIR OWN 
DISCRETION AND DILIGENCE TO PURCHASE OPTIC MODULES AND CABLES FROM ANY THIRD 
PARTY OF THEIR CHOICE. CUSTOMERS ARE SOLELY RESPONSIBLE FOR ASSESSING THE 
SUITABILITY OF THE PRODUCT AND/OR DEVICES AND FOR THE SELECTION OF THE VENDOR 
FOR PURCHASING ANY PRODUCT. THE OPTIC MODULES AND CABLES REFERRED TO ABOVE ARE 
NOT WARRANTED OR SUPPORTED BY INTEL. INTEL ASSUMES NO LIABILITY WHATSOEVER, AND 
INTEL DISCLAIMS ANY EXPRESS OR IMPLIED WARRANTY, RELATING TO SALE AND/OR USE OF 
SUCH THIRD PARTY PRODUCTS OR SELECTION OF VENDOR BY CUSTOMERS.

Intel 10GbE Network Adapter Known Issues
-----------------------------------------

  Supported SFP, SFP+, or QSFP+ module not recognized by the system
  -----------------------------------------------------------------
  If you try to install an unsupported module, the port may no longer install 
  any subsequent modules, regardless of whether the module is supported or not.
  The port will show a yellow bang under Windows Device manager and an event 
  id 49 (unsupported module) will be added to the system log when this issue 
  occurs. To resolve this issue, the system must be completely powered off.

  Lower than expected performance on quad port 10GbE devices
  ----------------------------------------------------------
  All SFP and QSFP quad port NICs based on the 82599 controller will link at 
  5 GT/s (PCIe gen2) when used in a system from Intel's Enterprise Platforms and 
  Services Division (EPSD). The PLX PCIe switch used on these NICs is not on 
  the EPSD white list of supported PCIe gen3 devices. 
  Devices not on the white list are blocked from linking at PCIe gen3 by the
  production BIOS.

  Lower than expected performance on dual port 10GbE devices
  ----------------------------------------------------------
  Some PCIe x8 slots are actually configured as x4 slots. These slots have 
  insufficient bandwidth for full 10Gbe line rate with dual port 10GbE devices. 
  The driver can detect this situation and will write the following message in 
  the system log: "PCI-Express bandwidth available for this card is not 
  sufficient for optimal performance. For optimal performance a x8 PCI-Express 
  slot is required." If this error occurs, moving your adapter to a true x8 
  slot will resolve the issue.

  Lower than expected performance on quad port 10GbE devices
  ----------------------------------------------------------
  Quad port 10Gbe devices require x8 PCIe gen 3 slots.  Full throughput is 
  not possible in a PCIe gen 2 slot.

  Link Loss on 10GbE Devices with Jumbo Frames enabled
  ----------------------------------------------------
  You must not lower Receive_Buffers or Transmit_Buffers below 256 if jumbo 
  frames are enabled on an Intel(R) 10GbE Device. Doing so will cause loss
  of link.

  Failed connection and possible system instability
  -------------------------------------------------
  If you have non-Intel networking devices capable of Receive-Side Scaling 
  installed in your system, the Microsoft Windows registry keyword "RSSBaseCPU" 
  may have been changed from the default value of 0x0 to point to a logical 
  processor. If this keyword has been changed then devices based on Intel(R) 
  82598 or 82599 10 Gigabit Ethernet Controllers might not pass traffic. 
  Attempting to make driver changes in this state may cause system instability. 
  Set the value of RSSBaseCpu to 0x0, or to a value corresponding to a physical 
  processor, and reboot the system to resolve the issue.


1GbE Quad Port Server Adapter Notes
===================================

Hot Plug operations are not supported by the following Intel Quad Port 
Server Adapters:
  Intel(R) Gigabit ET2 Quad Port Server Adapter
  Intel(R) Gigabit ET Quad Port Server Adapter
  Intel(R) Gigabit VT Quad Port Server Adapter
  Intel(R) PRO/1000 PF Quad Port Server Adapter
  Intel(R) PRO/1000 PT Quad Port LP Server Adapter
  Intel(R) PRO/1000 PT Quad Port Server Adapter
  Intel(R) PRO/1000 GT Quad Port Server Adapter
  Intel(R) PRO/1000 MT Quad Port Server Adapter

System does not boot
--------------------
Your system may run out of I/O resources and fail to boot if you install 
more than four quad port server adapters. Moving the adapters to different 
slots or rebalancing resources in the system BIOS may resolve the issue.
This issue affects the following Adapters:
 * Intel(R) Ethernet Server Adapter I350-T4 
 * Intel(R) Gigabit ET2 Quad Port Server Adapter
 * Intel(R) Gigabit ET Quad Port Server Adapter
 * Intel(R) Gigabit VT Quad Port Server Adapter
 * Intel(R) PRO/1000 PF Quad Port Server Adapter
 * Intel(R) PRO/1000 PT Quad Port LP server Adapter

Intel PRO/1000 GT Quad Port Server Adapter Not recommended 
for use on some systems
----------------------------------------------------------
The Intel PRO/1000 GT Quad Port Server Adapter does not function 
correctly in the following systems:
 
 * SuperMicro* P4DP6 running SCO Unixware or OpenServer 6
 * Intel(R) Server Board SE7505VB2 based systems (PCI slot 5 only. Other 
   slots work as designed)

Code 10 on Intel(R) PRO/1000 PT Quad Port LP Server Adapter
-----------------------------------------------------------
You may encounter a Windows Code 10 error with an Intel(R) PRO/1000 PT Quad 
Port LP Server Adapter installed in slot #4 of a SuperMicro 7046T-H6R system. 
Moving the adapter to another slot will resolve the issue.

Intel PRO/1000 MT Quad Port Server Adapter Known Issues
-------------------------------------------------------
The Intel PRO/1000 MT Quad Port Server Adapter operates in 3.3 volt 
PCI-X slots only. For best performance, this adapter should be installed 
in a 64-bit PCI-X slot. Refer to the detailed installation instructions 
in the User's Guide for additional requirements.

Wake on LAN is not supported on the Intel PRO/1000 MT Quad Port Server 
Adapter. Trying to enable this feature with IBAUTIL.EXE will not have any 
effect.

The Intel PRO/1000 MT Quad Port Server Adapter supports Intel(R) Boot Agent 
functionality on ports A and B, however it is disabled by default. To 
enable and use the Intel Boot Agent, refer to the User's Guide and 
other information in the \APPS\BOOTAGNT\ directory.

  Multiple Intel PRO/1000 MT Quad Port Server Adapters in one system
  ------------------------------------------------------------------
  Installing more than two Intel PRO/1000 MT Quad Port Server Adapters in 
  the same system is not recommended. Many systems are unable to support 
  the power requirements for more than two of these adapters. 

  Use only in a PCI-X Slot
  ------------------------
  Reduced performance has been observed when the Intel PRO/1000 MT Quad 
  Port Server Adapter is installed in a slot other than a PCI-X slot.

  Shared Interrupt Limitation 
  ---------------------------
  In some systems, the BIOS and OS assign the same interrupt number to 
  two or more different ports on the Intel PRO/1000 MT Quad Port Server 
  Adapter. If this occurs, these ports do not function properly. To 
  address this issue, reassign the system resources so that each port 
  of the adapter has its own unique interrupt number or disable one of 
  the ports sharing the same interrupt number. 

  Downshifting
  ------------
  When connecting to any Gigabit switch via a faulty CAT 5 cable where 
  one pair is broken, the adapter does not downshift from 1 Gig to 
  100Mbps. For the adapter to downshift, it must identify two broken 
  pairs in the cable.

  Intel PRO/1000 MT Quad Port Server Adapter Not recommended 
  for use on some systems
  ----------------------------------------------------------
  The Intel PRO/1000 MT Quad Port Server Adapter does not function 
  correctly in the following systems:
 
  Dell* PowerEdge* 2500
  Dell PowerEdge 6400
  Dell PowerEdge 6450
  Dell PowerEdge 6650SC
  Intel Saber, Saber-R, and Saber-Rx Systems
  SuperMicro 370DE6
  SuperMicro P4DP6
  IBM* eServer* xSeries* 365
 
  Using the Intel PRO/1000 MT Quad Port Server Adapter in these 
  configurations is not recommended.

  Heavy traffic may cause system reboot in some systems
  -----------------------------------------------------
  Using an Intel PRO/1000 MT Quad Port Server Adapter may cause a reboot 
  in systems with the Intel Profusion chipset including: Intel OCPRF100 
  and SRPM8 server systems; Compaq* ProLiant* 8000, 8500, ML750, DL760; 
  Dell PowerEdge 8450, 6300, 6350; IBM* x370.  Using the Intel PRO/1000 
  MT Quad Port Server Adapter in these configurations is not recommended.


Known Issues
============

  Enable PME setting not set to expected value
  --------------------------------------------
  After running Sysprep, the Enable PME setting may not be set to the 
  expected value.You should manually verify and configure the setting.

  Receive Side Scaling value is blank
  -----------------------------------
  Changing the Receive Side Scaling setting of an adapter in a team may 
  cause the value for that setting to appear blank when you next check it. 
  It may also appear blank for the other adapters in the team. The adapter 
  may be unbound from the team in this situation. Disabling and enabling the 
  team will resolve the issue. 

  CPU utilization higher than expected
  ------------------------------------
  Setting RSS Queues to a value greater than 4 is only advisable for large 
  web servers with several processors. Values greater than 4 may increase
  CPU utilization to unacceptable levels and have other negative impacts
  on system performance.

  RSS Load Balancing Profile Advanced Setting
  -------------------------------------------
  Setting the "RSS load balancing profile" Advanced Setting to 
  "ClosestProcessor" may significantly reduce CPU utilization. However, in 
  some system configurations (such as a system with more Ethernet ports than 
  processor cores), the "ClosestProcessor" setting may cause transmit and receive 
  failures. Changing the setting to "NUMAScalingStatic" will resolve the issue.

  Unexpected link loss when connected to Netgear XSM7224S switch
  --------------------------------------------------------------
  The Netgear XSM7224s switch is sensitive to Energy Efficient Ethernet (EEE) 
  mode. Link flap errors will occur with several Intel devices when EEE mode 
  is enabled. Disable EEE mode to resolve the issue. This issue affects 
  devices based on the following:
  * Intel(R) I350 controller
  * Intel(R) 82579 series of controllers
  * Intel(R) I217 series of controllers
  * Intel(R) I218 series of controllers

  Reboot Prompt Appears when modifying the Performance Profile
  ---------------------------------------------------------------------
  In Microsoft* Windows Server*, after modifying the performance profile, 
  a reboot prompt may appear. The Intel� Ethernet FCoE boot was configured 
  and there is no need to reboot. The base driver reloads are blocked 
  if FCoE boot is configured and the system is connected to an FCoE target, 
  even if the system was booted locally.

  Opening Windows Device Manager property sheet takes longer than expected
  ------------------------------------------------------------------------
  The Windows Device Manager property sheet may take 60 seconds or longer to open. 
  The driver must discover all Intel Ethernet devices and initialize them before 
  it can open the property sheet. This data is cached, so subsequent openings of
  the property sheet are generally quicker. 

  Audio or video distortion when LAN cable is connected or disconnected
  ---------------------------------------------------------------------
  Momentary audio distortion or video playback issues may occur when you 
  connect or disconnect a LAN cable to the onboard Ethernet port. 
  Intel(R) 82577 and 82578 based network connections are affected by this 
  issue. 

  Reduced or erratic receive performance
  --------------------------------------
  Intel(R) 7500 chipset-based systems may experience degraded receive 
  performance. Increasing receive descriptors to 1024 will resolve the 
  issue. Disabling C-states in the system BIOS will also resolve the issue.

  Activity LED blinks unexpectedly
  --------------------------------
  If a system based on the 82577, 82578, or 82579 controller is connected 
  to a hub, the Activity LED will blink for all network traffic present on 
  the hub. Connecting the system to a switch or router will filter out most 
  traffic not addressed to the local port.

  Unexpected NMI with 82599-based NICs
  ------------------------------------
  If you set the PCIe Maximum Payload Size to 256 bytes in your system BIOS
  and install an 82599-based NIC, you may receive an NMI when the NIC attains 
  link. This happens when the physical slot does not support a payload size 
  of 256 Bytes even if the BIOS does. Moving the adapter to a slot that 
  supports 256 bytes will resolve the issue. Consult your system documentation 
  for information on supported payload values.

  VLANs are not supported on VMQ enabled adapters and teams
  ---------------------------------------------------------
  If you create a VLAN on a VMQ enabled adapter, the VMQ setting will 
  automatically be set to disabled. The same will happen if you create a 
  VLAN on a team whose member adapters have VMQ enabled.

  Unexpected Connectivity Loss
  ----------------------------
  If you uncheck the "Allow the computer to turn off this device to save 
  power" box on the Power Management tab and then put you system to sleep, 
  you may lose connectivity when you exit sleep. You must disable and enable 
  the NIC to resolve the issue. Installing Intel(R)PROSet for Windows Device 
  Manager will also resolve the issue.

  Device Manager freezes on VLAN removal
  --------------------------------------
  Removing multiple VLANs from the Intel(R) 82576 Virtual Function device may 
  cause Device Manager to freeze. You must reboot the virtual partition to 
  resolve the issue.

  SNMP errors in the System Event Log
  -----------------------------------
  Under Microsoft Windows 7 or Windows Server 2008 R2, you may see the 
  following error in the System Event Log: "The SNMP Service encountered 
  an error while accessing the registry key 
  "SYSTEM\CurrentControlSet\Servcies\SNMP\Parameters\TrapConfiguration"
  The Windows 7 SNMP service start up isn't properly configuring the service 
  with a TrapConfiguration key. Perform the following to correct the issue:
   1. Open Services applet (run services.msc).
   2. Right click on SNMP Service, then select Properties.
   3. Click on the Traps tab. Enter "public" for the Community name and 
      click Add to list.
   4. Click on the Security tab. Click the Add button. Enter "public" and 
      click on the Add button.

  System hang at login or shut down
  ---------------------------------
  On the systems listed below, installing Intel(R) Gigabit Quad Port Server 
  Adapters may hang the system at the login screen or when shutting down. 
  This has been reported on:
  *  Intel(R) PRO/1000 PT Quad Port LP Server Adapter
  *  Intel(R) Gigabit ET Quad Port Server Adapter
  And systems with the following motherboards:
  *  Intel(R) Server Board S5400SF
  *  Intel(R) Server Board S5000VSA
  *  Intel(R) Server Board S5000PAL
  *  Intel(R) Server Board S5000XAL
  *  Intel(R) Workstation Board S5000XVN

  Installing system BIOS 97 or later will resolve this issue.

  VLANs unsupported on some Intel devices
  ---------------------------------------
  The following devices do not support VLANs:
   - Intel(R) 82567V-2 Gigabit Network Connection
   - Intel(R) 82567V Gigabit Network Connection

  Direct Assignment in a Virtual Environment
  ------------------------------------------
  The following Intel devices do not support Direct Assignment:
   - All PCI devices
   - All PCI-X devices
   - Older PCIe devices

  Reduced Large Send Offload performance
  --------------------------------------
  Large Send Offload (LSO) and IPSec Offload are not compatible. LSO is 
  automatically disabled when IPSec Offload is enabled. This may reduce 
  the performance of non-IPSec traffic. Confining all of your IPSec 
  traffic to one port and enabling IPSec Offload only on that port
  may mitigate this issue.
  On Microsoft Windows 8/Server 2012 and later, devices based on the
  82576, 82599, and X540 controllers are not affected by this issue.

  Hot Plug does not function in Microsoft Windows
  -----------------------------------------------
  On an Intel(R) Server System SR9000MK4U, the following dual port server 
  adapters cannot be removed using the system's Hot Plug functionality. 
  Use the Windows Safely Remove Hardware utility to remove the adapters.

  Intel(R) PRO/1000 PT Dual Port Server Adapter
  Intel(R) 10 Gigabit XF SR Dual Port Server Adapter

  Hot Add operations may fail on Intel(R) Gigabit ET Dual Port Server 
  Adapters. Doing so may cause a code 12 error. Hot Replace operations 
  function normally.

  Dropped Receive Packets on Half-duplex 10/100 Networks
  ------------------------------------------------------
  If you have an Intel PCI Express adapter installed, running at 10 or 
  100 Mbps, half-duplex, with TCP Segment Offload (TSO) enabled, you may 
  observe occasional dropped receive packets.  To work around this 
  problem, disable TSO, or update the network to operate in full-duplex 
  and/or 1 Gbps.

  Lost SOL and IDER sessions
  --------------------------
  SOL and IDER sessions may be lost if spanning tree is enabled. Turn off 
  spanning tree protocol on switch ports connected to devices configured 
  for SOL and IDER access.

  Procedure for installing and upgrading drivers and utilities
  ------------------------------------------------------------
  Intel does not recommend installing or upgrading drivers and Intel(R)
  PROSet software over a network connection. Instead, install or upgrade
  drivers and utilities from each system. To install or upgrade drivers
  and utilities, follow the instructions in the User Guide.

  Installing Intel PROSet and Intel PROSet for Windows Device Manager on 
  the same system
  ----------------------------------------------------------------------
  The Intel PROSet install process prevents installing both Intel PROSet 
  and Intel PROSet for Windows Device Manager on the same system. When you 
  install Intel PROSet for Windows Device Manager, prior versions of PROSet 
  are uninstalled automatically. 

  "Malicious script detected" warning from Norton AntiVirus* during 
  PROSet Uninstall
  -----------------------------------------------------------------
  The Intel PROSet uninstall process uses a Visual Basic script as part of 
  the process.  Norton AntiVirus and other virus scanning software may 
  mistakenly flag this as a malicious or dangerous script. Letting the script 
  run allows the uninstall process to complete normally.

  "Out Of Disk Space" Message during Installation
  -----------------------------------------------
  The boot partition requires a minimum of 15 MB free space in order to install 
  Intel PROSet, regardless of which drive you specify for installation.  If 
  there is insufficient space on the partition you will see this error 
  message, and the product will not install.  

  Windows Code 10 Error Message on Driver Install or Upgrade
  ----------------------------------------------------------
  If you encounter a Windows Code 10 error message when installing or 
  upgrading drivers, reboot to resolve the issue.

  Throughput reduction after Hot-Replace
  --------------------------------------
  If an Intel gigabit adapter is under extreme stress and is hot-swapped,
  throughput may significantly drop.  This may be due to the PCI property
  configuration by the Hot-Plug software.  If this occurs, throughput can
  be restored by restarting the system.

  No settings available on the Intel(R) Boot Options tab in Windows Device 
  Manager after flashing an EFI image
  ----------------------------------------------------------------------
  The settings have been hidden because the EFI environment does not make 
  use of them.

  Red Screen with 5400 general exception error after 
  lanutil64 -blink -all command
  --------------------------------------------------
  Using the EFI lanutil64 utility to blink the identification LEDs on all 
  network connections on systems that contain Intel PRO/100 devices may 
  cause the system to crash with a 5400 general exception error. Using the 
  utility to blink the identification LED on an individual network connection 
  will not cause the system to crash.

  Link Difficulties With 82541 or 82547 Based Connections
  -------------------------------------------------------
  The PROSet Advanced tab now contains a setting allowing the 
  master/slave mode to be forced. This improves time-to-link with 
  some unmanaged switches. For older adapters and controllers, you 
  may encounter difficulty with 82541 or 82547 based connections.

  Using Intel PRO/1000 XT or T Adapters and e1000ODI.COM Driver
  -------------------------------------------------------------
  In some cases, an Intel PRO/1000 T or PRO/1000 XT adapter or network 
  connection using the e1000ODI.COM driver will not receive traffic. 
  You can fix this problem by disabling Wake On LAN (WOL) in the 
  adapter hardware before connecting to the network. 
 
  Use IBAUtil to disable WOL. For more information, see the IBAUTIL.TXT 
  file for more information (\APPS\BOOTAGNT directory).  

  Intel Gigabit Network Adapters (copper only) do not detect active 
  link during load time
  -----------------------------------------------------------------
  Some Intel Gigabit Network adapters, especially copper adapters, cannot
  detect an active link during load time. To resolve this issue, try
  the following workarounds.
  - Re-attach to the server without reloading the driver.
  - For DOS-based installations, add a delay of 4 to 5 seconds in the 
    batch file after the load driver command.
  - Load the configuration by manually entering commands.
  - Set adapter to link at 1000 Mbps only. 

  Network stack will not enable RSC
  -------------------------------------------------------
  If Intel Data Center Bridging (DCB) is installed (FCoE, iSCSi, or both),
  the network stack will not enable Receive Segment Coalescing (RSC).

  PXE option ROM does not follow the PXE specification with respect to the 
  final "discover" cycle
  ------------------------------------------------------------------------
  In order to avoid long wait periods, the option ROM  no longer includes
  the final 32-second discover cycle. (If there was no response in the prior 
  16-second cycle, it is almost certain that there will be none in the final, 
  32-second cycle.

Customer Support
================

- Main Intel support website: http://support.intel.com

- Network products information: 
               http://support.intel.com/support/go/network/adapter/home.htm


Legal / Disclaimers
===================

Copyright (C) 1998-2013, Intel Corporation.  All rights reserved.

Intel Corporation assumes no responsibility for errors or omissions in 
this document. Nor does Intel make any commitment to update the information 
contained herein.

* Other product and corporate names may be trademarks of other companies 
and are used only for explanation and to the owners' benefit, without intent 
to infringe.
