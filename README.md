# Run Linux on Embedded Device Safely

Raspberry PI and Arduion have become popular recently and it is easy to install Linux on them. 
Some applications can run without display or keyboard/mouse. Examples would be a NAS, web or print server, 
any control system reading data from sensors and/or controling actors. 

For such devices we got used to switch them off by pulling the plug rather than shutting them down cleanly and wait. 

With a Linux installed pulling the plug can corrupt the file system or make it unusable even with a journaling FS. 

This project shows a safe configuration based on an Ubuntu 18.04 on Raspberry PI. It should be portable to other
Linux versions and flavours.

## Scope

Provides a configuration example of files mostly in /etc. This configuration:

- makes the root filesystem read-only
- overlays the root filesystem with a temporary filesystem in memory
- both overlayed filesystems can be viewed separately
- limits the space needed for log files
- removes cloud-init service of Ubuntu 18.04 (ignore if you want it)

## Advantages

- no FS corruption when pulling the plug
- no corruption by intruders
- see the changes of a running Linux FS

## Description

The single commits show the different steps taken. I put a git repository in the root folder allowing me to track the changes
and publish it straight here. I am still working on a good .gitignore file for that.

### Log Rotation

Operating a read-only filesystem with an in-memory temporary FS on a smallish microcontroller does not allow for large log 
files and journals. The logrotation configuration was modified to limit all logs to a reasonable size less than 1MB each. 
Feel free to adapt to your application. Be sure that the logrotate files in /etc/logrotate.d belong to root.

After some attacks creating quickly megabytes of btmp files I moved the logrotate configuration for btmp and wtmp from logrotate.conf
to separate files in /etc/logrotate.d. I also moved the logrotate script from /etc/cron.daily to /etc/cron.hourly to make 
hourly rotations work.

### Layered Filesystem

A read-only root filesystem and a temporary in-memory FS are created and overlayed at boot-up. This requires updates in 
initramfs. The overlay uses the aufs driver but you can easily configure the overlayfs driver. After boot-up the root FS
appears read and writable as on a normal Linux. Yet all changes to the root filesystem go to the temporary FS. 
The read-only FS is mounted at /mnt/root-ro while the temporary FS is mounted at /mnt/root-rw. In /mnt/root-rw you
will see any changes on the FS.

If you switch off the device, all changes are gone: logs, OS updates (via apt install)...

#### Advantage: Whatever happens - switch if off and on and you are back to normal

#### Disadvantage: If you intend to change the root FS the process is slightly more complex

#### Small Changes to root FS

Let us say you want to enter a hostname in /etc/hosts and make this change permanent. Run the command:

```
$ sodu mount -o remount,rw /mnt/root-ro
```

Edit /mnt/root-ro/etc/hosts. If you edit /etc/hosts changes will be lost after shutdown. Once editing of this file
and possisbly others you want to make the root FS read-only again:

```
$ sodu mount -o remount,ro /mnt/root-ro
```
#### Complex Changes to root FS

An example of a complex change to the root FS is updating Linux (via apt upgrade). Re-mounting /mnt/root-ro and installing
updates fails since the updates are written to the temporary FS although you made /mnt/root-ro read and writable.

The initramfs script allows to disable the overlay FS after next reboot. Therefore put a (empty) file named 
disable-root-ro into /mnt/root-rw/disable-root_ro following the instructions for Small Changes to root FS (abore).

Now reboot and you can perform apt upgrade...

### Disable unwanted Features

You will now know that updates do not work out of the box. Hence unattented updates must not happend. 

Cloud-init is another feature that was disabled. 

### Gratitudes

Many thanks to

- Forest Bond: HOW TO: BUILD A READ-ONLY LINUX SYSTEM; URL: https://www.logicsupply.com/company/io-hub/how-to-build-a-read-only-linux-system/
- Mattias Geniar: Clear systemd journal; URL: https://ma.ttias.be/clear-systemd-journal/
,
