
    This is a romfs file system driver for Windows NT/2000/XP.
    Copyright (C) 1999, 2000, 2001, 2002, 2003 Bo Brantén.
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Windows and Windows NT are either registered trademarks or trademarks of
    Microsoft Corporation in the United States and/or other countries.

    Please send comments, corrections and contributions to bosse@acc.umu.se

    The most recent version of this driver is available from:
    http://www.acc.umu.se/~bosse/romfs.zip

    The most recent free version of the file ntifs.h is available from:
    http://www.acc.umu.se/~bosse/ntifs.h

    Credits:

      The following persons has given me information that helped me improve
      this driver, for more credits see the free version of the file ntifs.h.

      Gunnar André Dalsnes (byte-range file locks)
      Matt Wu (FileAttributeTagInformation)
      Vadim V Vorobev (directory change notification)

    Revision history:

   14. 2003-04-07
       Corrected an error in the handling of create requests that made
       duplicate FCB's for the same file.

   13. 2003-02-20
       Correction so that unload work on Windows XP also.
       Added use of FsRtlNotifyVolumeEvent.
       Changed to use of AbnormalTermination.
       Implemented handling of share access.
       Uppdated the handling of work queue items.
       Some improvements on the handling of create requests.
       Some improvements on the debug prints.

   12. 2002-12-25
       Corrected an error in FsdQueryDirectory in the initialization of the
       search pattern when none was specified by the user at the first query.
       Corrected an overflow error when using FlagOn and storing the result in
       a boolean.
       Pass on ioctl's only for volume opens.
       Implemented support for FileIdFullDirectoryInformation and
       FileIdBothDirectoryInformation.
       Reorganized the functions for handling blockdevices.
       Changed the handling of directory change notification to use unicode
       strings.
       Some improvements on the debug prints.
       Added unlock volume in the umount program.
       Small improvement on the error handling in the unload program.

   11. 2002-05-25
       Some corrections so that romfs can be compiled with more versions of
       the DDK and ntifs.h.

   10. 2001-12-23
       Improved the handling of create requests.
       Corrected an error that incremented the reference count on busy files
       when trying an umount that failed.
       Corrected the use of ProbeForWrite so that it is not called when
       Irp->RequestorMode is KernelMode.
       Moved unlock volume from close to cleanup.

    9. 2001-11-09
       Changed the implementation of read requests so that they work at
       APC_LEVEL and does not need to be queued to a worker thread.
       Uppdated FsdGetUserBuffer to use MmGetSystemAddressForMdlSafe on
       Windows 2000.
       Added ProbeForWrite before accessing the user buffer in dirctl.c and
       read.c.
       Implemented support for FileFsFullSizeInformation.
       Changed the method for debug printing process names to the one used in
       Filemon from Sysinternals since it is more compatible across different
       versions of Windows.
       Put debug information in .pdb file on Windows NT 4.0 DDK.
       Corrected the setup of an completion routine in devctl.c.
       Corrected the placements of FsRtlEnterFileSystem in fastio.c.
       Corrected the placement of acquireing a resource in dirctl.c.
       Corrected the initializement of Fcb->FileAttributes when the driver is
       compiled read-only.
       Corrected a problem in runbuild.bat.
       Reorganized what code is paged/non-paged to what I think is right.
       Small change in the handling of directory change notification.
       Improved DbgPrint in init.c.
       Various code clenups.

    8. 2001-10-01
       Implemented support for directory change notification. Since the driver
       is currently read-only no directories will change but we support this
       call from applications.

    7. 2001-09-14
       Implemented support for byte-range file locks.
       Some improvements on the error handling in the FsdFastIoQueryXxxInfo
       functions.
       Implemented support for FileAttributeTagInformation.

    6. 2001-08-22
       Changed the section names used with #pragma code_seg() to upper case
       since the checked build of NT DbgPrint a notification otherwise.
       Corrected the use of FsRtlIsNameInExpression so that it is only called
       if the parameter Expression realy contain wild cards since the checked
       build of NT does an assertion otherwise.
       Corrected the use of FsRtlEnterFileSystem and FsRtlExitFileSystem so
       that they are only called at IRQL PASSIVE_LEVEL.
       Implemented pool taging to help find memory leaks.
       Fixed a memory leak in create.c.
       Initializing FileObject->Vpb in create.c.
       Initializing VolumeLabel, VolumeLabelLength and SerialNumber in the VPB
       at mount time.
       Code cleanup in cmcb.c and devctl.c.
       Implemented exception handling in the FsdFastIoQueryXxxInfo functions.
       Improved DbgPrint in devctl.c.

    5. 2001-06-12
       Temporary workaround for a bug in close that makes it reference a
       fileobject when it is no longer valid.
       Improvements on handling of lock volume, dismount volume and verify
       volume. It is now possible to dismount volumes and unload the driver
       even if previously opened files is still cached by NT (but has been
       closed by the user)

    4. 2001-05-13
       Corrected an error that made you have to type filename.exe instead of
       just filename to run a program.
       Using IoAcquireVpbSpinLock and IoReleaseVpbSpinLock when setting and
       clearing flags in the VPB.
       Using the VPB flag VPB_LOCKED.
       Corrected the requeuing of read requests with IRP_MN_DPC.
       Optimized reading of sector aligned file data.

    3. 2001-05-05
       Implemented support for:
         FSCTL_LOCK_VOLUME
         FSCTL_UNLOCK_VOLUME
         FSCTL_DISMOUNT_VOLUME
         FSCTL_IS_VOLUME_MOUNTED
         Unloading the driver.
       Programs to umount and unload.
       Some improvements on handling of create requests.
       Corrected:
         FsdDbgPrintCall
         FsdFastIoQueryBasicInfo
         FsdFastIoQueryStandardInfo
         FsdFastIoQueryNetworkOpenInfo

    2. 2001-04-29
       Some improvements on handling of create requests.
       Corrected handling of STATUS_VERIFY_REQUIRED.
       Corrected FsdVerifyVolume.
       Redesign of the fast I/O routines.
       Added a version resource.

    1. 2001-04-21
       Initial release.

    2000-07-11
       Non public pre-release.

    1999-06-12
       The project was started.

    Known bugs:

      On Windows NT 4.0 it is not possible to open a file on romfs from a
      Windows common file dialog box. When clicking on open nothing happens.
      This error doesn't ocur on Windows 2000.

      When replacing a romfs floppy with a fat floppy while there are files
      open a bugcheck ocurs on the next access. If an unreadable floppy, for
      example an unformated, is accessed in between no bugcheck ocurs,
      neither if all files has been closed before switching floppy.
