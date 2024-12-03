#!/bin/sh
#
# If a read-only root filesystem is overlayed with a temporary 
# filesystem, any installation goes into the temporary. 
# This script informs the user and allows to switch over to
# rw root filesystem.

rootRO=/mnt/root-ro

#(df | grep -q "$rootRO"    ) || exit 0
#(df | grep -q "mnt/root-rw") || exit 0
#(df | grep -q "aufs"       ) || exit 0

echo
echo "NOTE: You are trying to modify the root FS."
echo "      You are currently running on a"
echo "      read-only root FS."
echo "      Any installations would be lost."
echo
echo "Do you wish to REBOOT to a writable root FS for"
echo -n "installations (YES/[N])? "

read reply

if [ "$reply" != "YES" ]; then
    echo "Answer 'YES' (all capital) to continue - try again"
    exit 0
fi

#backupDir=$HOME
# use external drive for space:
backupDir=/home/ubuntu
echo "Do you wish to backup the boot and root"
existsLink=0
test -L "$backupDir/PI-backup" && existsLink=1
if [ $existsLink -eq 1 ]; then
    dirContents=$(sudo ls $backupDir/PI-backup 2> /dev/null)
    if [ "$dirContents" != "$backupDir/PI-backup" ]; then
        backupDir=$backupDir/PI-backup
    fi
fi
echo -n "partitions to $backupDir ([y]/NO)? "

read reply

if [ "$reply" != "NO" ]; then
    d=$(date -I)
    sudo dd if=/dev/mmcblk0p1 of=$backupDir/boot-backup-$d.dat status=progress
    if [ $? != 0 ]; then 
	echo ERROR: boot partition backup failed - exiting - no reboot
        exit 1
    fi
    sudo dd if=/dev/mmcblk0p2 of=$backupDir/root-backup-$d.dat status=progress
    if [ $? != 0 ]; then 
	echo ERROR: root partition backup failed - exiting - no reboot
        exit 1
    fi
fi

if [ -d $rootRO ]; then
    sudo mount -o remount,rw $rootRO
else
    exit 0
fi

if [ -e $rootRO/do-not-disable-root-ro ]; then
    sudo cp $rootRO/do-not-disable-root-ro $rootRO/disable-root-ro 
else
    sudo touch $rootRO/disable-root-ro 
fi

if [ -e $rootRO/do-not-forcefsck ]; then
    sudo cp $rootRO/do-not-forcefsck $rootRO/forcefsck
else
    sudo touch $rootRO/do-not-forcefsck 
fi

sudo /sbin/reboot

exit 0
